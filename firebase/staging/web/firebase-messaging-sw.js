importScripts('https://www.gstatic.com/firebasejs/12.12.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/12.12.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyAclOdcAenSath18ZsE5HzejY6HDb6sycA',
  appId: '1:822303414140:web:6c5d5c7179dcd8f60c76f9',
  messagingSenderId: '822303414140',
  projectId: 'catchdates-staging',
  authDomain: 'catchdates-staging.firebaseapp.com',
  storageBucket: 'catchdates-staging.firebasestorage.app',
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
