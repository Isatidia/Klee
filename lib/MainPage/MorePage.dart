import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "更多",
          style: TextStyle(
              //fontFamily: "font2",
              fontSize: 21,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color.fromARGB(168, 139, 192, 188), // 设置背景颜色为透明
        elevation: 0,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 150,
          ),
          Center(
            child: Image.asset(
              "images/mona-loading-default.gif",
              height: 200,
            ),
          ),
          Center(
            child: Text(
              '功能开发中...',
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
