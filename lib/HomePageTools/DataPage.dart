import 'dart:convert';
//import 'package:app_1/homepagetools/utils.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

final now = DateTime.now();
String SelectedDay = DateFormat('yyyy-MM-dd').format(now);

class ScheduleEvent {
  final String title;
  final String address;
  final String remark;
  final String startTime;
  final String endTime;
  final String message;

  ScheduleEvent({
    required this.title,
    required this.address,
    required this.remark,
    required this.startTime,
    required this.endTime,
    required this.message,
  });

  factory ScheduleEvent.fromJson(Map<String, dynamic> json) {
    return ScheduleEvent(
      title: json['title'] as String? ?? '', // 添加空值检查和默认值
      address: json['address'] as String? ?? '', // 添加空值检查和默认值
      remark: json['remark'] as String? ?? '', // 添加空值检查和默认值
      startTime: json['startTime'] as String? ?? '', // 添加空值检查和默认值
      endTime: json['endTime'] as String? ?? '', // 添加空值检查和默认值
      message: json['message'] as String? ?? '', // 添加空值检查和默认值
    );
  }
}

//提取老师
String extractTeacherInfo(String remark) {
  // 使用正则表达式来匹配 "任课教师：xxx" 格式的内容
  final RegExp regExp = RegExp(r'任课教师：(.*?)(,|$)');
  // 尝试在 remark 中查找匹配的内容
  final Match? match = regExp.firstMatch(remark);
  // 如果找到匹配项，则提取匹配的内容
  if (match != null) {
    final extractedInfo = '任课教师：' + match.group(1)!;
    return extractedInfo; // 返回提取的内容，如果为空则返回空字符串
  } else {
    return ''; // 如果没有匹配项，返回空字符串
  }
}

Future<List<Course>> fetchData() async {
  Future<String> getIdToken() async {
    SharedPreferences Token = await SharedPreferences.getInstance();
    String? idToken = Token.getString('TokenID');
    return idToken ?? ''; // 如果没有找到ID Token，则返回一个默认值
  }

  final formattedDate = SelectedDay;
  final idToken = await getIdToken();
  final baseUrl =
      'https://portal.xbmu.edu.cn/portal-api/v1/calendar/share/schedule/getEvents';
  final startDate = formattedDate;
  final endDate = formattedDate;
  final requestUrl =
      Uri.parse('$baseUrl?startDate=$startDate&endDate=$endDate');
  //print(requestUrl);
  final response = await http.get(
    requestUrl,
    headers: {
      'X-Id-Token': idToken,
    },
  );

  if (response.statusCode == 200) {
    // 请求成功
    //开始判断
    final jsonData = json.decode(utf8.decode(response.bodyBytes));
    final GetState = jsonData['message'] as String;
    if (GetState != 'SUCCESS') {
      return [
        Course(name: "这一天貌似没有课", time: "", location: "", teacher: ""),
      ];
    } else {
      final eventList = jsonData['data']['schedule'][formattedDate]
          ['calendarList'] as List<dynamic>;

      List<Course> courses = [];
      for (final event in eventList) {
        final scheduleEvent = ScheduleEvent.fromJson(event);
        final teacherInfo = extractTeacherInfo(scheduleEvent.remark);
        courses.add(
          Course(
            name: scheduleEvent.title,
            time: '${scheduleEvent.startTime} - ${scheduleEvent.endTime}',
            location: scheduleEvent.address,
            teacher: teacherInfo,
          ),
        );
      }
      return courses;
    }
  } else {
    print('请求失败: ${response.statusCode}');
    return [
      Course(name: "这一天貌似没有课", time: "", location: "", teacher: ""),
    ];
  }
}

//课表
class Course {
  final String name;
  final String time;
  final String location;
  final String teacher;

  Course(
      {required this.name,
      required this.time,
      required this.location,
      required this.teacher});
}

class DailySchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder<List<Course>>(
        future: fetchData(), // 异步获取课程数据
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 数据未准备好时显示加载指示器
            return Center(
              child: Image.asset(
                "images/mona-loading-default.gif",
                height: 180,
              ),
            );
          } else if (snapshot.hasError) {
            // 如果出现错误，显示错误消息
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            // 数据准备好时显示课程列表
            final dailyCourses = snapshot.data;
            return ListView.builder(
              itemCount: dailyCourses?.length,
              itemBuilder: (context, index) {
                final course = dailyCourses![index];
                return Card(
                  margin: EdgeInsets.fromLTRB(15, 10, 15, 5),
                  child: ListTile(
                    contentPadding: EdgeInsets.fromLTRB(15, 5, 10, 5),
                    title: Text(course.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(course.time),
                        Text(course.teacher),
                        Text(course.location),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class TableEvents extends StatefulWidget {
  @override
  _TableEventsState createState() => _TableEventsState();
}

class _TableEventsState extends State<TableEvents> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null;
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });
    }
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDay);
    SelectedDay = formattedDate;
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '日程',
          style: TextStyle(
              color: Color.fromARGB(150, 40, 40, 40),
              //fontFamily: "font2",
              fontSize: 20,
              fontWeight: FontWeight.w700),
        ),
        backgroundColor:
            Color.fromARGB(25, 0, 0, 0), // Updated background color
        elevation: 0,
        iconTheme: IconThemeData(
          color: const Color.fromARGB(
              255, 153, 153, 153), // Set the arrow color to gray
        ),
      ),
      body: ListView(
        // padding: EdgeInsets.all(2),
        children: [
          TableCalendar(
            locale: 'zh_CN',
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            rangeStartDay: _rangeStart,
            rangeEndDay: _rangeEnd,
            calendarFormat: _calendarFormat,
            rangeSelectionMode: _rangeSelectionMode,
            //  eventLoader: _getEventsForDay,//图标下的小圆点
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              // Use `CalendarStyle` to customize the UI
              outsideDaysVisible: false,
            ),
            onDaySelected: _onDaySelected,
            onRangeSelected: _onRangeSelected,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 550,
            child: DailySchedulePage(),
          )
        ],
      ),
    );
  }
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, 8, 28);
final kLastDay = DateTime(kToday.year + 1, 1, 14);
