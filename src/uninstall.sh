#!/system/bin/sh
# Apex Render v4.6.1 - Uninstaller
# by Ibanez ★

BOOST_PATH="/sys/module/cpu_boost/parameters"
[ -d "$BOOST_PATH" ] && {
    echo "0" > "$BOOST_PATH/input_boost_freq" 2>/dev/null
    echo "0" > "$BOOST_PATH/input_boost_ms" 2>/dev/null
}

[ -d "/dev/stune/top-app" ] && {
    echo "0" > /dev/stune/top-app/schedtune.boost 2>/dev/null
    echo "0" > /dev/stune/top-app/schedtune.prefer_idle 2>/dev/null
}
[ -d "/dev/stune/foreground" ] && {
    echo "0" > /dev/stune/foreground/schedtune.boost 2>/dev/null
    echo "0" > /dev/stune/foreground/schedtune.prefer_idle 2>/dev/null
}

for p in persist.vendor.power.dfps.level ro.vendor.display.default_fps \
         persist.sys.sf.high_fps sys.use_fifo_ui debug.gr.num_buffers \
         vendor.display.enable_bypass_version debug.renderengine.backend \
         debug.cpurend.disable debug.performance.tuning persist.sys.composition.type \
         ro.hwui.texture_cache_size ro.hwui.layer_cache_size ro.hwui.r_buffer_cache_size ro.hwui.path_cache_size; do
    setprop "$p" "" 2>/dev/null
done

# Reset v3 props
setprop persist.vendor.night.mode "" 2>/dev/null
setprop vendor.powerhal.init "" 2>/dev/null
setprop ro.vendor.power.config "" 2>/dev/null
setprop persist.sys.background_location_interval "" 2>/dev/null
setprop ro.config.auto_retrieval "" 2>/dev/null

settings put global wifi_scan_always_enabled 1 2>/dev/null
settings put global ble_scan_always_enabled 1 2>/dev/null

for gov in /sys/devices/system/cpu/cpufreq/policy*/schedutil; do
    [ -d "$gov" ] && {
        echo "10000" > "$gov/up_rate_limit_us" 2>/dev/null
        echo "10000" > "$gov/down_rate_limit_us" 2>/dev/null
        echo "0" > "$gov/pl" 2>/dev/null
        echo "0" > "$gov/rate_limit_us" 2>/dev/null
    }
done
for cpu in /sys/devices/system/cpu/cpufreq/policy*/scaling_{min,max}_freq; do
    echo "0" > "$cpu" 2>/dev/null
done

if [ -d "/sys/devices/system/cpu/cpuidle" ]; then
    echo "0" > /sys/devices/system/cpu/cpuidle/low_power_state 2>/dev/null
fi

echo "msm-adreno-tz" > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
echo "0" > /sys/class/kgsl/kgsl-3d0/max_gpuclk 2>/dev/null
echo "0" > /sys/class/kgsl/kgsl-3d0/min_gpuclk 2>/dev/null
echo "80" > /sys/class/kgsl/kgsl-3d0/idle_timer 2>/dev/null
echo "0" > /sys/class/kgsl/kgsl-3d0/force_no_nap 2>/dev/null
echo "1" > /sys/class/kgsl/kgsl-3d0/throttling 2>/dev/null

echo "100" > /proc/sys/vm/swappiness 2>/dev/null
echo "100" > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
echo "20" > /proc/sys/vm/dirty_ratio 2>/dev/null
echo "10" > /proc/sys/vm/dirty_background_ratio 2>/dev/null
echo "500" > /proc/sys/vm/dirty_writeback_centisecs 2>/dev/null
echo "3000" > /proc/sys/vm/dirty_expire_centisecs 2>/dev/null
echo "3" > /proc/sys/vm/page-cluster 2>/dev/null
echo "64" > /proc/sys/kernel/random/read_wakeup_threshold 2>/dev/null
echo "128" > /proc/sys/kernel/random/write_wakeup_threshold 2>/dev/null

echo "0,1,2,3,4,5" > /sys/module/lowmemorykiller/parameters/adj 2>/dev/null
echo "0,0,0,0,0,0" > /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null

echo "0" > /proc/sys/kernel/yama/ptrace_scope 2>/dev/null
echo "2" > /proc/sys/kernel/randomize_va_space 2>/dev/null
echo "7 4 1 7" > /proc/sys/kernel/printk 2>/dev/null

echo "cubic" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
echo "0" > /proc/sys/net/ipv4/tcp_ecn 2>/dev/null
echo "1" > /proc/sys/net/ipv4/tcp_sack 2>/dev/null
echo "1" > /proc/sys/net/ipv4/tcp_timestamps 2>/dev/null
echo "2097152" > /proc/sys/net/core/rmem_max 2>/dev/null
echo "2097152" > /proc/sys/net/core/wmem_max 2>/dev/null
setprop net.dns1 "" 2>/dev/null
setprop net.dns2 "" 2>/dev/null

settings put global device_idle_constants "" 2>/dev/null

pm enable com.google.android.gms/.chimera.GmsIntentOperationService 2>/dev/null
pm enable com.google.android.apps.googleassistant 2>/dev/null
pm enable com.android.hotwordenrollment.okgoogle 2>/dev/null
pm enable com.google.android.gms/.analytics.AnalyticsService 2>/dev/null
pm enable com.google.android.gms/.analytics.AnalyticsTaskService 2>/dev/null
pm enable com.google.android.gms/.measurement.AppMeasurementService 2>/dev/null
pm enable com.google.android.feedback 2>/dev/null
settings put global stats_collection 1 2>/dev/null
settings put global usage_stats_collection 1 2>/dev/null

for pkg in \
    com.miui.hybrid com.miui.phrase com.miui.contentcatcher com.xiaomi.airlink com.miui.securitycatcher.remote \
    com.miui.analytics com.miui.msa.global com.miui.daemon com.xiaomi.ab com.xiaomi.mtb \
    com.miui.bugreport com.bsp.catchlog com.modemdebug com.swfp.factory \
    com.google.android.as com.google.android.aicore com.google.android.apps.aiwallpapers \
    com.google.android.apps.wellbeing com.google.mainline.telemetry \
    com.facebook.appmanager com.facebook.services com.facebook.system \
    com.xiaomi.mi_connect_service com.xiaomi.mireconnect com.milink.service \
    com.miui.mishare.connectivity com.xiaomi.midrop com.xiaomi.miplay_client \
    com.xiaomi.mirror com.miui.freeform com.miui.cleaner com.miui.yellowpage \
    com.xiaomi.mipicks com.xiaomi.glgm com.xiaomi.payment com.mipay.wallet \
    com.mi.globalTrendNews com.mi.globalbrowser com.miui.hybrid \
    com.miui.android.fashiongallery com.miui.cloudservice com.miui.cloudbackup \
    com.miui.micloudsync com.miui.backup com.miui.videoplayer com.miui.player \
    com.miui.translation.kingsoft com.miui.translationservice; do
    pm enable "$pkg" 2>/dev/null
done

start thermal-engine 2>/dev/null
start thermal-manager 2>/dev/null
pm enable com.xiaomi.joyose 2>/dev/null

mount -o remount,relatime /data 2>/dev/null
mount -o remount,relatime /cache 2>/dev/null

log -p i -t Apex_v4 "Apex Render v4.6.1 uninstalled. System restored."