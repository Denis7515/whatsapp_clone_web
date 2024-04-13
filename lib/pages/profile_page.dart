import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_web/default%20colors/default_colors.dart';
import 'package:whatsapp_web/model/user_model.dart';

class ProfilePage extends StatefulWidget {
  const  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  
  late UserModel currentUserData;
  final currentUser = FirebaseAuth.instance.currentUser!;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Page'),
      ),
      body: StreamBuilder<DocumentSnapshot>(stream: FirebaseFirestore
      .instance.collection('users_web').doc(currentUser!.uid).snapshots(), 
      builder: (context, snapshot) {
       if (snapshot.hasData) {
        final userData = snapshot.data!.data() as Map<String, dynamic>;
        return ListView(children: [
       Padding(
         padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
        child: Column(
          children: [
           Stack(children: [
              CircleAvatar(
               radius: 64, backgroundColor: Colors.grey,
               backgroundImage: NetworkImage(userData['imageProfile'])),
                Positioned(top: 95, left: 92,
                child: GestureDetector(onTap: (){},
                  child: Container(
                  decoration: BoxDecoration(color: Colors.white,  borderRadius: BorderRadius.circular(35)),
                    child: const Padding(
                      padding: EdgeInsets.all(6.0),
                      child: Icon(Icons.camera_alt, color: DefaultColors.primaryColor),
                    )),
                ))
           ] ),
             const SizedBox(height: 28),
          Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(Icons.person, color: Colors.grey.shade600),
              const SizedBox(width: 25),
            const Text('Name  ', style: TextStyle(
                 fontWeight: FontWeight.w600, fontSize: 18)),
            Text(userData['name'], style: const TextStyle(
                 fontWeight: FontWeight.w700, fontSize: 19))
                ],),
          const SizedBox(height: 15),
           Row(mainAxisAlignment: MainAxisAlignment.start,
            children: [
            Icon(Icons.email,color: Colors.grey.shade600),
            const SizedBox(width: 25),
            const Text('Email  ', style: TextStyle(
                 fontWeight: FontWeight.w600, fontSize: 18),),
            Text(userData['email'], style: TextStyle(
                fontWeight: FontWeight.w500, color: Colors.grey.shade600,
                fontSize: 19)),
              ],),
           const SizedBox(height: 15),
          Row(mainAxisAlignment: MainAxisAlignment.start,
           children: [
             GestureDetector(
              onTap: () async {
                await FirebaseAuth.instance.signOut().then((value) {
                  Navigator.pushReplacementNamed(context, '/login');
                });
              },
              child:  Icon(Icons.logout_outlined, color: Colors.grey.shade600,)),
              const SizedBox(width: 25),
             const Text('LogOut ', style: TextStyle(
               fontWeight: FontWeight.w600, fontSize: 18) 
             ),
            ] 
          ),
        ],
        ),
      ),
        ],);
       } else if (snapshot.hasError) {
         return Center(child: Text('Error :${snapshot.error}',));
       }
       return const Center(child: CircularProgressIndicator());
      } 
      ),
     );
  }
  /*
  Future<void> showMyDialog(BuildContext context, 
    String field)  async {
    String newValue = "";
    await showDialog(context: context, 
    builder: (context) =>   AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      title: Text('Edit $field'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Enter new $field'
            ), 
            onChanged: (value) {
              newValue = value;
            },
        ),
        ],),
         actions: [
         TextButton(onPressed: (){
          Navigator.of(context).pop();
         }, child: const Text('Cancel')),
          TextButton(onPressed:  () async {
            Navigator.of(context).pop(newValue);
              }, 
              child: const Text('Update')),
      ]));
       // UPDATE IN FIRESTORE
       if (newValue.trim().isNotEmpty) {
        await FirebaseFirestore.instance.collection('users_web')
        .doc(currentUser.uid).update({field: newValue});
       }
  } */
}

