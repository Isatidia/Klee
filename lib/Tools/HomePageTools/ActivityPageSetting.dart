import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ActivityRegisterPage extends StatelessWidget {
  const ActivityRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("活动报名设置"),
      ),
      body: MyListTile(),
    );
  }
}

class MyListTile extends StatefulWidget {
  @override
  _MyListTileState createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  TextEditingController _textEditingController = TextEditingController();
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    var Information = Hive.box('DataBox');
    String? registerMessages = Information.get('ActivityRegisterMessages');
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidthRow = mediaQueryData.size.width;
    return ListView(
      children: [
        Container(
          height: 15,
        ),
        ListTile(
          title: Text('按钮，功能以后加'),
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
          title: Text("活动报名"),
        ),
        ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("报名时提交文字"),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: screenWidthRow * 13 / 20,
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        hintText: "报名文本：$registerMessages",
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                    height: 45,
                    //width: screenWidthRow / 5,
                    child: ElevatedButton(
                      onPressed: () {
                        String enteredText = _textEditingController.text;
                        if (!enteredText.isEmpty) {
                          Information.put(
                              'ActivityRegisterMessages', enteredText);
                          ScaffoldMessenger.of(context).clearSnackBars();
                          final snackBar = SnackBar(
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
                            content: Row(
                              children: [
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "保存成功",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                              ],
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }
                        setState(() {});
                      },
                      child: Text("保存"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          title: Text("一键全部报名"),
        ),
        ListTile(
          leading: Icon(
            Icons.info_outline,
          ),
          title: const Text("功能开发中"),
          subtitle: Text("预计下个版本上线,请关注QQ群"),
          onTap: () {},
        ),
        const Divider(),
      ],
    );
  }
}
