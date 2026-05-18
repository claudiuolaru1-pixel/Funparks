const fs = require("fs");
let m = fs.readFileSync("lib/main.dart", "utf8").replace(/\r\n/g, "\n");
m = m.replace(
  "  if (!_mapsRendererInitialized &&\n      !kIsWeb &&\n      defaultTargetPlatform == TargetPlatform.android) {\n    final platform = GoogleMapsFlutterPlatform.instance;\n    if (platform is GoogleMapsFlutterAndroid) {\n      await platform.initializeWithRenderer(AndroidMapRenderer.legacy);\n      platform.useAndroidViewSurface = true;\n      _mapsRendererInitialized = true;\n    }\n  }",
  "  if (!_mapsRendererInitialized &&\n      !kIsWeb &&\n      defaultTargetPlatform == TargetPlatform.android) {\n    final platform = GoogleMapsFlutterPlatform.instance;\n    if (platform is GoogleMapsFlutterAndroid) {\n      await platform.initializeWithRenderer(AndroidMapRenderer.latest);\n      _mapsRendererInitialized = true;\n    }\n  }"
);
fs.writeFileSync("lib/main.dart", m, "utf8");
console.log("renderer updated:", m.includes("AndroidMapRenderer.latest"));