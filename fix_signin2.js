const fs=require('fs');
let c=fs.readFileSync('lib/screens/sign_in_screen.dart','utf8');

// Add general catch to _login() using regex (handles CRLF/LF)
c=c.replace(
  /(\} on FirebaseAuthException catch \(e\) \{\s*setState\(\(\) => _loginError = _authMessage\(e\.code\)\);\s*\})\s*finally\s*\{\s*if \(mounted\) setState\(\(\) => _loginBusy = false\);/,
  `} on FirebaseAuthException catch (e) {
      setState(() => _loginError = _authMessage(e.code));
    } catch (e) {
      setState(() => _loginError = 'Error: ' + e.toString());
    } finally {
      if (mounted) setState(() => _loginBusy = false);`
);

fs.writeFileSync('lib/screens/sign_in_screen.dart',c,'utf8');
console.log('General catch added:', c.includes("} catch (e) {") );