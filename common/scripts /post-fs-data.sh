#!/system/bin/sh

# Mount partitions with noatime for less writes
mount -o remount,noatime,nodiratime /data 2>/dev/null
mount -o remount,noatime,nodiratime /cache 2>/dev/null

# Disable WiFi/BT scanning early
settings put global wifi_scan_always_enabled 0 2>/dev/null
settings put global ble_scan_always_enabled 0 2>/dev/null

# Force 60Hz early
setprop persist.vendor.power.dfps.level 0
setprop ro.vendor.display.default_fps 60
setprop persist.sys.sf.high_fps 0