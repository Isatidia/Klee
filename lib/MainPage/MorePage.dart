//import 'package:klee/MainPage/HomePage.dart';
import 'package:klee/Tools/MoreTools/ClassStudy/ClassStudy.dart';
import 'package:klee/login/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MoreToolsMainBody extends StatelessWidget {
  const MoreToolsMainBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("更多工具"),
      ),
      body: MoreToolsBody(),
    );
  }
}

class MoreToolsBody extends StatelessWidget {
  const MoreToolsBody({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidthRow = mediaQueryData.size.width;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                children: [
                  MoreToolButton(
                    title: "民大青年-我的课程",
                    subTitle: "量子速读！",
                    icon: Icons.book_rounded,
                    onTap: () {
                      goToClassListBody().then((page) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => page,
                        ));
                      });
                    },
                    screenWidth: screenWidthRow,
                  ),
                  MoreToolButton(
                    title: "青年大学习",
                    subTitle: "开发中...",
                    icon: Icons.collections_bookmark,
                    onTap: () {},
                    //onTap: () {},
                    screenWidth: screenWidthRow,
                  ),
                  MoreToolButton(
                    title: "更多建议",
                    subTitle: "请在QQ群反馈,在设置中查看群号",
                    icon: Icons.build_circle,
                    onTap: () {},
                    screenWidth: screenWidthRow,
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}

class MoreToolButton extends StatefulWidget {
  const MoreToolButton(
      {required this.title,
      required this.subTitle,
      required this.icon,
      required this.screenWidth,
      required this.onTap,
      super.key});

  final String title;
  final String subTitle;
  final double screenWidth;
  final IconData icon;
  final void Function() onTap;

  @override
  State<MoreToolButton> createState() => _MoreToolButtonState();
}

class _MoreToolButtonState extends State<MoreToolButton> {
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
              width: widget.screenWidth * 9 / 10,
              height: 130,
              child: AnimatedContainer(
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                    color: hovering
                        ? Theme.of(context)
                            .colorScheme
                            .inversePrimary
                            .withAlpha(70)
                        : Theme.of(context)
                            .colorScheme
                            .inversePrimary
                            .withAlpha(50)),
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
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  widget.subTitle,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ClipPath(
                          clipper: MoreToolsIconClipper(),
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

class MoreToolsIconClipper extends CustomClipper<Path> {
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

Future<Widget> goToClassListBody() async {
  Future<String> getIdToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? idToken = token.getString('TokenID');
    return idToken ?? '0';
  }

  String loginState = await getIdToken();

  if (loginState != '0') {
    return ClassListTab();
  } else {
    return LoginPage();
  }
}
