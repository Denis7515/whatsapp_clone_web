/*
import 'package:whatsapp_web/chat_messages_area/chats_area/contacts_list.dart';
import 'package:whatsapp_web/chat_messages_area/chats_area/recent_chats.dart';
import 'package:whatsapp_web/default%20colors/default_colors.dart';
import 'package:whatsapp_web/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatsArea extends StatelessWidget {
  final UserModel currentUserData;
  const ChatsArea({super.key, required this.currentUserData});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Container(
        decoration: const BoxDecoration(
          color: DefaultColors.lightBarBackgroundColor,
          border: Border(
            right: BorderSide(color: DefaultColors.backgroundColor, width: 1),
          ),
        ),
        child: Column(
          children: [
            // HEADER
            Container(
              color: DefaultColors.backgroundColor,
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey,
                    backgroundImage:
                        NetworkImage(currentUserData.imageProfile)),
                const SizedBox(width: 13),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(currentUserData.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                    Text(currentUserData.email,
                        style: TextStyle(fontWeight: FontWeight.w500,
                            color: Colors.grey.shade600)),
                  ],
                ),
                const Spacer(),
                IconButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut().then((value) {
                        Navigator.pushReplacementNamed(context, '/login');
                      });
                    },
                    icon: const Icon(Icons.logout_outlined)),
              ]),
            ),
            const TabBar(
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              indicatorColor: DefaultColors.primaryColor,
              indicatorWeight: 4,
              labelStyle: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, 
              ),
              tabs: [
                Tab(text: 'Chats'),
                Tab(text: 'Contacts'),
                ]),
                Expanded(child: Container(
                  color: Colors.white,
                  child: const TabBarView(children: [
                    // CHATS 
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: RecentChats(),
                    ),
                    // CONTACTS
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: ContactsList(),
                    ),
                   ]),
                ))
          ]
        ),
      ),
    );
  }
} */
