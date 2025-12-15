// Import Firebase scripts for messaging
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.0/firebase-messaging-compat.js');

// Initialize Firebase
firebase.initializeApp({
  apiKey: "AIzaSyApepP1qB8X-bnQy3RmXmIW-CEQOA3tnpU",
  authDomain: "qrmenufinder.firebaseapp.com",
  projectId: "qrmenufinder",
  storageBucket: "qrmenufinder.firebasestorage.app",
  messagingSenderId: "874709505685",
  appId: "1:874709505685:web:3b2b1575be532eaee62d9c",
  measurementId: "G-YBQE8YBQE8"
});

// Retrieve Firebase Messaging object
const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage(function(payload) {
  console.log('[firebase-messaging-sw.js] Received background message ', payload);
  
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png'
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});