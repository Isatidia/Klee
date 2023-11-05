import 'package:Klee/login/login.dart';
import 'package:flutter/material.dart';
import 'package:Klee/InformationPage/SettingsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Klee/InformationPage/ProfileInformationPage.dart';

//import 'package:shared_preferences/shared_preferences.dart';
class InformationPageBody extends StatelessWidget {
  const InformationPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    Future<String> getIdToken() async {
      SharedPreferences token = await SharedPreferences.getInstance();
      String? idToken = token.getString('TokenID');
      return idToken ?? '0';
    }

    return FutureBuilder<String>(
      future: getIdToken(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          String hello;
          String? loginState = snapshot.data;

          if (loginState != '0') {
            hello = '你好';
          } else {
            hello = '请先登录';
          }

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              title: Text(
                "$hello",
                style: TextStyle(
                  color: Color.fromARGB(150, 40, 40, 40),
                  //fontFamily: "font2",
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: InformationPage(),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class InformationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          ProfilePic(),
          SizedBox(height: 20),
          ProfileMenu(
            text: "用户信息",
            icon: Icons.account_box,
            press: () => {
              determinePageToNavigate().then((page) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => page,
                ));
              })
            },
          ),
          ProfileMenu(
            text: "设置",
            icon: Icons.settings_rounded,
            press: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => SettingsPage(),
              ));
            },
          ),
          ProfileMenu(
            text: "登出",
            icon: Icons.exit_to_app,
            press: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('确认登出？'),
                    content: Text('您确定要登出吗？'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 关闭弹窗
                        },
                        child: Text('取消'),
                      ),
                      TextButton(
                        onPressed: () {
                          SelectAllInformation();
                          // 记得写处理登出逻辑
                          //删除所有信息，单独用一个函数
                          Navigator.of(context).pop(); // 关闭弹窗
                        },
                        child: Text('确认'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    required this.text,
    required this.icon,
    this.press,
    this.textColor = const Color.fromARGB(200, 0, 0, 0),
    this.iconColor = const Color.fromARGB(200, 0, 0, 0),
  }) : super(key: key);

  final String text;
  final IconData icon;
  final VoidCallback? press;
  final Color textColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      child: TextButton(
        style: TextButton.styleFrom(
          padding: EdgeInsets.all(23),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Color.fromARGB(40, 179, 225, 236),
        ),
        onPressed: press,
        child: Row(
          children: [
            Icon(
              icon,
              size: 28,
              color: iconColor, // 设置图标颜色
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: textColor), // 设置文字颜色
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color.fromARGB(143, 40, 40, 40),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePic extends StatelessWidget {
  const ProfilePic({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 115,
      width: 115,
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            backgroundColor: Color.fromARGB(40, 201, 201, 201),
            backgroundImage: AssetImage('images/100.png'),
          ),
          Positioned(
            right: -10,
            bottom: -2,
            child: SizedBox(
              height: 40,
              width: 40,
              child: TextButton(
                style: TextButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: BorderSide(color: Colors.white),
                  ),
                  backgroundColor: Color(0xFFF5F6F9),
                ),
                onPressed: () {},
                child: Icon(
                  Icons.camera_alt,
                  color: Color.fromARGB(182, 0, 0, 0),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

//删除所有用户数据
void SelectAllInformation() async {
  final SharedPreferences Token = await SharedPreferences.getInstance();
  await Token.remove('TokenID');
  await Token.remove('TokenCookie');
  //await Token.remove('TokenCookie');
  //await Token.remove('TokenCookie');
  print('删除成功');
}

//检测用户状态
Future<Widget> determinePageToNavigate() async {
  Future<String> getIdToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? idToken = token.getString('TokenID');
    return idToken ?? '0';
  }

  String loginState = await getIdToken();

  if (loginState != '0') {
    return ProfileInformationPage();
  } else {
    return LoginPage();
  }
}
