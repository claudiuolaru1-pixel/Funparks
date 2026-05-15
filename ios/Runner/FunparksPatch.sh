#!/bin/sh
PLUGIN=$(find "$HOME/.pub-cache" -path "*/firebase_core*/FLTFirebaseCorePlugin.m" 2>/dev/null | head -1)
echo "[Funparks] Plugin: $PLUGIN"
[ -z "$PLUGIN" ] && exit 0
# Fix broken patches (try without @) - safe to run multiple times
perl -i -pe 's/(?<!\@)try \{ \[FIRApp configureWithName:/\@try { [FIRApp configureWithName:/;s/\} catch \(NSException \*__e\)/} \@catch (NSException *__e)/;' "$PLUGIN"
# Apply fresh patch if not correctly patched yet
if ! grep -qF "@try { [FIRApp configureWithName" "$PLUGIN"; then
  perl -i -0pe 's/(\[FIRApp configureWithName:[^\]]+\];)/\@try { $1 } \@catch (NSException *__e) { NSLog(\@"FunparksPatch"); }/g' "$PLUGIN"
  echo "[Funparks] Patched!"
else
  echo "[Funparks] Already correctly patched"
fi