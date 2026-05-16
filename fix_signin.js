const fs=require('fs');
let c=fs.readFileSync('lib/screens/sign_in_screen.dart','utf8');

// 1. Move controllers to late declarations
c=c.replace('  final _loginEmailCtrl = TextEditingController();','  late TextEditingController _loginEmailCtrl;');
c=c.replace('  final _loginPassCtrl = TextEditingController();','  late TextEditingController _loginPassCtrl;');
c=c.replace('  final _regEmailCtrl = TextEditingController();','  late TextEditingController _regEmailCtrl;');
c=c.replace('  final _regPassCtrl = TextEditingController();','  late TextEditingController _regPassCtrl;');
c=c.replace('  final _regConfirmCtrl = TextEditingController();','  late TextEditingController _regConfirmCtrl;');

// 2. Initialize them in initState
c=c.replace(
  '    _tabs = TabController(',
  `    _loginEmailCtrl = TextEditingController();
    _loginPassCtrl = TextEditingController();
    _regEmailCtrl = TextEditingController();
    _regPassCtrl = TextEditingController();
    _regConfirmCtrl = TextEditingController();
    _tabs = TabController(`
);

// 3. Add general catch to _login() - it only has FirebaseAuthException catch
c=c.replace(
  `    } on FirebaseAuthException catch (e) {
      setState(() => _loginError = _authMessage(e.code));
    } finally {
      if (mounted) setState(() => _loginBusy = false);`,
  `    } on FirebaseAuthException catch (e) {
      setState(() => _loginError = _authMessage(e.code));
    } catch (e) {
      setState(() => _loginError = 'Sign-in error: \${e.toString()}');
    } finally {
      if (mounted) setState(() => _loginBusy = false);`
);

fs.writeFileSync('lib/screens/sign_in_screen.dart',c,'utf8');
console.log('Fixed. Controllers late:', c.includes('late TextEditingController _loginEmailCtrl'));
console.log('General catch added:', c.includes("Sign-in error:"));