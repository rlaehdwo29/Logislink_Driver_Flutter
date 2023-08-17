import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../common/style_theme.dart';
import 'login_page.dart';

class BridgePage extends StatefulWidget {
  const BridgePage({Key? key}) : super(key: key);

  @override
  _BridgePageState createState() => _BridgePageState();
}

class _BridgePageState extends State<BridgePage> {
  //UserInfoService loginService;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      /*try {
        final dir = await getApplicationDocumentsDirectory();
        var dirSChk = Directory('${dir.path}/sample/');
        if (await dirSChk.exists()) {
          dirSChk.deleteSync(recursive: true);
        }
        loginService = context.read<UserInfoService>();
        var userDb = LocalDbProvider();
        UserModel _user = await userDb.getUser();
        await loginService.getVersion();
        if (_user != null) {
          if (_user.loginKeep == "Y") {
            await loginService.refreshToken().then((value) {
              if (value.status == "0" || value.status == "888") {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => MainPage()),
                        (route) => false);
              } else {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (BuildContext context) => const LoginPage()),
                        (route) => false);
              }
            });
          } else {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (BuildContext context) => const LoginPage()),
                    (route) => false);
          }
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
                  (route) => false);
        }
      } catch (e) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
                (route) => false);
      }*/
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (BuildContext context) => const LoginPage()),
              (route) => false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: styleWhiteCol,
      alignment: Alignment.center,
      child: CircularProgressIndicator(
        backgroundColor: styleGreyCol1,
      ),
    );
  }
}
