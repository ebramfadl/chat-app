const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotification = functions.firestore
  .document('{chatId}/{messageId}')
//  .document('chat/{messageId}')
  .onCreate((snapshot, context) => {
    const messageData = snapshot.data();
    const chatId = context.params.chatId;

    const payload = {
      notification: {
        title: chatId,
        body: messageData["text"],
      },
      data: {
        chatId: chatId, // You can include the chatId or other data in the notification payload
      },
      topic: `chat_${chatId}`, // Send the notification to the specific chat room (topic)
    };

    return admin.messaging().sendToTopic("chat",{payload});
  });



//  exports.sendChatNotification = functions.firestore
//    .document('chat/{chatId}/{messageId}')
//    .onCreate((snap, context) => {
//      const messageData = snap.data();
//      const recipientUserId = messageData.recipientUserId;
//
//      // Get the FCM token of the recipient user
//      // You should have a database or Firestore collection to store user FCM tokens
//      return admin.firestore().doc(`userTokens/${recipientUserId}`).get()
//        .then((tokenDoc) => {
//          const recipientToken = tokenDoc.data().fcmToken;
//
//          // Send the push notification to the recipient's device
//          const payload = {
//            notification: {
//              title: 'New Message',
//              body: 'You have a new chat message!',
//            },
//          };
//
//          return admin.messaging().sendToDevice(recipientToken, payload);
//        });
//    });