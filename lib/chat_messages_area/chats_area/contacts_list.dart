import 'package:whatsapp_web/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContactsList extends StatefulWidget {
  const ContactsList({super.key});

  @override
  State<ContactsList> createState() => _ContactsListState();
}

class _ContactsListState extends State<ContactsList> {

  String currentUserID = "";

  getCurrentFirebaseUser() {
    User currentFirebaseUser = FirebaseAuth.instance.currentUser!;
    if(currentFirebaseUser != null) {
     currentUserID = currentFirebaseUser.uid;
    }
  }

  Future<List<UserModel>> readContactList() async {
   final usersRef = FirebaseFirestore.instance.collection('users_web');

   QuerySnapshot allUsersRecord = await usersRef.get();

   List<UserModel> allUsersList = [];
   for(DocumentSnapshot userRecord in allUsersRecord.docs) {
    String uid = userRecord['uid'];
    if(uid == currentUserID) {
      continue;
    }
    String name = userRecord['name'];
    String email = userRecord['email'];
    String password = userRecord['password'];
    String imageProfile = userRecord['imageProfile'];

    UserModel userData = UserModel(uid, name, email, 
    password, imageProfile: imageProfile);
    allUsersList.add(userData);
   }
   return allUsersList;
  }

   @override
  void initState() {
    super.initState();
    getCurrentFirebaseUser();
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: readContactList(),
      builder: (context, dataSnapshot) {
       switch(dataSnapshot.connectionState) {
        case ConnectionState.none:
        case ConnectionState.waiting:
        return const Padding(
          padding: EdgeInsets.all(17),
          child: Center(child: Column(children: [
            Text('Loading contacts...'),
            SizedBox(height: 10),
            CircularProgressIndicator(),
          ])),
        );
        case ConnectionState.active: 
        case ConnectionState.done:
        if(dataSnapshot.hasError) {
          return const Center(
            child: Text('Error on loading contacts...'),
          );
        } else {
          List<UserModel>? userContactList = dataSnapshot.data;
          if(userContactList != null) {
            return ListView.separated(
              separatorBuilder: (context, index) {
                return const Divider(thickness: 0.3, color: Colors.grey,);
              },
              itemCount: userContactList.length,
              itemBuilder: (context, index) {
                UserModel userData = userContactList[index];
                return ListTile(
                  onTap: () {
                    Future.delayed(Duration.zero, (){
                     Navigator.pushNamed(context, '/messages',
                     arguments: userData
                     );
                    });
                  },
                  leading: CircleAvatar(radius: 26,
                  backgroundColor: Colors.grey,
                  backgroundImage: NetworkImage(userData.imageProfile.toString())),
                  title: Text(userData.name.toString(), 
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  subtitle: Text(userData.email.toString(), 
                  style: TextStyle(fontWeight: FontWeight.w500, 
                  color: Colors.grey.shade600)),
                  contentPadding: const EdgeInsets.all(9),
                  );
              },
            );
          } else {
            return const Center(
            child: Text('No contacts found.'),
          );
          }
        }
       } 
      } 
    );
  }
}

