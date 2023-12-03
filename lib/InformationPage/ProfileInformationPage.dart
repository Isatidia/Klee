import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileInformationPage extends StatelessWidget {
  const ProfileInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "个人信息",
        ),
      ),
      body: Center(
        child: ProfileInformationBody(),
      ),
    );
  }
}

//尝试ful
class MyImageWidget extends StatefulWidget {
  @override
  _MyImageWidgetState createState() => _MyImageWidgetState();
}

class _MyImageWidgetState extends State<MyImageWidget> {
  String imageUrl = 'https://cc.isatidis.top/001.png'; // 默认图片

  @override
  void initState() {
    super.initState();
    openHiveBoxAndLoadImage();
  }

  Future<void> openHiveBoxAndLoadImage() async {
    //await Hive.initFlutter();
    await Hive.openBox('DataBox');
    loadAvatarImage();
  }

  Future<void> loadAvatarImage() async {
    await GetPersonalImage();
    final box = await Hive.openBox('DataBox');
    String avatarUrl = box.get('avatarUrl', defaultValue: imageUrl);
    setState(() {
      imageUrl = avatarUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
        height: 150, // 设置容器高度
        child: Image.network(
          imageUrl,
        ));
  }
}

//个人信息主页
class ProfileInformationBody extends StatelessWidget {
  const ProfileInformationBody({super.key});

  @override
  Widget build(BuildContext context) {
    var Information = Hive.box('DataBox');
    String? userName = Information.get('userName');
    String? username = Information.get('username');
    String? organizationName = Information.get('organizationName');
    String? identityTypeName = Information.get('identityTypeName');
    return Container(
      margin: EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Color.fromARGB(40, 40, 40, 40)),
      child: ListView(
        children: <Widget>[
          MyImageWidget(),
          ListTile(
              title: Center(
            child: Text(
              '$userName',
              style: TextStyle(fontSize: 28),
            ),
          )),
          const Divider(),
          ListTile(
            leading: Icon(Icons.star),
            title: Text('学号：$username'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.class_rounded),
            title: Text('班级：$organizationName'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.assured_workload),
            title: Text('状态：$identityTypeName'),
            onTap: () {},
          ),
          const Divider(),
        ],
      ),
    );
  }
}

//获取个人信息
Future<void> GetPersonalInformation() async {
  Future<String> getIdToken() async {
    SharedPreferences Token = await SharedPreferences.getInstance();
    String? idToken = Token.getString('TokenID');
    return idToken ?? ''; // 如果没有找到ID Token，则返回一个默认值
  }

  String idToken = await getIdToken();

  String baseUrl =
      'https://authx-service.xbmu.edu.cn/personal/api/v1/personal/me/user';

  String requestUrl = '$baseUrl?idToken=$idToken';

  var response = await http.get(
    Uri.parse(requestUrl),
  );

  if (response.statusCode == 200) {
    //final jsonData = jsonDecode(response.body);
    Map<String, dynamic> jsonData = json.decode(response.body);
    // 访问JSON数据中的字段
    //bool acknowledged = jsonData["acknowleged"];
    //int code = jsonData["code"];
    // String message = jsonData["message"];
    Map<String, dynamic> data = jsonData["data"];
    String? username = data["username"];
    //List<String> roles = List<String>.from(data["roles"]);
    Map<String, dynamic> attributes = data["attributes"];
    //String? organizationId = attributes["organizationId"];
    //String identityTypeCode = attributes["identityTypeCode"];
    // String accountId = attributes["accountId"];
    String? organizationName = attributes["organizationName"];
    // String organizationCode = attributes["organizationCode"];
    String? imageUrl = attributes["imageUrl"];
    String? identityTypeName = attributes["identityTypeName"];
    //String identityTypeId = attributes["identityTypeId"];
    String? userName = attributes["userName"];
    //String userId = attributes["userId"];
    //String userUid = attributes["userUid"];
    //存储个人信息
    Hive.init('Data');
    var Information = await Hive.openBox('DataBox');
    Information.put('username', username);
    Information.put('organizationName', organizationName);
    Information.put('imageUrl', imageUrl);
    Information.put('identityTypeName', identityTypeName);
    Information.put('userName', userName);
    Information.put('userName', userName);
    Information.put('ActivityRegisterMessages', "默认:报名");
  } else {
    print("请求失败");
  }
}

//获取个人头像
Future<String> GetPersonalImage() async {
  Future<String> getTokenCookieJSESSIONI() async {
    SharedPreferences Token = await SharedPreferences.getInstance();
    String? TokenCookie = Token.getString('TokenCookie');
    return TokenCookie ?? ''; // 如果没有找到ID Token，则返回一个默认值
  }

  String TokenCookieJSESSIONI = await getTokenCookieJSESSIONI();
  String synAccessSource = 'wechat-mp';
  String baseUrlImage = 'https://ykt.xbmu.edu.cn/berserker-base/user';
  String requestUrlImage =
      '$baseUrlImage?synAccessSource=$synAccessSource&synjones-auth=$TokenCookieJSESSIONI';
  var responseImage = await http.get(
    Uri.parse(requestUrlImage),
  );
  if (responseImage.statusCode == 200) {
    // 解析JSON字符串
    Map<String, dynamic> jsonData = json.decode(responseImage.body);
    String avatarUrl = jsonData['data']['avatar'];
    print(avatarUrl);
    //Hive.init('Data');
    var Information = await Hive.openBox('DataBox');
    Information.put('avatarUrl', avatarUrl);
    return avatarUrl;
  } else {
    print('头像获取失败');
    print(requestUrlImage);
    return 'https://isatidis.top/img/card_cn.jpg';
  }
}
