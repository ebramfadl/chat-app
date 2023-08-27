import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chat/screens/welcome.dart';
import 'package:chat/screens/login.dart';
import 'package:chat/screens/registration.dart';
import 'package:chat/screens/chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      },
    );
  }
}