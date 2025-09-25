/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.12.5/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyDYoQedQ2t6uqJRysytvrku3rUeDCbfMo0',
  appId: '1:501773870758:web:75f44307f3daab4e723667',
  messagingSenderId: '501773870758',
  projectId: 'my-store-41300',
  authDomain: 'my-store-41300.firebaseapp.com',
  storageBucket: 'my-store-41300.appspot.com'
});

// Initialize messaging. Background notifications will be handled by the browser
// when the message contains a `notification` payload.
firebase.messaging();
