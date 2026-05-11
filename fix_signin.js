const fs=require('fs');
let c=fs.readFileSync('lib/screens/sign_in_screen.dart','utf8');

// Replace field initializers with nullable declarations
c=c.replace(
  `  final _loginEmailCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();
  bool _loginPassVisible = false;
  String? _loginError;
  bool _loginBusy = false;

  final _regEmailCtrl = TextEditingController();
  final _regPassCtrl = TextEditingController();
  final _regConfirmCtrl = TextEditingController();
  bool _regPassVisible = false;
  String? _regError;
  bool _regBusy = false;`,
  `  TextEditingController? _loginEmailCtrl;
  TextEditingController? _loginPassCtrl;
  bool _loginPassVisible = false;
  String? _loginError;
  bool _loginBusy = false;

  TextEditingController? _regEmailCtrl;
  TextEditingController? _regPassCtrl;
  TextEditingController? _regConfirmCtrl;
  bool _regPassVisible = false;
  String? _regError;
  bool _regBusy = false;`
);

// Initialize in initState
c=c.replace(
  `    _tabs = TabController(
        length: 2, vsync: this, initialIndex: widget.startOnRegister ? 1 : 0);`,
  `    _tabs = TabController(
        length: 2, vsync: this, initialIndex: widget.startOnRegister ? 1 : 0);
    try {
      _loginEmailCtrl = TextEditingController();
      _loginPassCtrl = TextEditingController();
      _regEmailCtrl = TextEditingController();
      _regPassCtrl = TextEditingController();
      _regConfirmCtrl = TextEditingController();
    } catch (_) {}`
);

// Fix dispose
c=c.replace(
  `    _tabs.dispose();
    _loginEmailCtrl.dispose();
    _loginPassCtrl.dispose();
    _regEmailCtrl.dispose();
    _regPassCtrl.dispose();
    _regConfirmCtrl.dispose();`,
  `    _tabs.dispose();
    _loginEmailCtrl?.dispose();
    _loginPassCtrl?.dispose();
    _regEmailCtrl?.dispose();
    _regPassCtrl?.dispose();
    _regConfirmCtrl?.dispose();`
);

// Fix all usages - add ? to controller references in methods
c=c.replace(/_loginEmailCtrl\.text/g,'_loginEmailCtrl?.text??\'\'');
c=c.replace(/_loginPassCtrl\.text/g,'_loginPassCtrl?.text??\'\'');
c=c.replace(/_regEmailCtrl\.text/g,'_regEmailCtrl?.text??\'\'');
c=c.replace(/_regPassCtrl\.text/g,'_regPassCtrl?.text??\'\'');
c=c.replace(/_regConfirmCtrl\.text/g,'_regConfirmCtrl?.text??\'\'');

// Fix controller params in build methods
c=c.replace('ctrl: _loginEmailCtrl,','ctrl: _loginEmailCtrl??TextEditingController(),');
c=c.replace('ctrl: _loginPassCtrl,','ctrl: _loginPassCtrl??TextEditingController(),');
c=c.replace('ctrl: _regEmailCtrl,','ctrl: _regEmailCtrl??TextEditingController(),');
c=c.replace(/ctrl: _regPassCtrl,/g,'ctrl: _regPassCtrl??TextEditingController(),');
c=c.replace('ctrl: _regConfirmCtrl,','ctrl: _regConfirmCtrl??TextEditingController(),');

fs.writeFileSync('lib/screens/sign_in_screen.dart',c,'utf8');
console.log('Fixed controllers in initState');