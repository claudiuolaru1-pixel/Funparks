const fs=require('fs');
let c=fs.readFileSync('lib/screens/sign_in_screen.dart','utf8');

// Add catch-all to _login
c=c.replace(
  `    } on FirebaseAuthException catch (e) {
      setState(() => _loginError = _authMessage(e.code));
    } finally {
      if (mounted) setState(() => _loginBusy = false);
    }
  }

  Future<void> _register`,
  `    } on FirebaseAuthException catch (e) {
      setState(() => _loginError = _authMessage(e.code));
    } catch (e) {
      setState(() => _loginError = 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _loginBusy = false);
    }
  }

  Future<void> _register`
);

fs.writeFileSync('lib/screens/sign_in_screen.dart',c,'utf8');
console.log('Fixed:', c.includes("Error: \${e.toString()}") ? 'YES' : 'NO');