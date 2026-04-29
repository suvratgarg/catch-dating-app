importScripts('https://www.gstatic.com/firebasejs/12.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/12.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAl271K9YGiYZOEcNgoEwZiOQV0ydpWfrg',
  appId: '1:619661127800:web:b0673ad370947b2f077d8d',
  messagingSenderId: '619661127800',
  projectId: 'catchdates-dev',
  authDomain: 'catchdates-dev.firebaseapp.com',
  storageBucket: 'catchdates-dev.firebasestorage.app',
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
