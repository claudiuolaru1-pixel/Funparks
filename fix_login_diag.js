const fs = require("fs");
let si = fs.readFileSync("lib/screens/sign_in_screen.dart", "utf8").replace(/\r\n/g, "\n");
// Show actual FirebaseAuthException code instead of _authMessage
si = si.replace(
  "    } on FirebaseAuthException catch (e) {\n      setState(() => _loginError = _authMessage(e.code));",
  "    } on FirebaseAuthException catch (e) {\n      setState(() => _loginError = 'FAE:' + e.code + ' ' + (e.message ?? ''));"
);
fs.writeFileSync("lib/screens/sign_in_screen.dart", si, "utf8");
console.log("diag added:", si.includes("FAE:"));