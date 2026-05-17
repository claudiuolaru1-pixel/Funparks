const fs = require("fs");
let app = fs.readFileSync("lib/app_state.dart", "utf8").replace(/\r\n/g, "\n");

// 1. Add _iosGuestChecked flag to avoid repeated SharedPreferences calls
app = app.replace(
  "  bool _iosSignedIn = false;",
  "  bool _iosSignedIn = false;\n  bool _iosGuestChecked = false;"
);

// 2. Add _iosGuestChecked guard in _ensureBootLoaded
app = app.replace(
  "    if (Platform.isIOS && !_iosSignedIn) {",
  "    if (Platform.isIOS && !_iosSignedIn && !_iosGuestChecked) {\n      _iosGuestChecked = true;"
);

// 3. Eagerly load My Day at boot time
app = app.replace(
  "    if (_bootLoaded) return;\n    _bootLoaded = true;",
  "    if (_bootLoaded) return;\n    _bootLoaded = true;\n    await _ensureMyDayLoaded();"
);

fs.writeFileSync("lib/app_state.dart", app, "utf8");
console.log("_iosGuestChecked:", app.includes("_iosGuestChecked = false;"));
console.log("guest guard:", app.includes("!_iosGuestChecked) {\n      _iosGuestChecked = true;"));
console.log("eager load:", app.includes("_bootLoaded = true;\n    await _ensureMyDayLoaded();"));