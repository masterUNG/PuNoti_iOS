import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Home extends StatefulWidget {
  const Home({
    Key? key,
  }) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  InitializationSettings? initializationSettings;
  IOSInitializationSettings? iosInitializationSettings;

  @override
  void initState() {
    super.initState();
    setupLocalNoti();
    setupAboutNotiFiebase();
  }

  Future<void> setupAboutNotiFiebase() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
    String? token = await firebaseMessaging.getToken();
    print('token ==> $token');

    NotificationSettings notificationSettings =
        await firebaseMessaging.requestPermission();
    print(
        'notificationSetting ==> ${notificationSettings.authorizationStatus}');
  }

  Future<void> setupLocalNoti() async {
    iosInitializationSettings = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNoti);

    initializationSettings = InitializationSettings(
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings!,
      onSelectNotification: onSelectNoti,
    );

    //for App On
    FirebaseMessaging.onMessage.listen((event) {
      print('App On');
      processShowLocalNoti(title: event.notification!.title!, message: event.notification!.body!);
    });

    //for App Off
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print('App Off');
      processShowLocalNoti(title: event.notification!.title!, message: event.notification!.body!);
    });
  }

  Future<void> onSelectNoti(String? string) async {
    print('You tap Noti');
  }

  Future onDidReceiveLocalNoti(
      int id, String? title, String? body, String? payload) async {
    return CupertinoAlertDialog(
      title: Text(title!),
      content: Text(body!),
      actions: [
        CupertinoDialogAction(
          child: const Text('OK'),
          isDefaultAction: true,
          onPressed: () {},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ElevatedButton(
        onPressed: () => processShowLocalNoti(title: 'Test', message: 'Message Test'),
        child: const Text('Test Local Noti'),
      ),
    );
  }

  Future<void> processShowLocalNoti({required String title, required String message}) async {
    print('processShowNoti Work');
    IOSNotificationDetails iosNotificationDetails =
        const IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(iOS: iosNotificationDetails);

    await flutterLocalNotificationsPlugin
        .show(1, title, message, notificationDetails)
        .then((value) {
      print('Success');
    })
        // ignore: invalid_return_type_for_catch_error
        .catchError((onError) => print('onError ==>> ${onError.toString()}'));
  }
}
