const fs = require("fs");

// 1. Add deleteAccount method to app_state.dart
let app = fs.readFileSync("lib/app_state.dart", "utf8").replace(/\r\n/g, "\n");
app = app.replace(
  "  void onAndroidSignIn(dynamic user) {",
  "  Future<void> deleteAccount() async {\n    if (Platform.isIOS) {\n      final prefs = await SharedPreferences.getInstance();\n      await prefs.clear();\n      _iosSignedIn = false;\n      _iosUserEmail = null;\n      _iosGuestChecked = false;\n      _myDayItems.clear();\n      _favoriteParkIds.clear();\n      notifyListeners();\n    } else {\n      final user = FirebaseAuth.instance.currentUser;\n      if (user != null) {\n        try { await _userDoc(user.uid).delete(); } catch (_) {}\n        await user.delete();\n      }\n      final prefs = await SharedPreferences.getInstance();\n      await prefs.clear();\n      _user = null;\n      _myDayItems.clear();\n      _favoriteParkIds.clear();\n      notifyListeners();\n    }\n  }\n\n  void onAndroidSignIn(dynamic user) {"
);
fs.writeFileSync("lib/app_state.dart", app, "utf8");
console.log("deleteAccount added:", app.includes("Future<void> deleteAccount()"));

// 2. Add Delete Account tile to settings_screen.dart
let si = fs.readFileSync("lib/screens/settings_screen.dart", "utf8").replace(/\r\n/g, "\n");
si = si.replace(
  "            const Divider(),\n          ] else ...[",
  "            ListTile(\n              leading: const Icon(Icons.delete_forever, color: Colors.red),\n              title: const Text('Delete Account',\n                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),\n              subtitle: const Text('Permanently delete your account and data'),\n              onTap: () async {\n                final confirm = await showDialog<bool>(\n                  context: context,\n                  builder: (_) => AlertDialog(\n                    title: const Text('Delete Account'),\n                    content: const Text('This will permanently delete your account and all your data. This cannot be undone.'),\n                    actions: [\n                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),\n                      FilledButton(\n                          onPressed: () => Navigator.pop(context, true),\n                          style: FilledButton.styleFrom(backgroundColor: Colors.red),\n                          child: const Text('Delete')),\n                    ],\n                  ),\n                );\n                if (confirm == true && context.mounted) {\n                  try {\n                    await context.read<AppState>().deleteAccount();\n                    if (context.mounted) Navigator.of(context).pushReplacementNamed(\'/start\');\n                  } catch (_) {\n                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(\n                      const SnackBar(content: Text(\'Please sign in again to delete your account.\')));\n                  }\n                }\n              },\n            ),\n            const Divider(),\n          ] else ...["
);
fs.writeFileSync("lib/screens/settings_screen.dart", si, "utf8");
console.log("Delete Account tile added:", si.includes("Delete Account"));