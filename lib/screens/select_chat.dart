import 'package:flutter/material.dart';
import 'package:chat/components/rounded_button.dart';
import 'package:chat/constants.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'chat.dart';
import 'create.dart';

class Select extends StatefulWidget {
  static const String id = 'select';

  @override
  State<StatefulWidget> createState() {
    return SelectState();
  }
}

class SelectState extends State<Select> {
  bool showSpinner = false;
  late String chatId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  chatId = value;
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter the chat ID'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                title: 'Enter',
                color: Colors.lightBlueAccent,
                onPressed: () async {
                  setState(() {
                    showSpinner = true;
                  });
                  final collectionRef = firestore.collection(chatId);
                  final snapshot = await collectionRef.get();
                  if (snapshot.docs.isEmpty) {
                    Alert(
                      context: context,
                      title: 'Ops!',
                      desc: 'Chat does not exist!',
                    ).show();
                    setState(() {
                      showSpinner = false;
                    });
                  }
                  else {
                    try{
                      Navigator.pushNamed(context, Chat.id, arguments: chatId);
                      setState(() {
                        showSpinner = false;
                      });

                    } catch (e) {
                      Alert(
                        context: context,
                        title: 'Ops!',
                        desc: 'An error occured',
                      ).show();
                      setState(() {
                        showSpinner = false;
                      });
                    }
                  }
                },
              ),

              RoundedButton(
                title: 'Create new chat',
                color: Colors.lightBlueAccent,
                onPressed: (){
                  Navigator.pushNamed(context, Create.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
