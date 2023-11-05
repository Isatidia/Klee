import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:folding_cell/folding_cell.dart';

String Message = '请求错误，请检查网络连接...';
String Message2 = '请求错误，请检查网络连接...';

class Listactivity extends StatelessWidget {
  const Listactivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '活动',
          style: TextStyle(
              color: Color.fromARGB(150, 40, 40, 40),
              //fontFamily: "font2",
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent, // Updated background color
        elevation: 0,
        iconTheme: IconThemeData(
          color: const Color.fromARGB(
              255, 153, 153, 153), // Set the arrow color to gray
        ),
      ),
      body: ListView(
        children: [
          activityInformationCards(),
        ],
      ),
    );
  }
}

class activityInformationCards extends StatefulWidget {
  @override
  _activityInformationCardsState createState() =>
      _activityInformationCardsState();
}

//123123
class _activityInformationCardsState extends State<activityInformationCards> {
  late Future<List<ActivityInformation>> _activityData;

  @override
  void initState() {
    super.initState();
    _activityData = ActivityListTesting();
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<ActivityInformation>>(
      future: _activityData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for data, display a loading indicator
          return Column(
            children: [
              SizedBox(
                height: 200,
              ),
              Center(
                child: Image.asset(
                  "images/mona-loading-default.gif",
                  height: 180,
                ),
              ),
              Center(
                child: Text(
                  '加载中...',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                ),
              )
            ],
          );
        } else if (snapshot.hasError) {
          // If there is an error during data fetching
          return Center(
            child: Text("Error: ${snapshot.error}"),
          );
        } else {
          // Data is ready, build the FoldingCell with the fetched data
          if (snapshot.hasData) {
            final activityList = snapshot.data;
            return Container(
              child: Column(
                children: activityList!.map((activity) {
                  final foldingCellKey = GlobalKey<SimpleFoldingCellState>();
                  return SimpleFoldingCell.create(
                    key: foldingCellKey,
                    frontWidget: _buildFrontWidget(
                      foldingCellKey,
                      activity.name,
                      activity.title_img,
                      activity.begin_time,
                      activity.end_time,
                    ),
                    innerWidget: _buildInnerWidget(
                      foldingCellKey,
                      activity.id,
                      activity.name,
                      activity.sponsor,
                      activity.begin_time,
                      activity.end_time,
                      activity.has_check_in,
                      activity.has_check_out,
                      activity.signup_online,
                      activity.signup_begin_time,
                      activity.signup_end_time,
                    ), //大卡片
                    cellSize: Size(MediaQuery.of(context).size.width, 160),
                    padding: EdgeInsets.fromLTRB(15, 10, 15, 5),
                    animationDuration: Duration(milliseconds: 300),
                    borderRadius: 10,
                  );
                }).toList(),
              ),
            );
          } else {
            // Data is null or empty
            return Center(
              child: Text("No data available"),
            );
          }
        }
      },
    );
  }

//传参！！！
  Widget _buildFrontWidget(
    GlobalKey<SimpleFoldingCellState> key,
    String name,
    String title_img,
    String begin_time,
    String end_time,
  ) {
    return Container(
      color: Color.fromARGB(255, 240, 240, 241),
      //alignment: Alignment.topCenter,
      child: Stack(
        children: <Widget>[
          Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(10, 10, 0, 0),
                height: 80,
                //color: Color.fromARGB(40, 40, 40, 40),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: FadeInImage(
                        placeholder: AssetImage('images/limobao.png'),
                        image: NetworkImage(title_img),
                      ),
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 5, 0, 0),
                          child: Text(
                            "活动时间:",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 2, 0, 0),
                          child: Text(
                            '$begin_time \n$end_time',
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                        //位置不够了，teng点位置
                        // Container(
                        //   margin: EdgeInsets.fromLTRB(10, 2, 20, 0),
                        //   child: Text(
                        //     '报名时间:',
                        //     style: TextStyle(
                        //         fontSize: 15, fontWeight: FontWeight.w500),
                        //   ),
                        // ),
                        // Container(
                        //   margin: EdgeInsets.fromLTRB(10, 2, 20, 0),
                        //   child: Text(
                        //     'time or not',
                        //     style: TextStyle(fontSize: 15),
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 70,
                padding: EdgeInsets.fromLTRB(1, 10, 0, 0),
                margin: EdgeInsets.fromLTRB(10, 0, 120, 0),
                //color: Color.fromARGB(39, 40, 40, 40),
                child: Text(
                  "$name",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(189, 0, 0, 0),
                  ),
                  textAlign: TextAlign.left, // 设置文本左对齐
                ),
              )
            ],
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: TextButton(
              onPressed: () => key.currentState?.toggleFold(),
              child: Text(
                "详细",
                style: TextStyle(
                    color: const Color.fromARGB(144, 0, 0, 0),
                    fontWeight: FontWeight.w600),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Color.fromARGB(220, 255, 255, 255),
                minimumSize: Size(80, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInnerWidget(
    GlobalKey<SimpleFoldingCellState> key,
    String id,
    String name,
    String sponsor,
    String begin_time,
    String end_time,
    bool has_check_in,
    bool has_check_out,
    bool signup_online,
    String signup_begin_time,
    String signup_end_time,
  ) {
    //签到判断弹窗 中转
    void _showRegisterConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return registerConfirmationDialog(
            hasCheckIn: has_check_in,
            id: id,
          );
        },
      );
    }

    //报名判断弹窗 中转
    void _showSingUpConfirmationDialog() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return singUpConfirmationDialog(
            signupOnline: signup_online,
            id: id,
          );
        },
      );
    }

    return Container(
      color: Color(0xFFecf2f9),
      padding: EdgeInsets.only(top: 5),
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(15, 0, 12, 0),
                child: Text(
                  "$name",
                  style: TextStyle(
                    color: Color(0xFF2e282a),
                    fontSize: 17.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(),
              Container(
                child: Text(
                  '主办单位:$sponsor',
                  style: TextStyle(fontSize: 15.5),
                ),
              ),
              Divider(),
              Container(
                child: Text(
                  '活动时间: $begin_time~$end_time',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Divider(),
              Container(
                child: Text(
                  '报名时间: $signup_begin_time~$signup_end_time',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              Divider(),
              Container(
                child: Text(
                  '是否可以报名: $signup_online',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Container(
                child: Text(
                  '是否可以签到: $has_check_in',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Container(
                child: Text(
                  '是否需要签退: $has_check_out',
                  style: TextStyle(fontSize: 15),
                ),
              ),
              Divider(),
              // Container(
              //   child: Text(
              //     'ID: $id',
              //     style: TextStyle(fontSize: 12),
              //   ),
              // ),
            ],
          ),
          Positioned(
            right: 190,
            bottom: 10,
            child: TextButton(
              onPressed: () {
                print('报名');
                _showSingUpConfirmationDialog();
              },
              child: Text(
                "报名",
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(80, 40),
              ),
            ),
          ),
          Positioned(
            right: 100,
            bottom: 10,
            child: TextButton(
              onPressed: () {
                print('签到');
                _showRegisterConfirmationDialog();
              },
              child: Text(
                "签到",
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(80, 40),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 10,
            child: TextButton(
              onPressed: () => key.currentState?.toggleFold(),
              child: Text(
                "返回",
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(80, 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//报名确认弹窗
class singUpConfirmationDialog extends StatelessWidget {
  final bool signupOnline;
  final String id;

  singUpConfirmationDialog({
    required this.signupOnline,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('确定报名吗？'),
      content: Text('您确定要报名吗？'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('取消'),
        ),
        if (signupOnline)
          TextButton(
            onPressed: () {
              print('确定报名');
              Navigator.of(context).pop();
              showSignUpDialog(context, id);
            },
            child: Text('确定'),
          ),
      ],
    );
  }
}

//签到确认弹窗
class registerConfirmationDialog extends StatelessWidget {
  final bool hasCheckIn;
  final String id;
  registerConfirmationDialog({
    required this.hasCheckIn,
    required this.id,
  });
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('确定签到吗？注意签到时间'),
      content: FutureBuilder<String>(
        future: registerTime(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 30,
              child: Text('获取签到时间...'),
            ); // 显示加载指示器
          } else if (snapshot.hasError) {
            return Text('加载失败: ${snapshot.error}');
          } else {
            return Text(snapshot.data ?? '没有数据'); // 显示请求结果
          }
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            //加上转跳
            Navigator.of(context).pop();
          },
          child: Text('取消'),
        ),
        if (hasCheckIn)
          TextButton(
            onPressed: () {
              //处理确定签到事件!!!!!
              print('确定签到');
              Navigator.of(context).pop();
              showRegisterDialog(context, id);
            },
            child: Text('签到'),
          ),
      ],
    );
  }
}

//请求签到时间
Future<String> registerTime(
  String id,
) async {
  final url = 'http://210.26.0.114:9090/yrpt/remote/';
  final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  final body = {
    'method': 'detail',
    'service': 'activityService',
    'params': '{"id": "$id"}'
  };

  final response =
      await http.post(Uri.parse(url), headers: headers, body: body);

  if (response.statusCode == 200) {
    final jsonResponse = response.body; // jsonResponse 是一个String
    //print(jsonResponse);

    final pattern =
        RegExp(r"签到时间：&nbsp;(\d{2}-\d{2} \d{2}:\d{2}～\d{2}-\d{2} \d{2}:\d{2})");
    final match = pattern.firstMatch(jsonResponse);

    if (match != null) {
      final signupTime = match.group(1)!;
      return ('签到时间：' + signupTime);
    } else {
      return ('没有签到时间');
    }
  } else {
    return ('Failed to fetch data. Status code: ${response.statusCode}');
  }
}

//请求部分
class ActivityInformation {
  final String id;
  final String name;
  final String sponsor; //发起社团or学院
  final bool has_check_in; //是否可以签到
  final bool has_check_out; //是否需要签退
  final bool signup_online; //能否报名
  final String signup_begin_time; //报名开始时间
  final String signup_end_time; //报名结束时间
  //final bool checkin_qrcode_status; //签到二维码状态，有quiet则有签到时间，空则无
  final String begin_time; //活动开始时间
  final String end_time; //活动结束时间
  final String title_img;
  //final String level_display; //活动类型
  //final String type_name; //活动性质

  ActivityInformation({
    required this.id,
    required this.name,
    required this.sponsor,
    required this.has_check_in,
    required this.has_check_out,
    required this.signup_online,
    required this.signup_begin_time,
    required this.signup_end_time,
    // required this.checkin_qrcode_status,
    required this.begin_time,
    required this.end_time,
    required this.title_img,
    //required this.level_display,
    //required this.type_name,
  });
}

//以后再写分页/翻页
Future<List<ActivityInformation>> ActivityListTesting() async {
  final url = Uri.parse('http://210.26.0.114:9090/yrpt/remote/');
  final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
  final body = {
    'method': 'search',
    'service': 'activityService',
    'params':
        '{"keywords":"","level":"","pageNum":1,"pageSize":25,"sptype":"","status":"1","type":""}'
  };

  final response = await http.post(url, headers: headers, body: body);

  if (response.statusCode == 200) {
    // 请求成功

    final jsonResponse = json.decode(response.body);
    //print('Response data: ${response.body}');
    final List<dynamic> datas = jsonResponse['datas'];
    List<ActivityInformation> ActivityList = [];
    for (final data in datas) {
      String A_id = data['id'];
      String A_name = data['name'];
      String A_sponsor = data['sponsor']; //发起社团or学院
      bool A_has_check_in = data['has_check_in']; //是否签到
      bool A_has_check_out = data['has_check_out']; //是否签退
      bool A_signup_online = data['signup_online']; //能否报名
      String A_signup_begin_time =
          extractDate01(data['signup_begin_time']); //报名开始时间
      String A_signup_end_time =
          extractDate02(data['signup_end_time']); //报名结束时间
      // String A_checkin_qrcode_status =
      //data['checkin_qrcode_status']; //签到二维码状态，有quiet则有签到时间，空则无
      String A_begin_time = extractDate1(data['begin_time']); //活动开始时间
      String A_end_time = extractDate1(data['end_time']); //活动结束时间
      String A_title_img = data['title_img'];

      ActivityList.add(
        ActivityInformation(
          id: A_id,
          name: A_name,
          sponsor: A_sponsor, //发起社团or学院
          has_check_in: A_has_check_in, //是否可以签到
          has_check_out: A_has_check_out, //是否可以签退
          signup_online: A_signup_online, //:能否报名
          signup_begin_time: A_signup_begin_time, //报名开始时间
          signup_end_time: A_signup_end_time, //报名结束时间
          //  checkin_qrcode_status:
          //    A_checkin_qrcode_status, //签到二维码状态，有quiet则有签到时间，空则无
          begin_time: A_begin_time, //活动开始时间
          end_time: A_end_time, //:活动结束时间
          title_img: A_title_img,
        ),
      );
    }
    return ActivityList;
  } else {
    // 请求失败
    print('Request failed with status: ${response.statusCode}');
    return [];
  }
}

//活动日期处理，简化为年月日
String extractDate1(String dateTimeString) {
  DateTime dateTime = DateTime.parse(dateTimeString);
  String formattedDate =
      '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  //print(formattedDate);
  return formattedDate;
}

//活动报名时间处理，处理空值
String extractDate01(String dateTimeString) {
  if (dateTimeString != '') {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String datePart =
        "${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return datePart;
  } else {
    return '没有报名时间';
  }
}

String extractDate02(String dateTimeString) {
  if (dateTimeString != '') {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String datePart =
        "${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return datePart;
  } else {
    return ' ';
  }
}

//开始！！！ 请求 加密的报名 数据
Future<void> getSignUpencrypt(String id) async {
  var Information = Hive.box('DataBox');
  String? username = Information.get('username');
  String url = 'https://api.isatidis.top/encrypt';
  Map<String, String> headers = {'Content-Type': 'application/json'};

  Map<String, dynamic> requestData = {
    "data": {
      "activityId": id,
      "additionalInfo": "报名",
      "loginId": username,
      "userType": "student",
      "user_code": username,
      "user_type": "student"
    }
  };

  String requestBody = json.encode(requestData);

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      print('$username');
      print('$id');
      print('加密成功，数据: ${response.body}');
      await getSignUp(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

//发送 加密的报名 请求
Future<void> getSignUp(String params) async {
  String url = 'http://210.26.0.114:9090/yrpt/remote/';
  Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'app-version': '2.4.1',
  };
  Map<String, String> bodyData = {
    'method': 'signup',
    'service': 'activitySignupApplyService',
    'params': params,
  };

  http
      .post(Uri.parse(url), headers: headers, body: bodyData)
      .then((response) async {
    if (response.statusCode == 200) {
      print('报名发送成功: ${response.body}');
      await getSignUpDecrypt(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }).catchError((error) {
    print('Error: $error');
  });
}

//报名请求发送成功后返回的 数据 解密
Future<void> getSignUpDecrypt(String encryptData) async {
  String url = 'https://api.isatidis.top/decrypt';
  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  Map<String, String> bodyData = {
    'data': encryptData,
  };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: json.encode(bodyData),
  );

  if (response.statusCode == 200) {
    print('报名请求发送成功后返回的 数据 解密： ${response.body}');
    Map<String, dynamic> responseData = json.decode(response.body);
    String message = responseData['message'];
    print(message);
    Message = message;
  } else {
    print('Request failed with status: ${response.statusCode}');
  }
}

void showSignUpDialog(
  BuildContext context,
  String id,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("报名状态"),
        content: FutureBuilder<String>(
          future: getSignUpMessage(id), // 异步请求数据
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 数据还在加载中
              return Container(
                height: 100,
                child: Column(
                  children: [
                    Container(
                      child: Image.asset(
                        "images/sasa!.gif",
                        height: 70,
                      ),
                    ),
                    Container(
                      child: Text('One moment please...'),
                    ),
                  ],
                ),
              ); // 或其他加载指示器
            } else if (snapshot.hasError) {
              // 请求发生错误
              return Text("发生错误: ${snapshot.error}");
            } else {
              // 请求成功，显示数据
              return Text(snapshot.data ?? "错误...");
            }
          },
        ),
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

//报名
Future<String> getSignUpMessage(String id) async {
  await getSignUpencrypt(id);
  await Future.delayed(Duration(milliseconds: 1250));
  return Message;
}

//签到判断窗
void showRegisterDialog(
  BuildContext context,
  String id,
) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("签到状态"),
        content: FutureBuilder<String>(
          future: getRegisterMessage(id), // 异步请求数据
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // 数据还在加载中
              return Container(
                height: 100,
                child: Column(
                  children: [
                    Container(
                      child: Image.asset(
                        "images/sasa!.gif",
                        height: 70,
                      ),
                    ),
                    Container(
                      child: Text('One moment please...'),
                    ),
                  ],
                ),
              ); // 或其他加载指示器
            } else if (snapshot.hasError) {
              // 请求发生错误
              return Text("发生错误: ${snapshot.error}");
            } else {
              // 请求成功，显示数据
              return Text(snapshot.data ?? "错误...");
            }
          },
        ),
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

//签到部分
Future<String> getRegisterMessage(String id) async {
  await getRegisterEncrypt(id);
  await Future.delayed(Duration(milliseconds: 1250));
  return Message2;
}

//开始！！原始签到数据加密
Future<void> getRegisterEncrypt(String id) async {
  var Information = Hive.box('DataBox');
  String? username = Information.get('username');
  String url = 'https://api.isatidis.top/encrypt';
  Map<String, String> headers = {'Content-Type': 'application/json'};

  Map<String, dynamic> requestData = {
    "data": {
      "activityId": id,
      "failTime": "2023-11-11 22:33:22",
      "loginId": username,
      "userType": "student",
      "user_code": username,
      "user_type": "student"
    }
  };

  String requestBody = json.encode(requestData);

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: requestBody,
    );

    if (response.statusCode == 200) {
      // print('加密成功，数据: ${response.body}');
      getRegister(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

//发送加密的签到数据
Future<void> getRegister(String params) async {
  String url = 'http://210.26.0.114:9090/yrpt/remote/';
  Map<String, String> headers = {
    'Content-Type': 'application/x-www-form-urlencoded',
    'app-version': '2.4.1',
  };
  Map<String, String> bodyData = {
    'method': 'checkin',
    'service': 'activityCheckinService',
    'params': params
  };
  http.post(Uri.parse(url), headers: headers, body: bodyData).then((response) {
    if (response.statusCode == 200) {
      // print('Response data: ${response.body}');
      getRegisterDecrypt(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
  }).catchError((error) {
    print('Error: $error');
  });
}

Future<void> getRegisterDecrypt(String encryptData) async {
  String url = 'https://api.isatidis.top/decrypt';
  Map<String, String> headers = {
    'Content-Type': 'application/json',
  };
  Map<String, String> bodyData = {
    'data': encryptData,
  };

  final response = await http.post(
    Uri.parse(url),
    headers: headers,
    body: json.encode(bodyData),
  );

  if (response.statusCode == 200) {
    print('报名请求发送成功后返回的\n 数据 解密： ${response.body}');
    Map<String, dynamic> responseData = json.decode(response.body);
    String message = responseData['message'];
    print(message);
    Message2 = message;
  } else {
    print('Request failed with status: ${response.statusCode}');
  }
}
