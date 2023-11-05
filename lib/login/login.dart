import 'dart:convert';
import 'package:Klee/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:Klee/HomePageTools/PayCode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Klee/InformationPage/ProfileInformationPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var nameController = TextEditingController(text: Account);
  var passwordController = TextEditingController(text: Password);
  var isLogging = false;
  var errorMessage = '';
  Future<void> loginAndFetchIdToken() async {
    String baseUrl = 'https://cas.xbmu.edu.cn/token/password/passwordLogin';
    String username = nameController.text;
    String password = passwordController.text;
    String appId = 'YOUR_APP_ID';
    String deviceId = 'YOUR_DEVICE_ID';
    String osType = 'YOUR_OS_TYPE';
    String geo = 'YOUR_GEO';
    //妈的后端又不写，要这些参数干什么，留着以后改
    //请求URL，将学号和密码添加到URL中
    String requestUrl =
        '$baseUrl?username=$username&password=$password&appId=$appId&deviceId=$deviceId&osType=$osType&geo=$geo';
    // 发送POST请求
    var response = await http.post(
      Uri.parse(requestUrl),
    );
    if (response.statusCode == 200) {
      // 请求成功
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Map<String, dynamic> data = jsonResponse['data'];
      String idToken = data['idToken']; // 获取idToken
      // 打印idToken
      print('idToken: $idToken');
      //存储idtoken
      final SharedPreferences Token = await SharedPreferences.getInstance();
      await Token.setString('TokenID', idToken);
      //获取数据
      GetInformation();
      //记得写返回提示
      Navigator.push(context, MaterialPageRoute(builder: (_) => MainPage()));
      showSuccessDialog(context);
    } else {
      // 请求失败
      print('请求失败，状态码: ${response.statusCode}');
      setState(() {
        errorMessage = '账号或密码错误'; // Set error message
        isLogging = false;
      });
    }
  }

  static get Account => null;

  static get Password => null;
  //bool useMyServer = appdata.settings[3]=="1";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "登录",
          style: TextStyle(
              //fontFamily: "font2",
              fontSize: 21,
              fontWeight: FontWeight.w600),
        ),
        backgroundColor: Color.fromARGB(168, 139, 192, 188), // 设置背景颜色为透明
        elevation: 0,
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          height: 500,
          //decoration: BoxDecoration(border: Border.all(width: 10, color: Colors.lightBlueAccent)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
            child: Column(
              children: <Widget>[
                AutofillGroup(
                    child: Column(
                  children: [
                    Image.network(
                      'https://cc.isatidis.top/klee.jpg',
                      height: 130,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                      child: Text('民大一点通登录'),
                    ),
                    TextField(
                      autofocus: false,
                      controller: nameController,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: "账号",
                          hintText: "学号",
                          prefixIcon: const Icon(Icons.person)),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(5),
                    ),
                    TextField(
                      controller: passwordController,
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                          border: const OutlineInputBorder(),
                          labelText: "密码",
                          hintText: "您的登录密码",
                          prefixIcon: const Icon(Icons.lock)),
                      //obscureText: true,//密码隐藏组件，记得撤销注释
                    ),
                  ],
                )),
                SizedBox.fromSize(
                  size: const Size(5, 10),
                ),
                if (!isLogging)
                  Column(
                    children: [
                      Text(
                        errorMessage,
                        style: TextStyle(color: Colors.red),
                      ), // Display error message
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLogging = true;
                            errorMessage = ''; // Clear error message
                          });
                          loginAndFetchIdToken();
                        },
                        child: Container(
                          width: 180, // Set the width to your desired value
                          height: 45, // Set the height to your desired value
                          alignment: Alignment.center, // Center the text
                          child: Text('登录',
                              style: TextStyle(
                                  fontSize: 20)), // Customize text style
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(198, 207, 241, 243),
                          padding:
                              EdgeInsets.all(2), // Adjust padding as needed
                          minimumSize:
                              Size(200, 50), // Adjust minimum size as needed
                        ),
                      ),
                    ],
                  ),
                if (isLogging) const CircularProgressIndicator(), //登录按钮变化
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // 返回一个AlertDialog
      return AlertDialog(
        title: Text("登录成功"),
        content: Text("欢迎使用！"),
        actions: <Widget>[
          TextButton(
            child: Text("关闭"),
            onPressed: () {
              // 关闭提示框
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void GetInformation() async {
  await getTicket();
  await GetPersonalInformation();
}
