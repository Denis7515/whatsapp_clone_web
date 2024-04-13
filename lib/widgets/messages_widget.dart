import 'dart:async';
import 'dart:typed_data';

import 'package:emoji_picker_flutter_forked_for_web/emoji_picker_flutter.dart';
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_web/default%20colors/default_colors.dart';
import 'package:whatsapp_web/model/chat.dart';
import 'package:whatsapp_web/model/message.dart';
import 'package:whatsapp_web/model/user_model.dart';
import 'package:whatsapp_web/provider/provider_chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagesWidget extends StatefulWidget {
  final UserModel fromUserData;
  final UserModel toUserData;
  const MessagesWidget(
      {super.key, required this.fromUserData, required this.toUserData});

  @override
  State<MessagesWidget> createState() => _MessagesWidgetState();
}

class _MessagesWidgetState extends State<MessagesWidget> {

  TextEditingController messageController = TextEditingController();
  late StreamSubscription _streamSubscriptionMessages;
  final streamController = StreamController<QuerySnapshot>.broadcast();
  final scrollControllerMessages = ScrollController();
  String? fileTypeChoosed;
  bool _loadingPic = false;
  bool _loadingFile = false;
  Uint8List? _selectedImage; 
  Uint8List? _selectedFile; 
  bool emojishowing = false;
  bool isEmoji = false;

  sendMessage() {
    String msgText = messageController.text.trim();
    if(msgText.isNotEmpty) {
      String fromUserID = widget.fromUserData.uid;

      final message = Message(
        fromUserID, 
        msgText, 
        Timestamp.now().toString(),
        Timestamp.now().toDate()
        ); 

        String toUserID = widget.toUserData.uid;

        String messageID = DateTime.now().microsecondsSinceEpoch.toString();

        // SAVE MESSAGE IN DATABASE FOR SENDER
        saveMessageToDatabase(fromUserID, toUserID, message, messageID);
       
        // SAVE CHAT FOR RECENTS [sender]
        final chatFromData = ChatModel(
          fromUserID, 
          toUserID, 
          message.text.trim(), 
          widget.toUserData.name, 
          widget.toUserData.email,
          widget.toUserData.imageProfile
          );
          saveRecentChatToDatabase(chatFromData, msgText);

        // SAVE MESSAGE IN DATABASE FOR RECEIVER
        saveMessageToDatabase(toUserID, fromUserID, message, messageID);

        // SAVE CHAT FOR RECENTS [receiver]
        final chatToData = ChatModel(
          toUserID, 
          fromUserID,
          message.text.trim(), 
          widget.fromUserData.name, 
          widget.fromUserData.email,
          widget.fromUserData.imageProfile
          );
          saveRecentChatToDatabase(chatToData, msgText);
    }
  }
  saveMessageToDatabase(fromUserID, toUserID, message, messageID) {
   FirebaseFirestore.instance.collection('messages_web').doc(fromUserID)
   .collection(toUserID).doc(messageID).set(message.toMap());

   messageController.clear();
  }
  
  saveRecentChatToDatabase(ChatModel chatModel, msgText) {
  FirebaseFirestore.instance.collection('chats_web').doc(chatModel.fromUserID)
  .collection('lastMessage').doc(chatModel.toUserID).set(chatModel.toMap());
  }

  createMessageListener({UserModel? toUserData}) {
    final streamMessages = FirebaseFirestore.instance.collection('messages_web')
    .doc(widget.fromUserData.uid).collection(toUserData?.uid ??
    widget.toUserData.uid).orderBy('dateTime', descending: false)
    .snapshots();

    _streamSubscriptionMessages = streamMessages.listen((data) {
      streamController.add(data);
      Timer(const Duration (seconds: 1), () {
        scrollControllerMessages.jumpTo(scrollControllerMessages
        .position.maxScrollExtent);
       });
     });
  }
  
  updateMessageListener() {
    UserModel? toUserData = context.watch<ProviderChat>().toUserData;
    if(toUserData != null ) {
      createMessageListener(toUserData: toUserData);
    }
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // to update messages listeners through provider
    updateMessageListener();
  }

  @override
  void dispose() {
    _streamSubscriptionMessages.cancel();
    super.dispose();
  }

  @override
  void initState() {
      super.initState();
     createMessageListener();
  }
  
  // EMOJI
  _onEmojiSelected(Emoji emoji) {
    messageController..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length));
  }
  _onBackspacePressed() {
    messageController
      ..text = messageController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: messageController.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
      //  color: DefaultColors.backgroundColor,
        image: DecorationImage(
            image: AssetImage('background.png'), fit: BoxFit.cover),
      ),
      child: Column(
        children: [
          
          // DISPLAY MESSAGES HERE
          StreamBuilder(stream: streamController.stream, 
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

                List<DocumentSnapshot> messagesList = snapshot.docs.toList();
                return Expanded(
                  child: ListView.builder(
                    controller: scrollControllerMessages,
                    itemCount: snapshot.docs.length,
                    itemBuilder: (context, index) {
                     DocumentSnapshot eachMessage = messagesList[index];
                                   
                     // Align message bubble for sender and receiver
                     CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start;
                     Alignment alignment = Alignment.bottomLeft;
                     Color color = Colors.white;
                     Color textColor = Colors.grey.shade900;
                     if(widget.fromUserData.uid == eachMessage['uid']) {
                      alignment = Alignment.bottomRight;
                      color = const Color(0xFF33AC88);
                      textColor = Colors.white;
                      crossAxisAlignment = CrossAxisAlignment.end;
                     }
                     Size width = MediaQuery.of(context).size * 0.7;
                    // DELETE MESSAGES
                     return GestureDetector(
                      onLongPress: () async {
                       if(eachMessage['uid'] == FirebaseAuth.instance.currentUser!.uid) {
                          await showDialog(
                          context: context, 
                          builder: (context) => AlertDialog(content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                             ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await deleteForMe(
                                  eachMessage.id, 
                                  FirebaseAuth.instance.currentUser!.uid, 
                                  widget.toUserData.uid, 
                                  );

                                await deleteForThem(
                                  eachMessage.id, 
                                  FirebaseAuth.instance.currentUser!.uid, 
                                  widget.toUserData.uid 
                                  );
                              },
                              child: const Text('Delete this message for everyone')
                             ),
                             const SizedBox(height: 18),
                              ElevatedButton(
                              onPressed: () async {
                                Navigator.of(context).pop();
                                await deleteForMe(
                                  eachMessage.id, 
                                  FirebaseAuth.instance.currentUser!.uid, 
                                  widget.toUserData.uid, 
                                  );                          
                              },
                              child: const Text('Delete this message for me')
                             ),
                              const SizedBox(height: 18),
                              ElevatedButton(
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel')),
                             ])
                             ),
                             );
                             }
                        },

                      child: eachMessage['text'].toString().contains('.jpg') ?
                      Align(
                        alignment: alignment,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(crossAxisAlignment: crossAxisAlignment,
                            children: [
                              Material(elevation: 2, color: color,
                               borderRadius: const BorderRadius.all(Radius.circular(12)),
                                child: Container(
                                  constraints: BoxConstraints.loose(width),
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.all(7),
                                  child: InstaImageViewer(child: Image.network(eachMessage['text'], 
                                  width: 240, height: 240,))
                                ),
                              ),
                                Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 9),
                                child: Text(DateFormat.jm().format(eachMessage['createdAt'].toDate()), 
                                style: TextStyle(fontWeight: FontWeight.w500, 
                                color: Colors.grey.shade600)),
                              )
                            ],
                          ),
                        ),
                      ) : eachMessage['text'].toString().contains('.pdf') || 
                          eachMessage['text'].toString().contains('.mp4') ||
                          eachMessage['text'].toString().contains('.mp3') ||
                          eachMessage['text'].toString().contains('.docx') ||
                          eachMessage['text'].toString().contains('.pptx') ||
                          eachMessage['text'].toString().contains('.xlsx') ?
                        Align(
                         alignment: alignment,
                         child: Column(
                          crossAxisAlignment: crossAxisAlignment,
                           children: [
                            Container(
                              constraints: BoxConstraints.loose(width),
                              decoration: BoxDecoration(color: color,
                              borderRadius: const BorderRadius.all(Radius.circular(12))),
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.all(7),
                              child: GestureDetector(onTap: () {
                              },
                                child: 
                             //   const Icon(Icons.folder_copy_outlined, size: 70)
                                Image.asset('file.png', width: 180, height: 180),
                                )),
                              Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 9),
                              child: Text(DateFormat.jm().format(eachMessage['createdAt'].toDate()), 
                              style: TextStyle(fontWeight: FontWeight.w500, 
                              color: Colors.grey.shade600)),
                            )
                          ],
                        ),
                      ) :
                       Align(
                        alignment: alignment,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(crossAxisAlignment: crossAxisAlignment,
                            children: [
                              Material(elevation: 2, color: color,
                               borderRadius: const BorderRadius.all(Radius.circular(12)),
                                  child: Container(
                                  constraints: BoxConstraints.loose(width),
                                  padding: const EdgeInsets.all(8),
                                  margin: const EdgeInsets.all(7),
                                  child: SelectableText(eachMessage['text'], 
                                  style: TextStyle(fontWeight: FontWeight.w600, 
                                  fontSize: 16, 
                                  color: textColor)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 9),
                                child: Text(DateFormat.jm().format(eachMessage['createdAt'].toDate()), 
                                style: TextStyle(fontWeight: FontWeight.w500, 
                                color: Colors.grey.shade600)),
                              ),
                            ],
                          ),
                        ),
                      ),
                     );
                    }
                    ));
              }
            }
          }),
          // TEXT FIELD
          Container(
            padding: const EdgeInsets.all(8),
            color: DefaultColors.barBackgroundColor,
            child: Row(children: [
              Expanded(
                  child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: const BoxDecoration(),
                child: Row(children: [
                  GestureDetector( 
                    onTap: () {
                      setState(() {
                        emojishowing = !emojishowing;
                      });
                    },
                    child: emojishowing ?  Icon(Icons.keyboard_alt_outlined, 
                    color: Colors.grey.shade600) : Icon(Icons.emoji_emotions_outlined, 
                    color: Colors.grey.shade600)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: TextField(
                    controller: messageController,
                      decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                      ),
                  )),

                  _loadingFile == false ?
                  IconButton(
                      onPressed: () {
                        dialogBoxSelectingFiles();
                      },
                      icon: Icon(Icons.attach_file_rounded,
                      color: Colors.grey.shade600)) : 
                      const Center(child: CircularProgressIndicator(color: DefaultColors.primaryColor)),
                  const SizedBox(width: 5),

                  _loadingPic == false ?
                  IconButton(
                      onPressed: () {
                        selectImage();
                      },
                      icon: Icon(Icons.camera_alt_outlined,
                      color: Colors.grey.shade600)) : 
                      const Center(child: CircularProgressIndicator(color: DefaultColors.primaryColor)),
                ]),
              )),
              GestureDetector(
                onTap: () {
                  sendMessage();
                },
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(38),
                      color: DefaultColors.primaryColor),
                  child: const Icon(Icons.send_rounded, color: Colors.white,
                  ),
                ),
              ),
            ]),
          ),
          Offstage(
            offstage: !emojishowing,
            child: SizedBox(height: 250,
              child: Builder(builder: (context) {
                const emojiSize = 48 * 1.37;
                final columns = MediaQuery.of(context).size.width ~/ emojiSize;
              return EmojiPicker(
                onEmojiSelected: ((category, emoji) {
                  _onEmojiSelected(emoji);
                }),
                config: Config(
                  columns: columns,
                  emojiSizeMax: emojiSize,
                  verticalSpacing: 7,
                   horizontalSpacing: 7,
                  customEmojiFont: 'NotoColorEmoji',
                  initCategory: Category.RECENT,
                  bgColor: const Color(0xFFF2F2F2),
                  skinToneDialogBgColor: Colors.white,
                  skinToneIndicatorColor: Colors.grey,
                  indicatorColor: DefaultColors.lightGreen,
                  iconColorSelected: DefaultColors.lightGreen,
                  enableSkinTones: true,
                  showRecentsTab: true,
                  recentsLimit: 28,
                  ), 
              );
              }),
              
            ),
          ), 
        ],
      ),
    );
  }

  dialogBoxSelectingFiles() {
    showDialog(context: context, 
    builder: (BuildContext context) {
     return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return AlertDialog(
        title: const Text('Send File'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const Text('Please choose file type from the followings:'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DropdownButton<String> (
                hint: const Text('Choose here:'),
                value: fileTypeChoosed,
                underline: Container(),
                items: <String> [
                  '.pdf', '.mp4', '.mp3', '.docx', '.pptx', '.xlsx'
                ].map((String value) {
                  return DropdownMenuItem<String>(value: value, 
                  child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600),));
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    fileTypeChoosed = value;
                  });
                },
              ),
            )
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () {
            Navigator.of(context).pop();
            // SELECT FILE 
            selectFile(fileTypeChoosed);
          }, 
          child: const Text('Select File'))
        ],
      );
     });
    });
  }

  selectFile(fileTypeChoosed) async {
   FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.any
    );

    setState(() {
      _selectedFile = pickerResult?.files.single.bytes;
    });
    uploadFile(_selectedFile);
  }

  uploadFile(selectedFile) {
    setState(() {
      _loadingFile = true;
    });
    if(selectedFile != null) {
      Reference fileRef = FirebaseStorage.instance.ref("files_web/${DateTime.now()
      .millisecondsSinceEpoch.toString()}$fileTypeChoosed");

      UploadTask uploadTask = fileRef.putData(selectedFile);
      uploadTask.whenComplete(() async {
        String linkFile = await uploadTask.snapshot.ref.getDownloadURL();

        setState(() {
          messageController.text = linkFile;
        });
        sendMessage();

        setState(() {
          _loadingFile = false;
        });
      });
    }
  }

  // SEND IMAGES 
  selectImage() async {
   FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.image
    );

    setState(() {
      _selectedImage = pickerResult?.files.single.bytes;
    });
    uploadImage(_selectedImage);
  }

  uploadImage(selectedImage) {
    setState(() {
      _loadingPic = true;
    });
    if(selectedImage != null) {
      Reference fileRef = FirebaseStorage.instance.ref("ChatImages_web/${DateTime.now()
      .millisecondsSinceEpoch.toString()}.jpg");

      UploadTask uploadTask = fileRef.putData(selectedImage);
      uploadTask.whenComplete(() async {
        String linkFile = await uploadTask.snapshot.ref.getDownloadURL();

        setState(() {
          messageController.text = linkFile;
        });
        sendMessage();
        
        setState(() {
         _loadingPic = false;
        });
      });
    }
  }

  deleteForMe(messageID, myId, toUserID) async {
   await FirebaseFirestore.instance.collection('messages_web').doc(myId)
   .collection(toUserID).doc(messageID).delete();
  }
  deleteForThem(messageID, myId, toUserID) async {
   await FirebaseFirestore.instance.collection('messages_web').doc(toUserID)
   .collection(myId).doc(messageID).delete();
  }
}
