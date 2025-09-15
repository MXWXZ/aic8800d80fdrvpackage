#!/bin/bash

eject_device() {
    if [ -L /dev/aicudisk ]; then
        rmmod aic_load_fw
        eject /dev/aicudisk
        insmod /lib/modules/$(uname -r)/kernel/drivers/net/wireless/aic8800/aic_load_fw.ko
    fi
}

UPTIME=$(awk '{print $1}' /proc/uptime)
UPTIME_SECS=$(echo "scale=0; $UPTIME / 1" | bc)
if [ "$UPTIME_SECS" -lt 30 ]; then
    sleep $((30 - UPTIME_SECS))
fi

if [ -e /run/systemd/system ]; then
    eject_device
else
    SYSTEMD_STARTUP_FILE="/run/udev/usb-eject-startup"

    if [ ! -f "$SYSTEMD_STARTUP_FILE" ]; then
        touch "$SYSTEMD_STARTUP_FILE"

        systemd-run --unit=usb-eject-delayed --on-active=60 --service-type=oneshot /usr/local/bin/usb-eject-delay.sh
    fi
fi
