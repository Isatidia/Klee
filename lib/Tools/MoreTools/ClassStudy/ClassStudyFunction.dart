import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

//未学习课程
class ClassNoStudyList {
  final String course_id; //课程ID
  final String name; //课程名称
  final String study_status_display; //课程状态
  final String planStatus; //课程状态(2：可以学习)（3：结束）
  final String duration; //课程总时间
  final String course_type; //课程类别
  final String learnt_duration; //已经学习时间
  final String plan_id; //学习参数一部分，还有sectionId，在课程详细信息

  ClassNoStudyList({
    required this.name,
    required this.duration,
    required this.study_status_display,
    required this.planStatus,
    required this.course_type,
    required this.learnt_duration,
    required this.plan_id,
    required this.course_id,
  });
}

Future<List<ClassNoStudyList>> GetNoEndClassList() async {
  var Information = Hive.box('DataBox');
  String? username = Information.get('username');
  final url = 'http://210.26.0.114:9090/mdedu/remote/';
  final body = {
    'params':
        '{"loginId":"$username","pageNum":1,"pageSize":20,"target_app":"mdqn","type":"learning","userType":"student","user_code":"$username","user_type":"student"}',
    'service': 'courseService',
    'method': 'searchMine',
  };
  try {
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> datas = jsonData['datas'];
      List<ClassNoStudyList> ClassNoStudyInformationList = [];
      for (var data in datas) {
        String c_course_id = data['course_id'].toString();
        String c_name = data['name'].toString();
        String c_study_status_display = data['study_status_display'];
        String c_planStatus = data['planStatus'];
        String c_duration = data['duration'].toString();
        String c_course_type = data['course_type'].toString();
        String c_learnt_duration = data['learnt_duration'].toString();
        String c_plan_id = data['plan_id'].toString();
        ClassNoStudyInformationList.add(ClassNoStudyList(
          course_id: c_course_id,
          name: c_name,
          study_status_display: c_study_status_display,
          planStatus: c_planStatus,
          duration: c_duration,
          course_type: c_course_type,
          learnt_duration: c_learnt_duration,
          plan_id: c_plan_id,
        ));
      }
      return ClassNoStudyInformationList;
    } else {
      print('Error: ${response.statusCode}');
      print('Response: ${response.body}');
      return [];
    }
  } catch (e) {
    //超时弹窗
    return [];
  }
}

//已经学习课程
class ClassEndStudyList {
  final String course_id; //课程ID
  final String name; //课程名称
  final String duration; //课程总时间
  final String course_type; //课程类别
  final String study_status_display; //课程状态

  final String learnt_duration; //已经学习时间
  final String plan_id; //学习参数一部分，还有sectionId，在课程详细信息

  ClassEndStudyList({
    required this.name,
    required this.duration,
    required this.course_type,
    required this.learnt_duration,
    required this.study_status_display,
    required this.plan_id,
    required this.course_id,
  });
}

//学号两个地方,记得传参
Future<List<ClassEndStudyList>> GetEndClassList() async {
  var Information = Hive.box('DataBox');
  String? username = Information.get('username');
  final url = 'http://210.26.0.114:9090/mdedu/remote/';
  final body = {
    'params':
        '{"loginId":"$username","pageNum":1,"pageSize":10,"target_app":"mdqn","type":"over","userType":"student","user_code":"$username","user_type":"student"}',
    'service': 'courseService',
    'method': 'searchMine',
  };
  try {
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> datas = jsonResponse['datas'];
      List<ClassEndStudyList> ClassEndStudyInformationList = [];
      for (final data in datas) {
        String c_course_id = data['course_id'].toString();
        String c_name = data['name'].toString();
        String c_duration = data['duration'].toString();
        String c_course_type = data['course_type'].toString();
        String c_study_status_display = data['study_status_display'];

        String c_learnt_duration = data['learnt_duration'].toString();
        String c_plan_id = data['plan_id'].toString();
        ClassEndStudyInformationList.add(ClassEndStudyList(
          course_id: c_course_id,
          name: c_name,
          duration: c_duration,
          course_type: c_course_type,
          learnt_duration: c_learnt_duration,
          study_status_display: c_study_status_display,
          plan_id: c_plan_id,
        ));
      }
      return ClassEndStudyInformationList;
    } else {
      print('Error: ${response.statusCode}');
      print('Response: ${response.body}');
      return [];
      //不知道接口上面时候失效，抛出异常弹窗
    }
  } catch (e) {
    //超时弹窗
    return [];
  }
}

//课程详细信息，获取课程sectionId
Future<String> ClassSectionId(String course_id, String plan_id) async {
  var Information = Hive.box('DataBox');
  String? username = Information.get('username');
  final url = 'http://210.26.0.114:9090/mdedu/remote/';
  final body = {
    'method': 'search',
    'service': 'sectionService',
    'params':
        '{"course_id":"$course_id","loginId":"$username","pageNum":1,"pageSize":1,"plan_id":"$plan_id","userType":"student","user_code":"$username","user_type":"student"}'
  };
  try {
    final response = await http.post(
      Uri.parse(url),
      body: body,
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonMap = json.decode(response.body);
      String sectionId = jsonMap["datas"][0]["section_id"];
      print(sectionId);
      return sectionId;
    } else {
      print("获取失败");
      return 'NO';

      //错误弹窗
    }
  } catch (e) {
    //超时弹窗
    print("获取失败");
    return 'NO';
  }
}

//
void ShowSuccessSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    behavior: SnackBarBehavior.floating,
    margin: EdgeInsets.fromLTRB(22, 0, 22, 15),
    //backgroundColor: Color.fromARGB(232, 247, 74, 62),
    content: Row(
      children: [
        Icon(
          Icons.link_outlined,
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

//
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

//网络状态
void NetworkStatus() async {}

Future<bool> isXBNUappInternetConnected() async {
  try {
    final response =
        await http.get(Uri.parse('http://210.26.0.114:9090/yrpt/app'));
    return response.statusCode == 200;
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

void InternetConnecte(BuildContext context) async {
  bool isMDQNConnected = await isXBNUappInternetConnected();
  bool isBaiduConnected = await isBaiduInternetConnected();
  if (isBaiduConnected) {
    if (!isMDQNConnected) {
      ShowFalseSnackBar(context, '民大青年服务器连接超时');
    } else {
      ShowSuccessSnackBar(context, '民大青年服务器正常');
    }
  } else {
    ShowFalseSnackBar(context, '无法连接到网络');
    print('无法连接到网络');
  }
}
