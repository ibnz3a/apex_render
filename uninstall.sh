#!/system/bin/sh

# Apply a backup before uninstalling
MODDIR=${0%/*}
BACKUP="$MODDIR/persist_backup.prop"
PROPLIST=$(grep -E '^persist\.' "$MODDIR/system.prop" 2>/dev/null | tr -d '\r' | cut -d= -f1 | sort -u)

for prop in $PROPLIST; do
  orig=$(grep "^$prop=" "$BACKUP" 2>/dev/null | cut -d= -f2-)
  if [ -n "$orig" ]; then
    resetprop -p "$prop" "$orig" 2>/dev/null
  else
    resetprop --delete "$prop" 2>/dev/null
  fi
done

# Enable Google services
pm enable com.google.android.gms/.chimera.GmsIntentOperationService 2>/dev/null
pm enable com.google.android.apps.googleassistant 2>/dev/null
pm enable com.android.hotwordenrollment.okgoogle 2>/dev/null
pm enable com.google.android.gms/.analytics.AnalyticsService 2>/dev/null
pm enable com.google.android.gms/.analytics.AnalyticsTaskService 2>/dev/null
pm enable com.google.android.gms/.measurement.AppMeasurementService 2>/dev/null
pm enable com.google.android.feedback 2>/dev/null

# Enable Xiaomi services
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
    com.miui.translation.kingsoft com.miui.translationservice com.xiaomi.joyose; do
    pm enable "$pkg" 2>/dev/null
done

# Delete module
log -p i -t apex_render "Apex Render has been uninstalled."
rm -rf /adb/modules/apex_render