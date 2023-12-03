import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:klee/MainPage/HomePage.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:klee/MainPage/MorePage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:klee/MainPage/InformationPage.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:klee/Tools/HomePageTools/PayCode.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:klee/Tools/MoreTools/ClassStudy/ClassStudyFunction.dart';
//今天不写注释，明天我不认识

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('DataBox');

  initializeDateFormatting('zh_CN', null).then((_) {
    runApp(MaterialApp(
      themeMode: ThemeMode.system,
      home: OneMainPage(),
    ));
  });
  getTicket();
  WidgetsFlutterBinding.ensureInitialized();
}

class OneMainPage extends StatefulWidget {
  const OneMainPage({super.key});

  @override
  State<OneMainPage> createState() => _OneMainPageState();
}

class _OneMainPageState extends State<OneMainPage> {
  @override
  Widget build(BuildContext context) {
    InternetConnecte(context);
    return Scaffold(
      body: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key});
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> pages = [HomePage(), MoreToolsMainBody(), InformationPageBody()];
  int selectedPage = 0;
  List<double> zValues = [0, 0, 0]; // 初始化 Z 轴高度

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 65, // 设置底部导航栏的高度
        decoration: BoxDecoration(
            //  color: Color.fromARGB(231, 178, 216, 247),
            ),
        child: BottomNavigationBar(
          //backgroundColor: Color.fromARGB(235, 229, 239, 247),
          items: [
            BottomNavigationBarItem(
              icon: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                transform:
                    Matrix4.translationValues(0, 7.5, zValues[0]), // 应用 Z 轴变换
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
                    Matrix4.translationValues(0, 7.5, zValues[1]), // 应用 Z 轴变换
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
                    Matrix4.translationValues(0, 7.5, zValues[2]), // 应用 Z 轴变换
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
          // selectedItemColor: Color.fromARGB(175, 40, 40, 40),
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

Future<bool> isXBNUappInternetConnected() async {
  try {
    final response =
        await http.get(Uri.parse('http://210.26.0.114:9090/yrpt/app'));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> isMDYDTappInternetConnected() async {
  try {
    final response =
        await http.get(Uri.parse('https://cas.xbmu.edu.cn/cas/login'));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> isMDYDTpayInternetConnected() async {
  try {
    final response = await http
        .get(Uri.parse('https://ykt.xbmu.edu.cn/berserker-base/redirect'));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<bool> isAppUpdate() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;

  try {
    final response =
        await http.post(Uri.parse('https://api.isatidis.top/updata'));
    if (response.statusCode == 200) {
      String isUpdataVersion = json.decode(response.body)['version'];
      if (isUpdataVersion != version) {
        return true;
      }
      return false;
    }
    return false;
  } catch (e) {
    return false;
  }
}

Future<bool> isBaiduInternetConnected() async {
  try {
    final response = await http.get(Uri.parse('https://baidu.com'));
    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}

Future<List<String>> isAppUpdateMessage() async {
  try {
    final response =
        await http.post(Uri.parse('https://api.isatidis.top/updata'));
    if (response.statusCode == 200) {
      String isUpdataVersion = json.decode(response.body)['version'];
      String isUpdataMessage = json.decode(response.body)['message'];
      return [isUpdataVersion, isUpdataMessage];
    }
    return ["请求错误", "请检查你的网络连接"];
  } catch (e) {
    return ["请求错误", "请检查你的网络连接"];
  }
}

void InternetConnecte(BuildContext context) async {
  bool isMDQNConnected = await isXBNUappInternetConnected();
  bool isBaiduConnected = await isBaiduInternetConnected();
  bool isMDYDTappConnected = await isMDYDTappInternetConnected();
  bool isMDYDTpayConnected = await isMDYDTpayInternetConnected();
  bool isAppUpdata = await isAppUpdate();
  if (isBaiduConnected) {
    if (!isMDYDTappConnected) {
      ShowFalseSnackBar(context, '民大一点通服务器连接超时');
    }
    if (!isMDYDTpayConnected) {
      ShowFalseSnackBar(context, '民大一点通付费服务连接异常');
    }
    if (!isMDQNConnected) {
      ShowFalseSnackBar(context, '民大一点通服务器连接超时，服务器可能处于宕机状态');
    }
    if (isAppUpdata) {
      List<String> updatamessage = await isAppUpdateMessage();
      showUpadtaMessageDialog(context, updatamessage);
    }
  } else {
    ShowFalseSnackBar(context, '无法连接到网络');
  }
}

void showUpadtaMessageDialog(BuildContext context, List<String> message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("有可用的更新"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("版本号: v${message[0]}"),
              SizedBox(height: 10),
              Text("更新内容:"),
              Text("${message[1]}"),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("关闭"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("下载"),
            onPressed: () {
              Navigator.of(context).pop();
              showDownloadDialog(context);
            },
          ),
        ],
      );
    },
  );
}

void showDownloadDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("请选择下载渠道"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text("请在以下两个渠道下载\n未知来源的文件可能有恶意行为"),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("腾讯云CDN(推荐)"),
            onPressed: () {
              launchUrlString("https://cc.isatidis.top/apk_new.zip",
                  mode: LaunchMode.externalApplication);
            },
          ),
          TextButton(
            child: Text("Github"),
            onPressed: () {
              launchUrlString(
                  "https://github.com/Isatidia/klee/releases/latest",
                  mode: LaunchMode.externalApplication);
            },
          ),
          TextButton(
            child: Text("取消"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
