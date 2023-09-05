import 'package:chat/api.dart';
import 'package:chat/notification_api.dart';
import 'package:chat/screens/create.dart';
import 'package:chat/screens/select_chat.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat/screens/welcome.dart';
import 'package:chat/screens/login.dart';
import 'package:chat/screens/registration.dart';
import 'package:chat/screens/chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  await Api().initNotifications();
  runApp(FlashChat());
}
class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: Welcome.id,
      routes: {
        Welcome.id: (context) => Welcome(),
        Login.id: (context) => Login(),
        Registration.id: (context) => Registration(),
        Chat.id: (context) => Chat(),
        Select.id: (context) => Select(),
        Create.id: (context) => Create()
      },
    );
  }
}
//
// class MainPage extends StatefulWidget{
//   @override
//   State<StatefulWidget> createState() {
//     return MainPageState();
//   }
// }

// class MainPageState extends State<MainPage>{
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     throw UnimplementedError();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     NotificationApi.init();
//     listenNotifications();
//   }
//
//   void listenNotifications() => NotificationApi.onNotifications.stream.listen(onClickedNotification);
//   void onClickedNotification(String? payload) => Navigator.pushNamed(context, Chat.id, arguments: payload);
// }