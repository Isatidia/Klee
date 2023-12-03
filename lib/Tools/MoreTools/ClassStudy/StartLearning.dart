import 'dart:async';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:klee/Tools/MoreTools/ClassStudy/ClassStudyFunction.dart';

class StartLearningPage extends StatefulWidget {
  StartLearningPage({
    required this.name,
    required this.learnt_duration,
    required this.duration,
    required this.course_id,
    required this.plan_id,
  });
  final String name;
  final String learnt_duration;
  final String duration;
  final String course_id;
  final String plan_id;
  @override
  _StartLearningPageState createState() => _StartLearningPageState();
}

class _StartLearningPageState extends State<StartLearningPage> {
  late Map<String, dynamic> customHeaders;
  late WebSocketChannel _channel;
  final List<String> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final RoundedLoadingButtonController _btnController =
      RoundedLoadingButtonController();
  String classSection_Id = '2233';
  void _studyStart() async {
    print('确认学习！');
    var Information = Hive.box('DataBox');
    String? username = Information.get('username');
    if (classSection_Id != '2233') {
      Timer(Duration(milliseconds: 200), () {
        _channel.sink.add(
            "{type:'doing', from:'', data:{planId:'${widget.plan_id}',courseId:'${widget.course_id}',sectionId:'$classSection_Id',traineeCode:'$username',traineeType:'student'}}");
      });
    } else {
      String classSection_Id =
          await ClassSectionId(widget.course_id, widget.plan_id);
      Timer(Duration(milliseconds: 200), () {
        _channel.sink.add(
            "{type:'doing', from:'', data:{planId:'${widget.plan_id}',courseId:'${widget.course_id}',sectionId:'$classSection_Id',traineeCode:'$username',traineeType:'student'}}");
      });
    }
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void falseresetButton(RoundedLoadingButtonController controller) async {
    Timer(Duration(seconds: 2), () {
      controller.reset();
    });
  }

  void resetButton(RoundedLoadingButtonController controller) async {
    Timer(Duration(milliseconds: 500), () {
      controller.reset();
    });
  }

  @override
  void initState() {
    super.initState();
    _btnController.stateStream.listen((value) {
      print(value);
    });

    customHeaders = {
      'Pragma': 'no-cache',
      'Cache-Control': 'no-cache',
      'User-Agent': 'klee',
    };

    _channel = _createWebSocketChannel();
    DateTime now = DateTime.now();
    String formattedDateTime = DateFormat('E MMMd y HH:mm:ss').format(now);
    _channel.sink.add(
        "{type:'TEST_LINK', data:'消息发出时间$formattedDateTime GMT+0800 (中国标准时间)'}");
  }

  WebSocketChannel _createWebSocketChannel() {
    var Information = Hive.box('DataBox');
    String? username = Information.get('username');
    try {
      return IOWebSocketChannel.connect(
        Uri.parse(
            'ws://210.26.0.114:9090/mdedu/websocket/courseStudyWebSocket/student/$username'),
        headers: customHeaders,
      );
    } catch (e) {
      print('Error creating WebSocket channel: $e');
      rethrow;
    }
  }

  String ExtractMassage(
      String massage, RoundedLoadingButtonController controller) {
    if (!massage.isEmpty) {
      Map<String, dynamic> jsonMassage = json.decode(massage);
      String ConnectionType = jsonMassage['type'];
      if (ConnectionType != 'doing') {
        String ConversationInformation = jsonMassage['data'];
        return ConversationInformation;
      } else {
        bool doingState = jsonMassage['success'];
        if (doingState) {
          String studyStatus =
              jsonMassage['data']['traineeSection'][0]['status'];
          if (studyStatus == '02') {
            String learntDuration = jsonMassage['data']['traineeSection'][0]
                    ['learnt_duration']
                .toString();
            _studyStart();
            return "学习成功，最新学习时长:$learntDuration";
          } else if (studyStatus == '03') {
            _channel.sink.close();
            controller.success();
            return "学习完成";
          }
          return "！出错，正常来说你不会看见这个信息，若看到，请联系开发者！";
        } else {
          String dataMassage = jsonMassage['data'];
          _channel.sink.close();
          controller.error();
          falseresetButton(controller);
          return dataMassage;
        }
      }
    } else {
      return '测试连接中...';
    }
    // return massage;
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;

    return Scaffold(
        appBar: AppBar(
          title: Text('课程学习'),
          actions: <Widget>[
            SizedBox(
              width: 15,
            )
          ],
        ),
        body: ListView(
          children: [
            SizedBox(
              height: 10,
            ),
            Container(
              //height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: (screenWidth * 1 / 20),
                  ),
                  Container(
                    width: (screenWidth * 7 / 10),
                    child: Card(
                      // 卡片内容
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.book_outlined),
                            title: Text(widget.name),
                            subtitle: Text(
                                '总时长:${widget.duration}\n初始已学时长:${widget.learnt_duration}'),
                          ),
                          ButtonBar(
                            children: <Widget>[],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: (screenWidth * 2 / 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RoundedLoadingButton(
                          height: 70,
                          loaderSize: 40,
                          loaderStrokeWidth: 2.4,
                          successIcon: Icons.cloud_done,
                          failedIcon: Icons.cloud_off,
                          child: Text('开始学习',
                              style: TextStyle(color: Colors.white)),
                          controller: _btnController,
                          onPressed: () => _studyStart(),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: (screenHeight - 200) * 9 / 10,
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              margin: EdgeInsets.only(left: 30, right: 30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(40, 40, 40, 40),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder(
                      stream: () async* {
                        yield* _channel.stream;
                      }(),
                      builder: (context, snapshot) {
                        _messages.add(ExtractMassage(
                          snapshot.hasData ? '${snapshot.data}' : '',
                          _btnController,
                        ));
                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                              child: Text(
                                _messages[index],
                                style: TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color.fromARGB(200, 0, 0, 0)),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}  
   // Timer(Duration(seconds: 2), () {
    //   controller.reset();
    // });
// ElevatedButton(
            //   onPressed: () {},
            //   style: ElevatedButton.styleFrom(
            //     padding: EdgeInsets.fromLTRB(14, 4, 14, 4),
            //     backgroundColor: Color.fromARGB(255, 255, 110, 110),
            //     foregroundColor: Color.fromARGB(255, 253, 253, 253),
            //     shadowColor: Color.fromARGB(40, 40, 40, 40),
            //   ),
            //   child: Row(
            //     children: [
            //       Icon(Icons.highlight_off),
            //       SizedBox(width: 4),
            //       Text(
            //         '连接断开',
            //         style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            //       ),
            //     ],
            //   ),
            // ),
  // OutlinedButton(
                        //     style: ButtonStyle(
                        //       shape: MaterialStateProperty.all(
                        //           RoundedRectangleBorder(
                        //               borderRadius: BorderRadius.circular(30))),
                        //     ),
                        //     onPressed: () {
                        //       _btnController.reset();
                        //     },
                        //     child: Text('Reset')),
                        // OutlinedButton(
                        //   style: ButtonStyle(
                        //     shape: MaterialStateProperty.all(
                        //         RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(30))),
                        //   ),
                        //   onPressed: () {
                        //     _btnController.error();
                        //   },
                        //   child: Text('Error'),
                        // ),
                        // OutlinedButton(
                        //   style: ButtonStyle(
                        //     shape: MaterialStateProperty.all(
                        //         RoundedRectangleBorder(
                        //             borderRadius: BorderRadius.circular(30))),
                        //   ),
                        //   onPressed: () {
                        //     _btnController.success();
                        //     print(_btnController.currentState);
                        //   },
                        //   child: Text('Success'),
 