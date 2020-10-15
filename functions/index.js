const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();
exports.myFunction = functions.firestore
    .document('chat/{chatRoomId}/{chatRoomId}/{message}')
    .onCreate((snapshot, context) => {
        console.log(snapshot.data());
        return admin.messaging().sendToTopic('chat', {
            notification: {
                title: snapshot.data().userName,
                body: snapshot.data().text,
                sound: 'default',
                clickAction: 'FLUTTER_NOTIFICATION_CLICK',
            }
        });
    });