const fs=require('fs');
let si=fs.readFileSync('lib/screens/sign_in_screen.dart','utf8').replace(/\r\n/g,'\n');
si=si.replace("import '../ios_auth_helper.dart';","import '../ios_auth_helper.dart';\nimport 'package:provider/provider.dart';\nimport '../app_state.dart';");
si=si.replace("      if (Platform.isIOS) {\n        await IOSAuthHelper.signIn(email, pass);\n      } else {","      if (Platform.isIOS) {\n        final uid = await IOSAuthHelper.signIn(email, pass);\n        if (mounted) Provider.of<AppState>(context, listen: false).onIOSSignIn(uid, email);\n      } else {");
si=si.replace("      if (Platform.isIOS) {\n        await IOSAuthHelper.register(email, pass);\n      } else {","      if (Platform.isIOS) {\n        final uid = await IOSAuthHelper.register(email, pass);\n        if (mounted) Provider.of<AppState>(context, listen: false).onIOSSignIn(uid, email);\n      } else {");
fs.writeFileSync('lib/screens/sign_in_screen.dart',si,'utf8');
console.log('ok:',si.includes('onIOSSignIn'));
