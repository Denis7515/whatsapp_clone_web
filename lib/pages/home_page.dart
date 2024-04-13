import 'package:whatsapp_web/chat_messages_area/chats_area/recent_chats.dart';
import 'package:whatsapp_web/chat_messages_area/chats_area/contacts_list.dart';
import 'package:whatsapp_web/chat_messages_area/messages_area.dart';
import 'package:whatsapp_web/default%20colors/default_colors.dart';
import 'package:whatsapp_web/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late UserModel currentUserData;

  readCurrentUserData() async {
    User? currentFirebaseUser = FirebaseAuth.instance.currentUser!;
    if (currentFirebaseUser != null) {
      String uid = currentFirebaseUser.uid;
      String name = currentFirebaseUser.displayName ?? "";
      String email = currentFirebaseUser.email ?? "";
      String password = "";
      String imageProfile = currentFirebaseUser.photoURL ?? "";

      currentUserData =
          UserModel(uid, name, email, password, imageProfile: imageProfile);
    }
  }

  @override
  void initState() {
    super.initState();
    readCurrentUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: DefaultColors.lightBarBackgroundColor,
        child: Stack(
          children: [
            Positioned(
                top: 0,
                child: SizedBox(
                  height: 65,
                  child: Container(
                    color: DefaultColors.lightBarBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('WhatsApp web',
                              style: TextStyle(fontSize: 20)),
                          SizedBox(
                              width: MediaQuery.of(context).size.width / 1.6),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currentUserData.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16),
                                  ),
                                  Text(currentUserData.email,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade600)),
                                ],
                              ),
                              const SizedBox(width: 13),
                              CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey,
                                  backgroundImage: NetworkImage(
                                      currentUserData.imageProfile)),
                                const SizedBox(width: 15),
                              Column(
                                children: [
                                    GestureDetector(
                                      onTap: () async {
                                        await FirebaseAuth.instance.signOut()
                                            .then((value) {
                                          Navigator.pushReplacementNamed(
                                              context, '/login');
                                        });
                                      },
                                      child: Icon(
                                        Icons.logout_outlined,
                                        color: Colors.grey.shade600,
                                      )),
                                      const SizedBox(height: 5),
                                    const Text('LogOut ', style: TextStyle(
                                      fontWeight: FontWeight.w600)),
                                  ],
                              ),
                                
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
            Positioned(
                top: 65,
                child: Container(
                  color: DefaultColors.primaryColor,
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.2,
                )),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.126,
                bottom: MediaQuery.of(context).size.height * 0.03,
                right: MediaQuery.of(context).size.height * 0.03,
                left: MediaQuery.of(context).size.height * 0.03,
                child: Row(
                  children: [
                    // CHAT AREA
                    Expanded(
                      flex: 4,
                      child: DefaultTabController(
                        length: 2,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: DefaultColors.lightBarBackgroundColor,
                            border: Border(
                              right: BorderSide(
                                  color: DefaultColors.backgroundColor,
                                  width: 1),
                            ),
                          ),
                          child: Column(children: [
                            const TabBar(
                                unselectedLabelColor: Colors.grey,
                                labelColor: Colors.black,
                                indicatorColor: DefaultColors.primaryColor,
                                indicatorWeight: 4,
                                labelStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                tabs: [
                                  Tab(text: 'Chats'),
                                  Tab(text: 'Contacts'),
                                ]),
                            Expanded(
                                child: Container(
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
                          ]),
                        ),
                      ),
                    ),

                    // MESSAGING AREA
                    Expanded(
                        flex: 9,
                        child: MessagesArea(
                          currentUserData: currentUserData,
                        )),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
