import 'package:klee/Tools/MoreTools/ClassStudy/StartLearning.dart';
import 'package:flutter/material.dart';

import 'package:klee/Tools/MoreTools/ClassStudy/ClassStudyFunction.dart';

//单独划分：界面-执行（异步）函数-弹窗（记得传context）
//弹窗分为三类：成功-失败-异常
//异常包括接口请求失败
//失败包括网络超时？还是放在异常中？

class ClassListTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // 选项卡的数量
      child: Scaffold(
        appBar: AppBar(
          title: Text("我的课程"),
          bottom: TabBar(
            tabs: [
              Tab(text: "未学习"),
              Tab(text: "已学完"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ClassNoStudyListBody(),
            ClassEndStudyListBody(),
          ],
        ),
      ),
    );
  }
}

class ClassNoStudyListBody extends StatelessWidget {
  const ClassNoStudyListBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenHeight = mediaQueryData.size.height;
    return FutureBuilder<List<ClassNoStudyList>>(
      future: GetNoEndClassList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight / 4.5,
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
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("没有数据"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              ClassNoStudyList classInfo = snapshot.data![index];
              String classStatus = "异常";
              if (classInfo.planStatus != '3') {
                classStatus = "Yes";
              } else {
                classStatus = "No";
              }
              return Container(
                margin: EdgeInsets.fromLTRB(10, 8, 10, 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color.fromARGB(255, 158, 158, 158),
                  ),
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  title: Text(classInfo.name),
                  subtitle: Text(
                    "课程时长: ${classInfo.duration}\n已学时长: ${classInfo.learnt_duration}\n课程状态: ${classInfo.study_status_display}\n是否可以学习:$classStatus",
                  ),
                  children: <Widget>[
                    Divider(),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.end, // Align buttons to the right
                      children: [
                        TextButton(
                          onPressed: (classInfo.planStatus == '2')
                              ? () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          StartLearningPage(
                                        name: classInfo.name,
                                        duration: classInfo.duration,
                                        learnt_duration:
                                            classInfo.learnt_duration,
                                        course_id: classInfo.course_id,
                                        plan_id: classInfo.plan_id,
                                      ),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.5, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.easeInOut;
                                        var tween = Tween(
                                                begin: begin, end: end)
                                            .chain(CurveTween(curve: curve));
                                        var offsetAnimation =
                                            animation.drive(tween);
                                        return SlideTransition(
                                            position: offsetAnimation,
                                            child: child);
                                      },
                                    ),
                                  );
                                  InternetConnecte(context);
                                }
                              : null, // Disable the button if the course status is "未开始"
                          child: Text(
                            "开始学习",
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14.5),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: (classInfo.planStatus == '2')
                                ? Color.fromARGB(0, 255, 255, 255)
                                : Color.fromARGB(54, 158, 158,
                                    158), // Use gray background if disabled
                            minimumSize: Size(80, 40),
                          ),
                        ),
                        SizedBox(
                          width: 25,
                        ),
                      ],
                    ),
                    Divider(),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}

class ClassEndStudyListBody extends StatelessWidget {
  const ClassEndStudyListBody({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenHeight = mediaQueryData.size.height;
    return FutureBuilder<List<ClassEndStudyList>>(
      future: GetEndClassList(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              children: [
                SizedBox(
                  height: screenHeight / 4.5,
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
            ),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("没有数据"));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              ClassEndStudyList classInfo = snapshot.data![index];

              return Container(
                margin: EdgeInsets.fromLTRB(10, 8, 10, 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: const Color.fromARGB(255, 158, 158, 158),
                  ),
                ),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  title: Text(classInfo.name),
                  subtitle: Text(
                    "课程时长: ${classInfo.duration} min\n课程状态: ${classInfo.study_status_display}",
                  ),
                  trailing: Container(width: 0.0, height: 0.0),
                ),
              );
            },
          );
        }
      },
    );
  }
}
