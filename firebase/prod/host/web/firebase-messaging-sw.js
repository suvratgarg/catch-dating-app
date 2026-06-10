importScripts('https://www.gstatic.com/firebasejs/12.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/12.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBZUkQpo1xw1GYOLhdRh5RbVdy0wq8A644',
  appId: '1:574779808785:web:65a9fe67d7f19ed78ea5b0',
  messagingSenderId: '574779808785',
  projectId: 'catch-dating-app-64e51',
  authDomain: 'catch-dating-app-64e51.firebaseapp.com',
  storageBucket: 'catch-dating-app-64e51.firebasestorage.app',
  measurementId: 'G-YMWCDQKJJ0',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notification = payload.notification ?? {};
  const title = notification.title ?? 'Catch';
  const options = {
    body: notification.body,
    icon: '/icons/Icon-192.png',
    data: payload.data ?? {},
  };

  self.registration.showNotification(title, options);
});
