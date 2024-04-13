import 'dart:async';
import 'package:whatsapp_web/model/user_model.dart';
import 'package:whatsapp_web/provider/provider_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecentChats extends StatefulWidget {
  const RecentChats({super.key});

  @override
  State<RecentChats> createState() => _RecentChatsState();
} 

class _RecentChatsState extends State<RecentChats> {
  late UserModel fromUserData;
  final streamController = StreamController<QuerySnapshot>.broadcast();
  late StreamSubscription streamSubscriptionChats;

  chatListener() {
    final streamRecentChats = FirebaseFirestore.instance.collection('chats_web')
    .doc(fromUserData.uid).collection('lastMessage').snapshots();

    streamSubscriptionChats = streamRecentChats.listen((newMessageData) {
      streamController.add(newMessageData);
    });
  }

  loadInitialData(){
    User? currentFirebaseUser = FirebaseAuth.instance.currentUser;

    if (currentFirebaseUser != null) {
      String userID = currentFirebaseUser.uid;
      String name = currentFirebaseUser.displayName ?? "";
      String email = currentFirebaseUser.email ?? "";
      String password =  "";
      String imageProfile = currentFirebaseUser.photoURL ?? "";

      fromUserData = UserModel(
        userID, name, email, password, imageProfile: imageProfile);
    }
    chatListener();
  }
  
  @override
  void initState() {
      super.initState();
      loadInitialData();
  }

  @override
  void dispose() {
    streamSubscriptionChats.cancel();
     super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: streamController.stream, 
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          return const Center(
                child: Column(
                  children: [
                    Text('Loading data...'),
                    SizedBox(height: 4),
                    CircularProgressIndicator()
                  ]));
          case ConnectionState.active:
          case ConnectionState.done:
          if(snapshot.hasError) {
            return const Center(
                  child: Text('Error occurred.'),
                );
          } else {
            QuerySnapshot snapshotData = snapshot.data as QuerySnapshot;
            List<DocumentSnapshot> recentChatsList = snapshotData.docs.toList();
            
            return ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider(
                  color: Colors.grey,
                  thickness: 0.3 
                );
              },
              itemCount: recentChatsList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot chat = recentChatsList[index];
                String toUserImage = chat['toUserImage'];
                String toUserName = chat['toUsername'];
                String toUserEmail = chat['toUserEmail'];
                String lastMessage = chat['lastMessage'];
                String toUserID = chat['toUserID'];

                final toUserData = UserModel(toUserID, toUserName, toUserEmail, "", imageProfile: toUserImage);

                return ListTile(
                  onTap: (){
                    context.read<ProviderChat>().toUserData = toUserData;
              //      Navigator.pushNamed(context, '/messages', arguments: toUserData);
                  },
                  title: Text(toUserData.name, style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 17)),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(
                        toUserData.imageProfile)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                           Text(toUserData.email, 
                              style: TextStyle(fontWeight: FontWeight.w500, 
                              color: Colors.grey.shade600)),
                          Text(lastMessage.toString().contains('.jpg') ?
                          'Sent you an image.' : 
                            lastMessage.toString().contains('.docx') ||
                            lastMessage.toString().contains('.pdf') || 
                            lastMessage.toString().contains('.mp4') ||
                            lastMessage.toString().contains('.mp3') ||
                            lastMessage.toString().contains('.xlsx') ||
                            lastMessage.toString().contains('.pptx')  ? 
                            'Sent you a file.' : lastMessage.toString(),
                            style: TextStyle(fontWeight: FontWeight.w500, 
                            color: Colors.grey.shade600), 
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                            ] ),
                          contentPadding: const EdgeInsets.all(5)
                );
              },
            );
          }
        }
      });
  }
}