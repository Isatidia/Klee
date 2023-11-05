import 'package:Klee/HomePageTools/ActivityPage.dart';
import 'package:Klee/login/login.dart';
import 'package:flutter/material.dart';
import 'package:Klee/HomePageTools/DataPage.dart';
import 'package:Klee/HomePageTools/PayCode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          '首页',
          style: TextStyle(
              color: Color.fromARGB(150, 40, 40, 40),
              //fontFamily: "font2",
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent, // 设置背景颜色为透明
        elevation: 0,
      ),
      body: MePage(),
    );
  }
}

//
//
class HomePageHello extends StatelessWidget {
  HomePageHello({super.key});
  String time() {
    var hour = DateTime.now().hour;

    if ((hour > 6) && (hour <= 9)) {
      return ('早上好!');
    } else if ((hour > 9) && (hour <= 11)) {
      return ('上午好!');
    } else if ((hour > 11) && (hour < 13)) {
      return ('中午好!');
    } else if ((hour >= 13) && (hour < 19)) {
      return ('下午好!');
    } else if ((hour >= 19) && (hour < 24)) {
      return ('晚上好!');
    } else {
      return ('熬夜吗?');
    }
  }

  @override
  Widget build(BuildContext context) {
    String timehello = time();
    return Container(
      padding: EdgeInsets.fromLTRB(50, 40, 50, 50),
      child: Text(
        '$timehello',
        style: TextStyle(
            fontFamily: "font2", fontSize: 40, fontWeight: FontWeight.w700),
      ),
    );
  }
}

//
class MePage extends StatelessWidget {
  const MePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HomePageHello(), //问候语在这
                Wrap(
                  children: [
                    MePageButton(
                      title: "付款码",
                      subTitle: "查看付款码",
                      icon: Icons.qr_code,
                      onTap: () {
                        goToPayCode().then((page) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => page,
                          ));
                        });
                      },
                    ),
                    MePageButton(
                      title: "课表",
                      subTitle: "看看今天上什么课？",
                      icon: Icons.calendar_month,
                      onTap: () {
                        goToTableEvents().then((page) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => page,
                          ));
                        });
                        //fetchData();
                      },
                      //onTap: () {},
                    ),
                    MePageButton(
                      title: "我的活动",
                      subTitle: "一键报名与签到",
                      icon: Icons.notifications_rounded,
                      onTap: () {
                        goToListactivity().then((page) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => page,
                          ));
                        });
                        //ActivityListTesting();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MePageButton extends StatefulWidget {
  const MePageButton(
      {required this.title,
      required this.subTitle,
      required this.icon,
      required this.onTap,
      super.key});

  final String title;
  final String subTitle;
  final IconData icon;
  final void Function() onTap;

  @override
  State<MePageButton> createState() => _MePageButtonState();
}

class _MePageButtonState extends State<MePageButton> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    double padding = 10.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 8, padding, 8),
      child: MouseRegion(
        onEnter: (event) => setState(() => hovering = true),
        onExit: (event) => setState(() => hovering = false),
        cursor: SystemMouseCursors.click,
        child: Listener(
          onPointerUp: (event) => setState(() => hovering = false),
          onPointerDown: (event) => setState(() => hovering = true),
          child: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(24)),
            onTap: widget.onTap,
            child: SizedBox(
              width: 600,
              height: 150,
              child: AnimatedContainer(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  color: hovering
                      ? Theme.of(context)
                          .colorScheme
                          .inversePrimary
                          .withAlpha(50)
                      : Color.fromARGB(155, 174, 205, 217).withAlpha(40),
                ),
                duration: const Duration(milliseconds: 300),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 8, 32, 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.title,
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.subTitle,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipPath(
                          clipper: MePageIconClipper(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: hovering
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.surface,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Icon(
                                widget.icon,
                                color: hovering
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MePageIconClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final r = size.width * 0.3; // 控制弧线的大小

    // 起始点
    path.moveTo(r, 0);

    // 上边弧线
    path.arcToPoint(
      Offset(size.width - r, 0),
      radius: Radius.circular(r * 2),
      clockwise: false,
    );

    // 右上角圆弧
    path.arcToPoint(
      Offset(size.width, r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // 右边弧线
    path.arcToPoint(
      Offset(size.width, size.height - r),
      radius: Radius.circular(r * 2),
      clockwise: false,
    );

    // 右下角圆弧
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // 下边弧线
    path.arcToPoint(
      Offset(r, size.height),
      radius: Radius.circular(r * 2),
      clockwise: false,
    );

    // 左下角圆弧
    path.arcToPoint(
      Offset(0, size.height - r),
      radius: Radius.circular(r),
      clockwise: true,
    );

    // 左边弧线
    path.arcToPoint(
      Offset(0, r),
      radius: Radius.circular(r * 2),
      clockwise: false,
    );

    // 左上角圆弧
    path.arcToPoint(
      Offset(r, 0),
      radius: Radius.circular(r),
      clockwise: true,
    );

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

//检测用户状态
Future<Widget> goToPayCode() async {
  Future<String> getIdToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? idToken = token.getString('TokenID');
    return idToken ?? '0';
  }

  String loginState = await getIdToken();

  if (loginState != '0') {
    return PayCode();
  } else {
    return LoginPage();
  }
}

Future<Widget> goToTableEvents() async {
  Future<String> getIdToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? idToken = token.getString('TokenID');
    return idToken ?? '0';
  }

  String loginState = await getIdToken();

  if (loginState != '0') {
    return TableEvents();
  } else {
    return LoginPage();
  }
}

Future<Widget> goToListactivity() async {
  Future<String> getIdToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? idToken = token.getString('TokenID');
    return idToken ?? '0';
  }

  String loginState = await getIdToken();

  if (loginState != '0') {
    return Listactivity();
  } else {
    return LoginPage();
  }
}
