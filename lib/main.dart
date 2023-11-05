import 'package:Klee/MainPage/HomePage.dart';
import 'package:Klee/MainPage/MorePage.dart';
import 'package:Klee/MainPage/InformationPage.dart';
import 'package:flutter/material.dart';
import 'package:Klee/HomePageTools/PayCode.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';

//今天不写注释，明天我不认识

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('DataBox');
  await getTicket();
  initializeDateFormatting('zh_CN', null).then((_) {
    runApp(MaterialApp(
      home: MainPage(),
    ));
  });
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key});
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> pages = [HomePage(), MorePage(), InformationPageBody()];
  int selectedPage = 0;
  List<double> zValues = [0, 0, 0]; // 初始化 Z 轴高度

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 65, // 设置底部导航栏的高度
        decoration: BoxDecoration(
          color: Color.fromARGB(231, 178, 216, 247),
        ),
        child: BottomNavigationBar(
          backgroundColor: Color.fromARGB(235, 229, 239, 247),
          items: [
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform:
                    Matrix4.translationValues(0, 10, zValues[0]), // 应用 Z 轴变换
                child: Icon(Icons.home_outlined),
              ),
              activeIcon: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform:
                    Matrix4.translationValues(0, 2, zValues[0]), // 应用 Z 轴变换
                child: Icon(Icons.home),
              ),
              label: '主页',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform:
                    Matrix4.translationValues(0, 10, zValues[1]), // 应用 Z 轴变换
                child: Icon(Icons.auto_awesome_motion_outlined),
              ),
              activeIcon: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform:
                    Matrix4.translationValues(0, 2, zValues[1]), // 应用 Z 轴变换
                child: Icon(Icons.auto_awesome_motion_rounded),
              ),
              label: '更多',
            ),
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform:
                    Matrix4.translationValues(0, 10, zValues[2]), // 应用 Z 轴变换
                child: Icon(
                  Icons.account_circle_outlined,
                ),
              ),
              activeIcon: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform:
                    Matrix4.translationValues(0, 2, zValues[2]), // 应用 Z 轴变换
                child: Icon(Icons.account_circle),
              ),
              label: '我',
            ),
          ],
          currentIndex: selectedPage,

          //selectedLabelStyle: TextStyle(color: Colors.white),
          //unselectedLabelStyle: TextStyle(color: Colors.transparent),
          selectedIconTheme: IconThemeData(size: 26.0), // 调整选中状态图标的大小
          unselectedIconTheme: IconThemeData(size: 27.0),
          selectedItemColor: Color.fromARGB(175, 40, 40, 40),
          unselectedFontSize: 0,
          onTap: (index) {
            setState(() {
              // 更新选中页面和 Z 轴高度
              selectedPage = index;
              for (int i = 0; i < zValues.length; i++) {
                zValues[i] = (i == index) ? 10 : 0;
              }
            });
          },
        ),
      ),
      body: pages[selectedPage],
    );
  }
}
