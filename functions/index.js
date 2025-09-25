const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

exports.sendNotification = functions.https.onCall(async (data, context) => {
  const token = data?.token;
  const topic = data?.topic;
  const notification = data?.notification;
  const payloadData = sanitizeData(data?.data);

  if (!token && !topic) {
    throw new functions.https.HttpsError('invalid-argument', 'Provide token or topic');
  }

  const message = {
    ...(token ? { token } : { topic }),
    notification: notification || undefined,
    data: payloadData,
    android: {
      priority: 'high',
      notification: notification ? {
        channelId: 'admin_my_store_default',
        clickAction: 'FLUTTER_NOTIFICATION_CLICK',
      } : undefined,
    },
    apns: {
      payload: {
        aps: {
          sound: 'default',
          'content-available': 1,
        },
      },
    },
    webpush: {
      notification: notification || undefined,
      fcmOptions: { link: '/' },
    },
  };

  const id = await admin.messaging().send(message);
  return { id };
});

function sanitizeData(obj) {
  if (!obj) return {};
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v == null) continue;
    out[k] = String(v);
  }
  return out;
}
