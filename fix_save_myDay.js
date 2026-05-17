const fs = require("fs");
let app = fs.readFileSync("lib/app_state.dart", "utf8").replace(/\r\n/g, "\n");

// Fix _saveMyDayUnified - guard Firestore call properly on iOS
app = app.replace(
  "    if (isLoggedIn) {\n      await _userDoc(_user!.uid).set({\n        'my_day': _myDayItems.map((i) => i.toJson()).toList(),\n        'updated_at': FieldValue.serverTimestamp(),\n      }, SetOptions(merge: true));\n    }",
  "    if (isLoggedIn && _user != null && !Platform.isIOS) {\n      await _userDoc(_user!.uid).set({\n        'my_day': _myDayItems.map((i) => i.toJson()).toList(),\n        'updated_at': FieldValue.serverTimestamp(),\n      }, SetOptions(merge: true));\n    }"
);

fs.writeFileSync("lib/app_state.dart", app, "utf8");
console.log("fixed:", app.includes("_user != null && !Platform.isIOS"));