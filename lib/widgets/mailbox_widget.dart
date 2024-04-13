import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_web/model/user_model.dart';

class MailBoxRead extends StatefulWidget {
  final UserModel fromUserData;
  final UserModel toUserData;
  const MailBoxRead(
      {super.key, required this.fromUserData, required this.toUserData});

  @override
  State<MailBoxRead> createState() => _MailBoxReadState();
}

class _MailBoxReadState extends State<MailBoxRead> {
   late StreamSubscription _streamSubscriptionEmails;
  final streamController = StreamController<QuerySnapshot>.broadcast();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [

          StreamBuilder(
            stream: streamController.stream, 
            builder: (context, dataSnapshot) {
              switch (dataSnapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
              return const Expanded(child: Center(
                child: Column(
                  children: [
                    Text('Loading data...'),
                    CircularProgressIndicator()
                  ],
                ),
              ));
              case ConnectionState.active:
              case ConnectionState.done:
              if(dataSnapshot.hasError) {
                return const Center(
                  child: Text('Error occurred.'),
                );
                 } else {
                final snapshot = dataSnapshot.data as QuerySnapshot;
                List<DocumentSnapshot> emailist = snapshot.docs.toList();
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                       DocumentSnapshot eachemail = emailist[index];
                     Column(
                       children: [
                         Container(
                           child: Text(eachemail['emailText'])
                        ),
                        Container(
                           child: Text(DateFormat.jm().format(eachemail['createdAt'].toDate()))
                        ),
                       ],
                     );
                    },
                    
                  ),
                );
                 }}
            })
        ]),
    );
  }
}