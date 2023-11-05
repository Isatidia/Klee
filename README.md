# Klee

[![flutter](https://img.shields.io/badge/flutter-3.13.9-blue)](https://flutter.dev/) 

使用flutter构建的西北民族大学综合软件，支持的软件包括民大一点通，民大青年

后端依赖于民大一点通，民大青年，[api.isatidis.top](https://github.com/Isatidia/Klee-3DES)

请使用民大一点通账号登录

目前支持Android，Windows端；其他端暂未验证可用性

欢迎提出问题和功能建议

请尽量使用官方App

## 已实现的功能
#### 民大一点通：
- 密码登录
- 付款码
- 个人信息
- 个人课表
#### 民大青年：
- 活动报名
- 活动签到

## 正在开发中
#### 民大一点通
 - 验证码登录
#### 民大青年
 - 我的报名-已报名活动状态
 - 我的签到-已签到活动状态
 - 我的课程-中华文化大课堂
#### 民大教务：
 - 新建文件夹
### 其他：欢迎提出建议
- [QQ群:](http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=jBzF3oGkYB4v6_ILyh3IMBTePJs2x2E3&authKey=Xx608ZC7WxTRKj3RGI628sBTVhHFe2i6bfVEwdnii5lmxkmsZLUFP%2Bnzn3fk%2F0QU&noverify=0&group_code=929874130/)929874130 

## 从源代码构建
请参考[https://docs.flutter.dev/](https://docs.flutter.dev/)

使用**Stable频道最新版**的[Flutter SDK](https://docs.flutter.dev/get-started/install)

[![Readme Card](https://github-readme-stats.vercel.app/api/pin/?username=Isatidia&repo=Klee-3DES)](https://github.com/Isatidia/Klee-3DES)

## Thanks

### dependencies
- [flutter](https://flutter.dev/): 
- [dio](https://pub.dev/packages/dio): Dart HTTP客户端，用于进行网络请求
- [shared_preferences](https://pub.dev/packages/shared_preferences): 在本地存储和检索小型键值
- [qr_flutter](https://pub.dev/packages/qr_flutter): 生成QR码
- [hive](https://pub.dev/packages/hive): 轻量级的键值对数据库，用于本地数据存储
- [hive_flutter](https://pub.dev/packages/hive_flutter): hive数据库的Flutter集成
- [url_launcher](https://pub.dev/packages/url_launcher): 用于在设备上打开URLs
- [timelines](https://pub.dev/packages/timelines): 用于创建时间轴视图
- [convert](https://pub.dev/packages/convert): 用于处理数据的编码和解码
- [intl](https://pub.dev/packages/intl): 用于国际化和本地化的Flutter插件
- [table_calendar](https://pub.dev/packages/table_calendar): 用于创建日历视图
- [folding_cell](https://pub.dev/packages/folding_cell): 可折叠单元格的插件
- [motion_toast](https://pub.dev/packages/motion_toast): 用于显示动画提示信息
- [fluttertoast](https://pub.dev/packages/fluttertoast): 显示Toast消息

## 屏幕截图

本项目仍在持续开发中, 以下屏幕截图可能并非来自最新版本
### 手机
<img src="https://cc.isatidis.top/screenshots/1.jpg" style="width: 200px"><img src="https://cc.isatidis.top/screenshots/2.jpg" style="width: 200px"><img src="https://cc.isatidis.top/screenshots/3.jpg" style="width: 200px"><img src="https://cc.isatidis.top/screenshots/4.jpg" style="width: 200px"><img src="https://cc.isatidis.top/screenshots/5.jpg" style="width: 200px">
## 已知问题
 - 在登录界面登录成功后，由于继承了父组件的属性，返回主页会自动唤起键盘
 - 启动应用有概率长时间白屏，如无法使用，请联系作者
