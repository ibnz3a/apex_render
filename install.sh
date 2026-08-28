#!/system/bin/sh
SKIPMOUNT=false
PROPFILE=true
POSTFSDATA=true
LATESTARTSERVICE=true
SKIPUNZIP=1

ui_print " "
ui_print "⚡ Apex Render v4.5 ⚡"
ui_print "   by Ibanez ★"
ui_print " "
ui_print "► HyperOS 4 · sweet"
ui_print "► 60Hz locked · Battery extreme"
ui_print "► Adreno 618 tuned · Network optimized"
ui_print " "

unzip -o "$ZIPFILE" -d "$MODPATH" >&2
  
rm banner.png README.md CHANGELOG.md LICENSE
cp -f $MODPATH/common/src/banner.png $MODPATH/banner.png 
cp -f $MODPATH/common/scripts/service.sh $MODPATH/service.sh
cp -f $MODPATH/common/scripts/post-fs-data.sh $MODPATH/post-fs-data.sh
cp -f $MODPATH/common/surfaceflinger/arm64 $MODPATH/SurfaceFlinger
rm -rf $MODPATH/common

BACKUP="$MODPATH/persist_backup.prop"
: > "$BACKUP"
for prop in $(grep -E '^persist\.' "$MODPATH/system.prop" | tr -d '\r' | cut -d= -f1 | sort -u); do
  val=$(resetprop "$prop" 2>/dev/null)
  [ -n "$val" ] && echo "$prop=$val" >> "$BACKUP"
done

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm $MODPATH/service.sh 0 0 0777
  set_perm $MODPATH/post-fs-data.sh 0 0 0777
  set_perm $MODPATH/SurfaceFlinger 0 0 0777
}

set_permissions

ui_print "  Installation complete."
ui_print "   Reboot to activate."
ui_print " "