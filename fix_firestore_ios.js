const fs = require("fs");
let app = fs.readFileSync("lib/app_state.dart", "utf8").replace(/\r\n/g, "\n");

// Guard _syncFromFirestore
app = app.replace(
  "  Future<void> _syncFromFirestore(String uid) async {\n    try {",
  "  Future<void> _syncFromFirestore(String uid) async {\n    if (Platform.isIOS) return; // Firestore not available on iOS 26\n    try {"
);

// Guard _pushToFirestore
app = app.replace(
  "  Future<void> _pushToFirestore(String uid) async {\n    try {",
  "  Future<void> _pushToFirestore(String uid) async {\n    if (Platform.isIOS) return; // Firestore not available on iOS 26\n    try {"
);

fs.writeFileSync("lib/app_state.dart", app, "utf8");
console.log("_syncFromFirestore guarded:", app.includes("_syncFromFirestore(String uid) async {\n    if (Platform.isIOS)"));
console.log("_pushToFirestore guarded:", app.includes("_pushToFirestore(String uid) async {\n    if (Platform.isIOS)"));