import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "设置",
          style: TextStyle(
              //fontFamily: "font2",
              fontSize: 21,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color.fromARGB(168, 139, 192, 188), // 设置背景颜色为透明
        elevation: 0,
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
    return Container(
      child: ListView(
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
            subtitle: Text("还没做,请关注QQ群"),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: Text("关于"),
          ),
          ListTile(
            leading: Icon(
              Icons.info_outline,
            ),
            title: const Text("Klee!"),
            subtitle: Text("本软件仅用于学习交流"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(
              Icons.code,
            ),
            title: Text("项目地址"),
            subtitle: const Text("https://github.com/Isatidia/Klee/"),
            onTap: () => launchUrlString("https://github.com/Isatidia/Klee/",
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
      ),
    );
  }
}
