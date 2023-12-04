import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PayCode extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('付款码')),
      body: RefreshCode(),
    );
  }
}

class RefreshCode extends StatefulWidget {
  const RefreshCode({Key? key}) : super(key: key);
  @override
  _RefreshCodeState createState() => _RefreshCodeState();
}

class _RefreshCodeState extends State<RefreshCode>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showCheckmark = false; // Whether to show the checkmark icon

  GlobalKey<_ShowPayCodeState> _showPayCodeKey = GlobalKey();

  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _showCheckmark = true;
          });
          _controller.reset();
        }
      });
  }

  void refreshShowPayCode() {
    _showPayCodeKey.currentState
        ?.refresh(); // Call refresh method in ShowPayCode
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ShowPayCode(key: _showPayCodeKey),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_controller.isAnimating) {
            return;
          }
          setState(() {
            _showCheckmark = false;
          });
          _controller.forward();
          refreshShowPayCode();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            if (_showCheckmark) {
              return Icon(Icons.check);
            } else {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14,
                child: Icon(Icons.refresh),
              );
            }
          },
        ),
        hoverColor: Color(0xFF31C6F4),
        backgroundColor: Color(0xE897C6F4),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ShowPayCode extends StatefulWidget {
  const ShowPayCode({Key? key}) : super(key: key);
  @override
  State<ShowPayCode> createState() => _ShowPayCodeState();
}

class _ShowPayCodeState extends State<ShowPayCode> {
  Future<String>? _ticketFuture;
  double _balance = 0.0;
  void initState() {
    super.initState();
    _ticketFuture = getfirstpaycode(); // 开始异步获取支付码
    _getBalance(); // 获取余额
  }

  void refresh() {
    setState(() {
      _ticketFuture = getfirstpaycode(); // Re-fetch data
      _getBalance(); // 获取余额
    });
  }

  Future<void> _getBalance() async {
    double balance = await GetBalance();
    setState(() {
      _balance = balance;
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidthRow = mediaQueryData.size.width;
    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromARGB(40, 40, 40, 40),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(25),
      child: FutureBuilder<String>(
        future: _ticketFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Image.asset(
                "images/mona-loading-default.gif",
                height: 180,
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            if (snapshot.data != 'Fail') {
              return Column(
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: QrImageView(
                      data: snapshot.data ?? '',
                      version: QrVersions.auto,
                      size: screenWidthRow * 2 / 3,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '扫描上面的二维码进行支付',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: 250,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1.0),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.all(16),
                    //margin: EdgeInsets.fromLTRB(50, 10, 50, 10),
                    child: Text(
                      '余额: $_balance',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              );
            } else {
              return Center(
                child: Text(
                  '请尝试右下角刷新',
                  style: TextStyle(fontSize: 30),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

//请求部分
//请求一次性令牌‘st-xxx’
Future<void> getTicket() async {
  //跨页面访问idtoken
  Future<String> getIdToken() async {
    SharedPreferences Token = await SharedPreferences.getInstance();
    String? idToken = Token.getString('TokenID');
    return idToken ?? ''; // 如果没有找到ID Token，则返回一个默认值
  }

  final client = http.Client();
  String idToken = await getIdToken();
  String baseUrl = 'https://cas.xbmu.edu.cn/cas/login';
  String service =
      'https%3A%2F%2Fykt.xbmu.edu.cn%2Fberserker-auth%2Fcas%2Flogin%2Fwisedu%3FtargetUrl%3Dhttps%253A%252F%252Fykt.xbmu.edu.cn%252Fberserker-base%252Fredirect%253FappId%253D12%2526type%253Dapp';
  //md不做符号转换
  //请求URL
  String requestUrl = '$baseUrl?idToken=$idToken&service=$service';
  // 发送get请求
  final request = http.Request('GET', Uri.parse(requestUrl));
  // 阻止重定向
  request.followRedirects = false;
  final response = await client.send(request);
  // 打印响应标头的Location字段
  final location = response.headers['location'];
  //print('Location: $location');

  // 关闭HTTP客户端
  client.close();

  if (response.statusCode == 302) {
    getnewCookie(location!);
  } else {
    print('fail');
    print(requestUrl);
  }
}

//通过替换JSESSIONI方式获取新的登录状态cookie-JSESSIONI
void getnewCookie(String location) async {
  var client = http.Client();
  var request = http.Request('GET', Uri.parse(location));
  request.headers['Cookie'] = 'JSESSIONID=2233';
  request.followRedirects = false;
  var response = await client.send(request);
  final cookie = response.headers['set-cookie'];
  //print(cookie);
  paycodetoken(cookie!);
  // 关闭HTTP客户端
  client.close();
}

//获取付款令牌,也是状态令牌
void paycodetoken(String cookie) async {
  var client = http.Client();
  var request = http.Request(
      'GET',
      Uri.parse(
          'https://ykt.xbmu.edu.cn/berserker-auth/cas/login/wisedu?targetUrl=https%3A%2F%2Fykt.xbmu.edu.cn%2Fberserker-base%2Fredirect%3FappId%3D12%26type%3Dapp'));
  request.headers['Cookie'] = cookie;
  request.followRedirects = false;
  var response = await client.send(request);
  //print(response.headers['location']);
  //print('                         ');
  // 获取重定向后的URL
  String redirectUrl = response.headers['location']!;
  // 解析URL
  Uri parsedUrl = Uri.parse(redirectUrl);
  // 获取参数值
  String synjonesAuth = parsedUrl.queryParameters['synjones-auth']!;
  //print('synjones-auth: $synjonesAuth');
  //print('                         ');
  //getpaycode(synjonesAuth);
  // 关闭HTTP客户端
  client.close();
  final SharedPreferences Token = await SharedPreferences.getInstance();
  await Token.setString('TokenCookie', synjonesAuth);
}

//获取一组付款码
Future<String> getpaycode(String synjonesAuth) async {
  var Information = Hive.box('DataBox');
  String? cardAccount = Information.get('cardAccount');
  print(cardAccount);
  var request = http.Request(
      'GET',
      Uri.parse(
          'https://ykt.xbmu.edu.cn/berserker-app/ykt/tsm/batchGetBarCodeGet?account=$cardAccount&payacc=000&paytype=1&synAccessSource=wechat-mp&synjones-auth=$synjonesAuth'));

  var response = await http.Client().send(request);
  var responseBody = await http.Response.fromStream(response);
  var jsonResponse = json.decode(responseBody.body);

  if (jsonResponse['code'] == 200) {
    List<String> barcodeList = (jsonResponse['data']['barcode'] as List)
        .map((item) => item.toString())
        .toList();
    //丢弃其他paycode，只要第一个
    String firstBarcode = barcodeList[0];
    print('First Paycode Number: $firstBarcode');
    return firstBarcode;
  } else {
    print('令牌synjonesAuth失效');
    return 'Fail';
  }
}

//获取余额
Future<double> GetBalance() async {
  Future<String> getsynjonesAuth() async {
    SharedPreferences Token = await SharedPreferences.getInstance();
    String? TokenCookie = Token.getString('TokenCookie');
    return TokenCookie ?? ''; // 如果没有找到ID Token，则返回一个默认值
  }

  String synjonesAuth = await getsynjonesAuth();
  var request = http.Request(
      'GET',
      Uri.parse(
          'https://ykt.xbmu.edu.cn/berserker-app/ykt/tsm/codebarPayinfo?synAccessSource=wechat-mp&synjones-auth=$synjonesAuth'));

  var response = await http.Client().send(request);
  var responseBody = await http.Response.fromStream(response);
  var jsonResponse = json.decode(responseBody.body);

  if (jsonResponse['code'] == 200) {
    int accinfoBalance = jsonResponse['data'][0]['accinfo_balance'];
    double accinfoBalanceWithDecimal = accinfoBalance / 100;
    print('balance还有: $accinfoBalanceWithDecimal');
    return accinfoBalanceWithDecimal;
  } else {
    print('令牌synjonesAuth失效');
    return -22.33;
  }
}

//获取付款码
Future<String> getfirstpaycode() async {
//优先使用临时身份码synjonesAuth请求付款码，不行再使用idToken重新获取，暂时不知道状态cookie什么时候过期，所以不用
  Future<String> getsynjonesAuth() async {
    SharedPreferences Token = await SharedPreferences.getInstance();
    String? TokenCookie = Token.getString('TokenCookie');
    return TokenCookie ?? ''; // 如果没有找到ID Token，则返回一个默认值
  }

  String synjonesAuth = await getsynjonesAuth();
  print(synjonesAuth);
  //GetBalance();
  String FirstPayCode = await getpaycode(synjonesAuth);
  if (FirstPayCode != 'Fail') {
    return FirstPayCode;
  } else {
    await getTicket();
    String synjonesAuth = await getsynjonesAuth();
    String FirstPayCode = await getpaycode(synjonesAuth);
    return FirstPayCode;
  }
}
