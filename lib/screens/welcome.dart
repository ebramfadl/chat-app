import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chat/components/rounded_button.dart';

class Welcome extends StatefulWidget{
  static const String id = 'welcome';

  @override
  State<StatefulWidget> createState() {
    return WelcomeState();
  }
}

class WelcomeState extends State<Welcome> with SingleTickerProviderStateMixin{

  late AnimationController controller;
  late Animation animation;

  @override
  void initState(){
    super.initState();

    controller = AnimationController(duration: Duration(seconds: 1),vsync: this);
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white).animate(controller);
    controller.forward();
    controller.addListener(() {
      setState(() {

      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: animation.value,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Hero(
                  tag: 'logo',
                  child: Container(
                    child: Image.asset('images/logo.png'),
                    height: 60,
                  ),
                ),
                TypewriterAnimatedTextKit(
                  text: ['Chat'],
                  textStyle: TextStyle(
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 48,
            ),
            RoundedButton(
              title: 'Login',
              color: Colors.blueAccent,
              onPressed: (){
                Navigator.pushNamed(context, Login.id);
              },
            ),
            RoundedButton(
              title: 'Register',
              color: Colors.blueAccent,
              onPressed: (){
                Navigator.pushNamed(context, Registration.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}