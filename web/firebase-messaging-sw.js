importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/8.4.1/firebase-messaging.js');


  const firebaseConfig = { 
     apiKey: "AIzaSyC4U6De-3ILH8f3ZSliK_Eu8t7xamSaCW8",
     authDomain: "thesocial-786ed.firebaseapp.com",
     projectId: "thesocial-786ed",
     storageBucket: "thesocial-786ed.appspot.com",
     messagingSenderId: "812515365752",
     appId: "1:812515365752:web:0cb0202f4491715f162e8d"
     };
     
  firebase.initializeApp(firebaseConfig);
  const messaging = firebase.messaging();


  messaging.onBackgroundMessage(function(payload) {
    console.log('Received background message ', payload);

    const notificationTitle = payload.notification.title;
    const notificationOptions = {
      body: payload.notification.body,
    };

    self.registration.showNotification(notificationTitle,
      notificationOptions);
  });