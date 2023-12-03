import 'dart:convert';
import 'package:klee/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "设置",
        ),
      ),
      body: SettingsScreen(),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  int selectedTheme = 0;

  List<String> themes = ['明亮', '深色', '系统默认'];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Container(
          height: 15,
        ),
        ListTile(
          title: Text('还没做'),
          trailing: Switch(
            value: notificationsEnabled,
            onChanged: (value) {
              setState(() {
                notificationsEnabled = value;
              });
            },
          ),
        ),
        const Divider(),
        ListTile(
          title: Text("APP"),
        ),
        ListTile(
          leading: Icon(
            Icons.update,
          ),
          title: Text("检查更新"),
          subtitle: Text("点击检查更新"),
          onTap: () {
            isAppUpdate(context);
          },
        ),
        const Divider(),
        ListTile(
          title: Text("关于"),
        ),
        ListTile(
          leading: Icon(
            Icons.info_outline,
          ),
          title: const Text("klee!"),
          subtitle: Text("本软件仅用于学习交流"),
          onTap: () {},
        ),
        ListTile(
          leading: Icon(
            Icons.code,
          ),
          title: Text("项目地址"),
          subtitle: const Text("https://github.com/Isatidia/klee"),
          onTap: () => launchUrlString("https://github.com/Isatidia/klee",
              mode: LaunchMode.externalApplication),
        ),
        ListTile(
          leading: const Icon(Icons.support_outlined),
          title: Text("支持开发"),
          subtitle: const Text("KFCFKXQS-VW50"),
          onTap: () => launchUrlString("https://cc.isatidis.top/v50.jpg",
              mode: LaunchMode.externalApplication),
        ),
        ListTile(
          leading: const Icon(Icons.comment_outlined),
          title: Text("加入QQ群"),
          subtitle: const Text("QQ群:929874130"),
          onTap: () => launchUrlString(
              "http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=jBzF3oGkYB4v6_ILyh3IMBTePJs2x2E3&authKey=Xx608ZC7WxTRKj3RGI628sBTVhHFe2i6bfVEwdnii5lmxkmsZLUFP%2Bnzn3fk%2F0QU&noverify=0&group_code=929874130",
              mode: LaunchMode.externalApplication),
        ),
      ],
    );
  }
}

void isAppUpdate(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  try {
    final response =
        await http.post(Uri.parse('https://api.isatidis.top/updata'));
    if (response.statusCode == 200) {
      String isUpdataVersion = json.decode(response.body)['version'];

      if (isUpdataVersion != version) {
        List<String> updatamessage = await isAppUpdateMessage();
        showUpadtaMessageDialog(context, updatamessage);
      } else {
        print("最新的");
        ShowNoUpdataSnackBar(context);
      }
    } else {
      ShowFalseSnackBar(context, "连接到更新服务器出错，这通常是开发者的问题");
    }
  } catch (e) {
    ShowFalseSnackBar(context, "网络错误，请检查你的网络连接");
  }
}

void ShowFalseSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
    backgroundColor: Color.fromARGB(232, 247, 74, 62),
    content: Row(
      children: [
        Icon(
          Icons.link_off,
          color: Colors.white,
        ),
        SizedBox(width: 8),
        Text(
          '$message',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void ShowNoUpdataSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).clearSnackBars();
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
    //backgroundColor: Color.fromARGB(232, 247, 185, 62),
    content: Row(
      children: [
        Icon(
          Icons.file_download_done,
          color: Colors.white,
        ),
        SizedBox(width: 8),
        Text(
          "当前是最新版",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ],
    ),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
