import 'package:whatsapp_web/default%20colors/default_colors.dart';
import 'package:whatsapp_web/model/user_model.dart';
import 'package:whatsapp_web/widgets/messages_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatefulWidget {
  final UserModel toUserData;
  
  const MessagesPage(this.toUserData, {
    Key? key }) : super (key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {

  late UserModel toUser;
  late UserModel fromUser;

  getUserData() {
    toUser = widget.toUserData;

    User? loggedInUser = FirebaseAuth.instance.currentUser;
    if(loggedInUser != null) {
      fromUser = UserModel(
        loggedInUser.uid,
        loggedInUser.displayName ?? "",
        loggedInUser.email ?? "",
        "",
        imageProfile: loggedInUser.photoURL ?? ""
      );
    } 
  }

  @override
  void initState() {
     super.initState();
     getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: DefaultColors.primaryColor,
        centerTitle: true,
        title: Row(children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey,
            backgroundImage: NetworkImage(toUser.imageProfile),
          ),
          const SizedBox(width: 12),
          Text(toUser.name,
                style: const TextStyle(fontWeight: FontWeight.w600, 
                fontSize: 15, color: Colors.white)),
        ]),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.more_vert, color: Colors.white),
          )
        ],
      ),
      body: MessagesWidget(
        fromUserData: fromUser,
        toUserData: toUser),
    );
  }
}