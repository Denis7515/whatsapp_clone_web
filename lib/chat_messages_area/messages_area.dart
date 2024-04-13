import 'package:whatsapp_web/default%20colors/default_colors.dart';
import 'package:whatsapp_web/model/user_model.dart';
import 'package:whatsapp_web/provider/provider_chat.dart';
import 'package:whatsapp_web/widgets/messages_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagesArea extends StatelessWidget {
  final UserModel currentUserData;
  const MessagesArea({super.key, required this.currentUserData});

  @override
  Widget build(BuildContext context) {
    UserModel? toUserData = context.watch<ProviderChat>().toUserData;

    return toUserData == null
        ? Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.white,
            child: Center(child: Image.asset('whatsapp.png')),
          )
        : Column(
            children: [
              // HEADER
              Container(
                color: DefaultColors.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(toUserData.imageProfile),
                    ),
                    const SizedBox(width: 12),
                    Text(toUserData.name,
                        style: TextStyle(
                            color: Colors.grey.shade900,
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                    const Spacer(),
                    const Icon(Icons.search),
                    const SizedBox(width: 12),
                    const Icon(Icons.more_vert),
                  ]),
                ),
              ),
              // MESSAGES LIST
              Expanded(
                  child: MessagesWidget(
                fromUserData: currentUserData,
                toUserData: toUserData,
              )),
            ],
          );
  }
}
