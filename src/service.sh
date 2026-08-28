#!/system/bin/sh
# Apex Render v4.6.1 - Core Engine (Fusion v3 + v4.6 + extra tweaks)
# by Ibanez ★
# Commit: feat: merge HyperOS 3 optimizations with v4.6 micro-stutter fix
# Commit: perf: lower down_rate to 30, boost to 80ms, idle_timer to 5ms
# Commit: perf: adjust VM for better battery and fluidity balance

# --------------------------------------------
# Wait for full boot
# --------------------------------------------
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 3
done

# --------------------------------------------
# 1. FULL RESET (stock values)
# --------------------------------------------
for p in persist.vendor.power.dfps.level ro.vendor.display.default_fps \
         persist.sys.sf.high_fps sys.use_fifo_ui debug.gr.num_buffers \
         vendor.display.enable_bypass_version debug.renderengine.backend \
         debug.cpurend.disable debug.performance.tuning persist.sys.composition.type \
         ro.hwui.texture_cache_size ro.hwui.layer_cache_size ro.hwui.r_buffer_cache_size ro.hwui.path_cache_size; do
    setprop "$p" ""
done

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

echo "msm-adreno-tz" > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
echo "0" > /sys/class/kgsl/kgsl-3d0/max_gpuclk 2>/dev/null
echo "100" > /proc/sys/vm/swappiness 2>/dev/null
echo "100" > /proc/sys/vm/vfs_cache_pressure 2>/dev/null

start thermal-engine 2>/dev/null
start thermal-manager 2>/dev/null
pm enable com.xiaomi.joyose 2>/dev/null

# --------------------------------------------
# 2. GLOBAL OPTIMIZATIONS
# --------------------------------------------
settings put global wifi_scan_always_enabled 0
settings put global ble_scan_always_enabled 0

mount -o remount,noatime,nodiratime /data 2>/dev/null
mount -o remount,noatime,nodiratime /cache 2>/dev/null

echo "1" > /proc/sys/kernel/yama/ptrace_scope 2>/dev/null
echo "2" > /proc/sys/kernel/randomize_va_space 2>/dev/null
echo "1 1 1 1" > /proc/sys/kernel/printk 2>/dev/null
echo "512" > /proc/sys/kernel/random/read_wakeup_threshold 2>/dev/null
echo "128" > /proc/sys/kernel/random/write_wakeup_threshold 2>/dev/null

settings put global device_idle_constants "min_time_to_alarm=7200000,inactivity_to_reset=60000,maintenance_min_lazy_time=300000,max_temp_app_allowlist_time=30000,motion_inactive_timeout=60000,notification_whitelist_time=30000,sensing_timeout=30000"

echo "netmgr_wl" > /sys/power/wake_lock 2>/dev/null
echo "qcom_rx_wakelock" > /sys/power/wake_lock 2>/dev/null
echo "wlan_wake" > /sys/power/wake_lock 2>/dev/null
echo "ipa_ws" > /sys/power/wake_lock 2>/dev/null
echo "qcom_tx_wakelock" > /sys/power/wake_lock 2>/dev/null
echo "N" > /sys/module/lpm_levels/parameters/sleep_disabled 2>/dev/null

for queue in /sys/block/*/queue/scheduler; do
    echo "kyber" > "$queue" 2>/dev/null || echo "mq-deadline" > "$queue" 2>/dev/null
    echo "2048" > "${queue%/*}/queue/read_ahead_kb" 2>/dev/null
    echo "64" > "${queue%/*}/queue/nr_requests" 2>/dev/null
    echo "0" > "${queue%/*}/queue/iostats" 2>/dev/null
    echo "0" > "${queue%/*}/queue/rotational" 2>/dev/null
done

echo "bbr" > /proc/sys/net/ipv4/tcp_congestion_control 2>/dev/null
echo "1" > /proc/sys/net/ipv4/tcp_ecn 2>/dev/null
echo "1" > /proc/sys/net/ipv4/tcp_sack 2>/dev/null
echo "1" > /proc/sys/net/ipv4/tcp_timestamps 2>/dev/null
echo "16384" > /proc/sys/net/ipv4/tcp_notsent_lowat 2>/dev/null
tc qdisc add dev wlan0 root fq 2>/dev/null
tc qdisc add dev rmnet_data0 root fq 2>/dev/null
echo "8388608" > /proc/sys/net/core/rmem_max 2>/dev/null
echo "8388608" > /proc/sys/net/core/wmem_max 2>/dev/null
setprop net.dns1 1.1.1.1
setprop net.dns2 8.8.8.8

echo "18432,23040,27648,32256,55296,80640" > /sys/module/lowmemorykiller/parameters/adj 2>/dev/null
echo "512,768,1024,1280,2048,3072" > /sys/module/lowmemorykiller/parameters/minfree 2>/dev/null

pid_kswapd=$(pgrep kswapd)
[ -n "$pid_kswapd" ] && ionice -c 3 -p "$pid_kswapd" 2>/dev/null

echo "0" > /proc/sys/vm/page-cluster 2>/dev/null

[ -d "/dev/stune/top-app" ] && {
    echo "1" > /dev/stune/top-app/schedtune.boost 2>/dev/null
    echo "1" > /dev/stune/top-app/schedtune.prefer_idle 2>/dev/null
}
[ -d "/dev/stune/foreground" ] && {
    echo "1" > /dev/stune/foreground/schedtune.boost 2>/dev/null
    echo "1" > /dev/stune/foreground/schedtune.prefer_idle 2>/dev/null
}
[ -d "/dev/stune/background" ] && {
    echo "0" > /dev/stune/background/schedtune.boost 2>/dev/null
}

# --------------------------------------------
# 3. PANEL: 60Hz LOCKED + NIGHT MODE OFF (v3)
# --------------------------------------------
setprop persist.vendor.power.dfps.level 0
setprop ro.vendor.display.default_fps 60
setprop persist.sys.sf.high_fps 0
setprop persist.vendor.night.mode 0

PANEL_PATH="/sys/devices/platform/soc/soc:qcom,mdss_mdp"
if [ -d "$PANEL_PATH" ]; then
    echo "60" > "$PANEL_PATH/dynamic_fps" 2>/dev/null
    echo "60" > "$PANEL_PATH/min_fps" 2>/dev/null
    echo "60" > "$PANEL_PATH/max_fps" 2>/dev/null
    echo "1" > "$PANEL_PATH/psr_mode" 2>/dev/null
    [ -f "$PANEL_PATH/low_power_mode" ] && echo "1" > "$PANEL_PATH/low_power_mode" 2>/dev/null
    [ -f "$PANEL_PATH/backlight_dimmer" ] && echo "1" > "$PANEL_PATH/backlight_dimmer" 2>/dev/null
fi

# --------------------------------------------
# 4. CPU BOOST (80ms para máxima fluidez)
# --------------------------------------------
BOOST_PATH="/sys/module/cpu_boost/parameters"
if [ -d "$BOOST_PATH" ]; then
    echo "1036800 1804800" > "$BOOST_PATH/input_boost_freq" 2>/dev/null
    echo "80" > "$BOOST_PATH/input_boost_ms" 2>/dev/null
fi

# --------------------------------------------
# 5. SCHEDUTIL (aggressive + rate_limit_us)
# --------------------------------------------
for gov in /sys/devices/system/cpu/cpufreq/policy*/schedutil; do
    [ -d "$gov" ] && {
        echo "0" > "$gov/up_rate_limit_us" 2>/dev/null
        echo "30" > "$gov/down_rate_limit_us" 2>/dev/null
        echo "1" > "$gov/rate_limit_us" 2>/dev/null
        echo "1" > "$gov/pl" 2>/dev/null
    }
done

# --------------------------------------------
# 6. CPU FREQUENCIES (Balanced)
# --------------------------------------------
echo "300000" > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq 2>/dev/null
echo "1401600" > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq 2>/dev/null
echo "300000" > /sys/devices/system/cpu/cpufreq/policy4/scaling_min_freq 2>/dev/null
echo "1804800" > /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq 2>/dev/null
echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy0/scaling_governor 2>/dev/null
echo "schedutil" > /sys/devices/system/cpu/cpufreq/policy4/scaling_governor 2>/dev/null

# --------------------------------------------
# 7. CPU DEEP SLEEP (v3)
# --------------------------------------------
if [ -d "/sys/devices/system/cpu/cpuidle" ]; then
    echo "1" > /sys/devices/system/cpu/cpuidle/low_power_state 2>/dev/null
fi

# --------------------------------------------
# 8. POWER HAL (v3)
# --------------------------------------------
setprop vendor.powerhal.init 1 2>/dev/null
setprop ro.vendor.power.config 1 2>/dev/null

# --------------------------------------------
# 9. LOCATION INTERVAL + AUTO RETRIEVAL (v3)
# --------------------------------------------
setprop persist.sys.background_location_interval 1800 2>/dev/null
setprop ro.config.auto_retrieval false 2>/dev/null

# --------------------------------------------
# 10. ADRENO 618 GPU TUNING (idle_timer=5ms)
# --------------------------------------------
echo "msm-adreno-tz" > /sys/class/kgsl/kgsl-3d0/devfreq/governor 2>/dev/null
echo "650000000" > /sys/class/kgsl/kgsl-3d0/max_gpuclk 2>/dev/null
echo "300000000" > /sys/class/kgsl/kgsl-3d0/min_gpuclk 2>/dev/null
echo "5" > /sys/class/kgsl/kgsl-3d0/idle_timer 2>/dev/null
echo "0" > /sys/class/kgsl/kgsl-3d0/force_no_nap 2>/dev/null
echo "1" > /sys/class/kgsl/kgsl-3d0/throttling 2>/dev/null
echo "100" > /sys/class/kgsl/kgsl-3d0/bus_split 2>/dev/null

# --------------------------------------------
# 11. VIRTUAL MEMORY (battery + fluidity balance)
# --------------------------------------------
echo "50" > /proc/sys/vm/swappiness 2>/dev/null
echo "80" > /proc/sys/vm/vfs_cache_pressure 2>/dev/null
echo "20" > /proc/sys/vm/dirty_ratio 2>/dev/null
echo "10" > /proc/sys/vm/dirty_background_ratio 2>/dev/null
echo "500" > /proc/sys/vm/dirty_writeback_centisecs 2>/dev/null
echo "500" > /proc/sys/vm/dirty_expire_centisecs 2>/dev/null

# --------------------------------------------
# 12. HWUI CACHES (más grandes para fluidez)
# --------------------------------------------
setprop ro.hwui.texture_cache_size 256
setprop ro.hwui.layer_cache_size 192
setprop ro.hwui.r_buffer_cache_size 48
setprop ro.hwui.path_cache_size 96

# --------------------------------------------
# 13. GOOGLE TAMER (extendido con v3)
# --------------------------------------------
settings put global stats_collection 0 2>/dev/null
settings put global usage_stats_collection 0 2>/dev/null
pm disable-user --user 0 com.google.android.gms/.chimera.GmsIntentOperationService 2>/dev/null
pm disable-user --user 0 com.google.android.gms/.auth.be.proximity.authorization.userpresence.UserPresenceService 2>/dev/null
pm disable-user --user 0 com.google.android.gms/.ads.AdRequestBrokerService 2>/dev/null
pm disable-user --user 0 com.google.firebase 2>/dev/null
pm disable-user --user 0 com.google.android.apps.googleassistant 2>/dev/null
pm disable-user --user 0 com.android.hotwordenrollment.okgoogle 2>/dev/null
pm disable-user --user 0 com.google.android.gms/.analytics.AnalyticsService 2>/dev/null
pm disable-user --user 0 com.google.android.gms/.analytics.AnalyticsTaskService 2>/dev/null
pm disable-user --user 0 com.google.android.gms/.measurement.AppMeasurementService 2>/dev/null
pm disable-user --user 0 com.google.android.feedback 2>/dev/null

# --------------------------------------------
# 14. DEBLOAT (lista completa)
# --------------------------------------------
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
    pm disable-user --user 0 "$pkg" 2>/dev/null
done

# --------------------------------------------
# 15. HYPEROS 4
# --------------------------------------------
if getprop ro.miui.ui.version.name | grep -qE "V816|V817|V818"; then
    setprop vendor.display.enable_bypass_version 1
    setprop debug.renderengine.backend gles
    pm enable com.xiaomi.joyose 2>/dev/null
fi

# --------------------------------------------
# 16. THERMAL ENABLED
# --------------------------------------------
start thermal-engine 2>/dev/null
start thermal-manager 2>/dev/null

# --------------------------------------------
# 17. GRAPHICS PROPS
# --------------------------------------------
setprop debug.cpurend.disable 1
setprop debug.performance.tuning 1
setprop persist.sys.composition.type gpu
setprop persist.sys.powerhal.interactive 1
setprop sys.use_fifo_ui 1
setprop debug.gr.num_buffers 3

log -p i -t Apex_v4 "Apex Render v4.6.1 loaded - Fusion v3 + v4.6 + extra tweaks"