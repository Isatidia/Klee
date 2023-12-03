import 'dart:async';
import 'dart:convert';
import 'package:klee/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//import 'package:provider/provider.dart';
import 'package:klee/Tools/HomePageTools/PayCode.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:klee/InformationPage/ProfileInformationPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var nameController = TextEditingController(text: Account);
  var passwordController = TextEditingController(text: Password);
  var phoneNumberController = TextEditingController(text: Phone);
  var captchaController = TextEditingController(text: Captcha);
  var isLoggingWithPhone = false;
  bool _isButtonDisabled = false;
  int _counter = 10;
  late Timer _timer;

  static get Account => null;
  static get Password => null;
  static get Phone => null;
  static get Captcha => null;
  @override
  void initState() {
    super.initState();
    // Initialize _timer here
    _timer = Timer(Duration.zero, () {});
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        setState(() {
          if (_counter < 1) {
            timer.cancel();
            _isButtonDisabled = false;
          } else {
            _counter = _counter - 1;
          }
        });
      },
    );
  }

  void _onButtonPressed() async {
    if (!RegExp(r'^\d{11}$').hasMatch(phoneNumberController.text)) {
      print('输入正确手机号!');
      ScaffoldMessenger.of(context).clearSnackBars();
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
        backgroundColor: Color.fromARGB(232, 247, 74, 62),
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '请输入正确的手机号',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print('发送验证码!');
      String nonce1 = await initializationVerificationVode(context);
      if (nonce1 != '2233') {
        String nonce2 = await sendVerificationCode(
            context, phoneNumberController.text, nonce1);
        final SharedPreferences Token = await SharedPreferences.getInstance();
        await Token.setString('Nonce2', nonce2);
      }

      setState(() {
        _isButtonDisabled = true;
        _counter = 30;
        _startTimer();
      });
      //判断验证码发送是否成功,每一步判断是否为2233字符
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    // 获取屏幕宽度和高度
    double screenWidthRow = mediaQueryData.size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "登录",
          style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
        ),
        //backgroundColor: Color.fromARGB(172, 125, 199, 199),
        elevation: 0,
      ),
      body: ListView(
          padding: EdgeInsets.fromLTRB(
              screenWidthRow * 1 / 30, 0, screenWidthRow * 1 / 30, 0),
          children: [
            SizedBox(
              height: 50,
            ),
            Image.asset('images/klee.png', height: 130),
            SizedBox(
              height: 7,
            ),
            Center(
              child: Text(
                '民大一点通登录',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            DefaultTabController(
              length: 2, // Number of tabs
              child: Column(
                children: <Widget>[
                  Container(
                    // color: Color.fromARGB(40, 40, 40, 40),
                    child: TabBar(
                      tabs: [
                        Tab(text: '账号密码登录'),
                        Tab(text: '手机验证码登录'),
                      ],
                      onTap: (index) {
                        setState(() {
                          // Toggle between email/password and phone number login
                          isLoggingWithPhone = index == 1;
                        });
                      },
                    ),
                  ),
                  Container(
                    // width: 350,
                    // height: 250,
                    child: Column(
                      children: <Widget>[
                        AutofillGroup(
                          child: Column(
                            children: [
                              SizedBox(
                                height: 8,
                              ),
                              isLoggingWithPhone
                                  ? Column(children: [
                                      TextField(
                                        controller: phoneNumberController,
                                        keyboardType: TextInputType.phone,
                                        onChanged: (text) {
                                          _updateState();
                                        },
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          labelText: "手机号",
                                          hintText: "账号绑定的手机号",
                                          prefixIcon: const Icon(Icons.phone),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(5),
                                      ),
                                      Row(children: <Widget>[
                                        Container(
                                          width: screenWidthRow * 13 / 20,
                                          child: TextField(
                                            controller: captchaController,
                                            autofillHints: const [
                                              AutofillHints.password
                                            ],
                                            onChanged: (text) {
                                              _updateState();
                                            },
                                            decoration: InputDecoration(
                                              border:
                                                  const OutlineInputBorder(),
                                              labelText: "验证码",
                                              hintText: "手机验证码",
                                              prefixIcon: const Icon(
                                                  Icons.announcement),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidthRow / 40,
                                        ),
                                        Container(
                                          padding: EdgeInsets.all(0),
                                          width: screenWidthRow * 5 / 20,
                                          height: 50,
                                          child: IntrinsicWidth(
                                            child: ElevatedButton(
                                              onPressed: _isButtonDisabled
                                                  ? null
                                                  : _onButtonPressed,
                                              child: Text(
                                                _isButtonDisabled
                                                    ? '$_counter S'
                                                    : ' 发送\n验证码',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]),
                                      SizedBox.fromSize(
                                        size: const Size(5, 10),
                                      ),
                                      phoneLoginButton(
                                        phone: phoneNumberController.text,
                                        captcha: captchaController.text,
                                      ),
                                    ])
                                  : Column(children: [
                                      TextField(
                                        autofocus: false,
                                        controller: nameController,
                                        autofillHints: const [
                                          AutofillHints.email
                                        ],
                                        onChanged: (text) {
                                          _updateState();
                                        },
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          labelText: "账号",
                                          hintText: "学号",
                                          prefixIcon: const Icon(Icons.person),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.all(5),
                                      ),
                                      TextField(
                                        controller: passwordController,
                                        autofillHints: const [
                                          AutofillHints.password
                                        ],
                                        onChanged: (text) {
                                          _updateState();
                                        },
                                        decoration: InputDecoration(
                                          border: const OutlineInputBorder(),
                                          labelText: "密码",
                                          hintText: "您的登录密码",
                                          prefixIcon: const Icon(Icons.lock),
                                        ),
                                        obscureText: true,
                                      ),
                                      SizedBox.fromSize(
                                        size: const Size(5, 10),
                                      ),
                                      userNameLoginButton(
                                        account: nameController.text,
                                        password: passwordController.text,
                                      ),
                                    ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ... (以后再写)
                ],
              ),
            ),
          ]),
    );
  }
}

//账号密码登录按钮
class userNameLoginButton extends StatefulWidget {
  final String account;
  final String password;

  userNameLoginButton({required this.account, required this.password});
  @override
  _userNameLoginButtonState createState() => _userNameLoginButtonState();
}

class _userNameLoginButtonState extends State<userNameLoginButton> {
  final RoundedLoadingButtonController _loginInController =
      RoundedLoadingButtonController();

//按钮状态判断
  void _doSomething(
    RoundedLoadingButtonController controller,
    String account,
    String password,
  ) async {
    print('登录确认');

    if (widget.account.trim().isEmpty || widget.password.trim().isEmpty) {
      controller.reset();
      ScaffoldMessenger.of(context).clearSnackBars();
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
        // backgroundColor: Color.fromARGB(232, 247, 74, 62),

        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '请输入学号和密码',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print(account);
      print(password);
      bool loginStatus =
          await loginWithuserNameIdToken(context, account, password);
      if (!loginStatus) {
        controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RoundedLoadingButton(
        width: 380,
        color: Color.fromARGB(199, 106, 244, 216),
        successColor: const Color.fromARGB(255, 245, 217, 133),
        controller: _loginInController,
        onPressed: () => _doSomething(
          _loginInController,
          widget.account,
          widget.password,
        ),
        valueColor: Colors.black,
        borderRadius: 10,
        child: Text('登录', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}

//手机号登录按钮
class phoneLoginButton extends StatefulWidget {
  final String phone;
  final String captcha;

  phoneLoginButton({required this.phone, required this.captcha});
  @override
  _phoneLoginButtonState createState() => _phoneLoginButtonState();
}

class _phoneLoginButtonState extends State<phoneLoginButton> {
  final RoundedLoadingButtonController _loginInController =
      RoundedLoadingButtonController();

//按钮状态判断
  void _doSomething(
    RoundedLoadingButtonController controller,
    String phone,
    String captcha,
  ) async {
    print('验证码登录确认');
//先判断有无手机号，再判断有无验证码，记得更新组件,验证码的密码属性记得改
    if (!RegExp(r'^\d{11}$').hasMatch(widget.phone)) {
      controller.reset();
      ScaffoldMessenger.of(context).clearSnackBars();
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
        backgroundColor: Color.fromARGB(232, 247, 74, 62),
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '请输入正确的手机号',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      if (!widget.captcha.trim().isEmpty) {
        //开始验证码登录
        Future<String> getNonce2() async {
          SharedPreferences Token = await SharedPreferences.getInstance();
          String? idToken = Token.getString('Nonce2');
          return idToken ?? ''; // 如果没有找到ID Token，则返回一个默认值
        }

        String nonce2 = await getNonce2();
        //print(widget.phone);
        //print(widget.captcha);
        bool loginState = await loginWithPhoneIdToken(
            context, widget.phone, widget.captcha, nonce2);
        if (!loginState) {
          controller.reset();
        }
      } else {
        controller.reset();
        ScaffoldMessenger.of(context).clearSnackBars();
        final snackBar = SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
          backgroundColor: Color.fromARGB(232, 247, 74, 62),
          content: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              SizedBox(width: 8),
              Text(
                '请输入验证码',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RoundedLoadingButton(
        width: 380,
        color: Color.fromARGB(199, 106, 244, 216),
        successColor: const Color.fromARGB(255, 245, 217, 133),
        controller: _loginInController,
        onPressed: () => _doSomething(
          _loginInController,
          widget.phone,
          widget.captcha,
        ),
        valueColor: Colors.black,
        borderRadius: 10,
        child: Text('登录', style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}

//登录成功后获取信息
void GetInformation() {
  getTicket();
  GetPersonalInformation();
}

//账户密码登录
Future<bool> loginWithuserNameIdToken(
    BuildContext context, String userName, String userPassword) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String userAgent = 'klee/$version';
  String baseUrl = 'https://cas.xbmu.edu.cn/token/password/passwordLogin';
  String username = userName;
  String password = userPassword;
  String appId = 'YOUR_APP_ID';
  String deviceId = 'YOUR_DEVICE_ID';
  String osType = 'YOUR_OS_TYPE';
  String geo = 'YOUR_GEO';
  var url = Uri.parse(
      '$baseUrl?username=$username&password=$password&appId=$appId&deviceId=$deviceId&osType=$osType&geo=$geo');
  var headers = {
    'User-Agent': userAgent,
  };
  try {
    var response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Map<String, dynamic> data = jsonResponse['data'];
      String idToken = data['idToken'];
      print('idToken: $idToken');
      final SharedPreferences Token = await SharedPreferences.getInstance();
      await Token.setString('TokenID', idToken);
      GetInformation();

      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
        //backgroundColor: Color.fromARGB(232, 247, 74, 62),
        content: Row(
          children: [
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '登录成功',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.push(context, MaterialPageRoute(builder: (_) => MainPage()));
      return true;
    } else {
      print('请求失败，状态码: ${response.statusCode}');
      ScaffoldMessenger.of(context).clearSnackBars();
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
        backgroundColor: Color.fromARGB(232, 247, 74, 62),
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '登录失败，请检查你的登录信息',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
      backgroundColor: Color.fromARGB(232, 247, 74, 62),
      content: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            '登录超时，请检查你的网络连接',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return false;
  }
}

//初始化验证码
Future<String> initializationVerificationVode(BuildContext context) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String userAgent = 'klee/$version';
  var url = Uri.parse('https://cas.xbmu.edu.cn/token/passwordless/smsInit');
  var headers = {
    'xweb_xhr': '1',
    'User-Agent': userAgent,
    'Sec-Fetch-Site': 'cross-site',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Dest': 'empty',
  };
  try {
    var response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      print('Request successful');

      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Map<String, dynamic> data = jsonResponse['data'];
      String nonce = data['nonce'];
      //sendVerificationCode(context, userAgent, userPhone, nonce);
      //print('$nonce');
      return nonce;
    } else {
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
        backgroundColor: Color.fromARGB(232, 247, 74, 62),
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '民大一点通认证服务器错误',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return '2233';
    }
  } catch (e) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
      backgroundColor: Color.fromARGB(232, 247, 74, 62),
      content: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            '网络错误',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    //print('Error during the HTTP request: $e');
    return '2233';
  }
}

//发送验证码
Future<String> sendVerificationCode(
  BuildContext context,
  String userPhone,
  String nonce,
) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String userAgent = 'klee/$version';
  var url = Uri.parse(
      'https://cas.xbmu.edu.cn/token/passwordless/smsSend?mobile=$userPhone&nonce=$nonce');
  var headers = {
    'xweb_xhr': '1',
    'Accept-Language': 'zh-CN',
    'User-Agent': userAgent,
    'Sec-Fetch-Site': 'cross-site',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Dest': 'empty',
  };
  try {
    var response = await http.post(url, headers: headers);
    if (response.statusCode == 200) {
      print('验证码发送成功');
      print('Response body: ${response.body}');
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
              '验证码发送成功',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      //下一步
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Map<String, dynamic> data = jsonResponse['data'];
      String nonce = data['nonce'];

      print('$nonce');
      return nonce;
    } else {
      print('Response body: ${response.body}');
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
        backgroundColor: Color.fromARGB(232, 247, 74, 62),
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '该手机号未绑定',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return '2233';
    }
  } catch (e) {
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
      backgroundColor: Color.fromARGB(232, 247, 74, 62),
      content: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            '网络错误',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    print('Error during the HTTP request: $e');
    return '2233';
  }
}

//手机验证码登录
Future<bool> loginWithPhoneIdToken(BuildContext context, String userPhone,
    String smscode, String nonce) async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String version = packageInfo.version;
  String userAgent = 'klee/$version';
  var url = Uri.parse(
      'https://cas.xbmu.edu.cn/token/passwordless/smsLogin?mobile=$userPhone&smscode=$smscode&appId=APP_ID&deviceId=DEVICE_ID&osType=OS_TYPE&geo=GEO&nonce=$nonce');
  var headers = {
    'xweb_xhr': '1',
    'Accept-Language': 'zh-CN',
    'User-Agent': userAgent,
    'Sec-Fetch-Site': 'cross-site',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Dest': 'empty',
  };
  try {
    var response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      Map<String, dynamic> data = jsonResponse['data'];
      String idToken = data['idToken'];
      print('idToken: $idToken');
      final SharedPreferences Token = await SharedPreferences.getInstance();
      await Token.setString('TokenID', idToken);
      GetInformation();

      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
        //backgroundColor: Color.fromARGB(232, 247, 74, 62),
        content: Row(
          children: [
            Icon(
              Icons.check,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '登录成功',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      Navigator.push(context, MaterialPageRoute(builder: (_) => MainPage()));
      return true;
    } else {
      print('请求失败，状态码: ${response.statusCode}');
      ScaffoldMessenger.of(context).clearSnackBars();
      final snackBar = SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
        backgroundColor: Color.fromARGB(232, 247, 74, 62),
        content: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '登录失败，请检查你的登录信息',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return false;
    }
  } catch (e) {
    ScaffoldMessenger.of(context).clearSnackBars();
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
      backgroundColor: Color.fromARGB(232, 247, 74, 62),
      content: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.white,
          ),
          SizedBox(width: 8),
          Text(
            '登录超时，请检查你的网络连接',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return false;
  }
}
