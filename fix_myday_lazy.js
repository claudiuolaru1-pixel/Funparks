const fs = require("fs");
let app = fs.readFileSync("lib/app_state.dart", "utf8").replace(/\r\n/g, "\n");

app = app.replace(
  "  List<MyDayItem> get myDayItems => List.unmodifiable(_myDayItems);\n  int get myDayTotalCount => _myDayItems.length;\n  int get myDayTotalMinutes =>\n      _myDayItems.fold(0, (sum, i) => sum + i.estimatedMinutes);\n  bool isInMyDayUnified(String id) => _myDayItems.any((i) => i.id == id);",
  "  List<MyDayItem> get myDayItems {\n    if (!_myDayUnifiedLoaded) _ensureMyDayLoaded().then((_) => notifyListeners());\n    return List.unmodifiable(_myDayItems);\n  }\n  int get myDayTotalCount {\n    if (!_myDayUnifiedLoaded) _ensureMyDayLoaded().then((_) => notifyListeners());\n    return _myDayItems.length;\n  }\n  int get myDayTotalMinutes =>\n      _myDayItems.fold(0, (sum, i) => sum + i.estimatedMinutes);\n  bool isInMyDayUnified(String id) {\n    if (!_myDayUnifiedLoaded) _ensureMyDayLoaded().then((_) => notifyListeners());\n    return _myDayItems.any((i) => i.id == id);\n  }"
);

fs.writeFileSync("lib/app_state.dart", app, "utf8");
console.log("myDayTotalCount lazy:", app.includes("_myDayUnifiedLoaded) _ensureMyDayLoaded().then((_) => notifyListeners());\n    return _myDayItems.length"));
console.log("isInMyDayUnified lazy:", app.includes("_myDayUnifiedLoaded) _ensureMyDayLoaded().then((_) => notifyListeners());\n    return _myDayItems.any"));