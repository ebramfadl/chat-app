import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../api.dart';

final firestore = FirebaseFirestore.instance;
final firebaseMessaging = FirebaseMessaging.instance;
late User loggedInUser;
late String chatId;

class Chat extends StatefulWidget {
  static const String id = 'chat';

  @override
  State<StatefulWidget> createState() {
    return ChatState();
  }
}

class ChatState extends State<Chat> {
  final messageTextController = TextEditingController();
  final auth = FirebaseAuth.instance;
  late String messageText;


  void setupPushNotifications() async {
    final fcm = FirebaseMessaging.instance;

    await fcm.requestPermission();

    fcm.subscribeToTopic(chatId);
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    setupPushNotifications();
  }

  // void initFirebaseMessaging() {
  //   firebaseMessaging.subscribeToTopic('chat_$chatId'); // Subscribe to a topic based on your chat room or chat ID
  //
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print("onMessage: $message");
  //     // Handle the notification when the app is in the foreground
  //     // You can show a local notification or update your UI here
  //   });
  //
  //   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  //     print("onMessageOpenedApp: $message");
  //     // Handle the notification when the app is in the background and is opened by tapping the notification
  //     // You can navigate to the chat screen with the provided chatId
  //     final payloadChatId = message.data['chatId'];
  //     if (payloadChatId != null) {
  //       Navigator.pushNamed(context, Chat.id, arguments: payloadChatId);
  //     }
  //   });
  //
  //   // Optional: Handle background messages using onBackgroundMessage
  //   FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  // }
  //
  // Future<void> handleBackgroundMessage(RemoteMessage message) async {
  //   print("Handling background message: $message");
  //   // Handle the notification when the app is terminated or in the background
  //   // You can navigate to the chat screen with the provided chatId
  //   final payloadChatId = message.data['chatId'];
  //   if (payloadChatId != null) {
  //     Navigator.pushNamed(context, Chat.id, arguments: payloadChatId);
  //   }
  // }


  // void listenNotifications() => NotificationApi.onNotifications.stream.listen(onClickedNotification);
  // void onClickedNotification(String? payload) => Navigator.pushNamed(context, Chat.id, arguments: payload);

  void getCurrentUser() async {
    try {
      final user = await auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    final message = ModalRoute.of(context)!.settings.arguments; // to access the notification message
    chatId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessagesStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),

                  //gallery image
                  Expanded(
                    child: IconButton(
                      onPressed: () async{
                        final ImagePicker picker = ImagePicker();
                        // Picking multiple images
                        final List<XFile> images =
                        await picker.pickMultiImage(imageQuality: 70);
                        // uploading & sending image one by one
                        for (var i in images) {
                          await Api.sendChatImage(File(i.path),chatId,loggedInUser);
                        }
                      },
                      icon: const Icon(
                          Icons.image,
                          color: Colors.blueAccent,
                          size: 26,
                      ),
                    ),
                  ),

                  //camera image
                  Expanded(
                    child: IconButton(
                      onPressed: () async{
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          await Api.sendChatImage(File(image.path),chatId,loggedInUser);
                        }
                      },
                      icon: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.blueAccent,
                        size: 26,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        messageTextController.clear();
                        firestore.collection(chatId).add({
                          'text': messageText,
                          'sender': loggedInUser.email,
                          'type': 'text',
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        // }).then((_) {
                        //   // Send a notification after adding the message to Firestore
                        //   NotificationApi.showNotification(
                        //     title: 'New Message',
                        //     body: '$messageText from ${loggedInUser.email}',
                        //     payload: chatId,
                        //     // Set other optional parameters if needed
                        //   );
                        // });
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    chatId = ModalRoute.of(context)!.settings.arguments as String;
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection(chatId).orderBy('timestamp',descending: false).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.docs.isEmpty == true) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages = snapshot.data?.docs.reversed;
        List<MessageBubble> messageBubbles = [];
        for (var message in messages!) {
          final messageData = message.data() as Map;
          final messageText = messageData['text'];
          final messageSender = messageData['sender'];
          final messageType = messageData['type'];
          final currentUser = loggedInUser.email;
          final messageBubble = MessageBubble(
            sender: messageSender,
            text: messageText,
            type: messageType,
            isMe: currentUser == messageSender,
          );
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  MessageBubble({required this.sender, required this.text, required this.isMe, required this.type});

  final String sender;
  final String text;
  final String type;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                    bottomRight: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
            elevation: 5,
            color: isMe ? Colors.lightBlueAccent : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 20),
              child: type == 'text'? Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black54,
                  fontSize: 15,
                ),
              ):Image.network(text),
            ),
          ),
        ],
      ),
    );
  }
}
