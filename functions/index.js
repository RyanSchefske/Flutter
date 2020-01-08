const functions = require('firebase-functions');

const admin = require('firebase-admin');
admin.initializeApp();

exports.sendLikeNotification = functions.https.onCall(event => {
  const username = event.username;
  const payload = {
    notification: {
      body: username.concat(' liked your post!'),
      badge: '1',
      sound: 'default',
    }
  };

  const registrationToken = event.text;
  return admin.messaging().sendToDevice(registrationToken, payload).then(response => {
    return null;
  });
});


exports.sendFollowNotification = functions.https.onCall(event => {
  const username = event.username;
  const payload = {
    notification: {
      body: username.concat(' followed you!'),
      badge: '1',
      sound: 'default',
    }
  };

  const registrationToken = event.text;
  return admin.messaging().sendToDevice(registrationToken, payload).then(response => {
    return null;
  });
});
