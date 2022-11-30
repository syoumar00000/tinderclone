import 'dart:async';

import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:tinderclone/controller/chat_controller.dart';
import 'package:tinderclone/services/connection_services.dart';
import 'package:tinderclone/services/parse_handler.dart';
import 'package:tinderclone/services/user_conversation.dart';
import 'package:tinderclone/view/conversation_list_tile.dart';

class MessageView extends StatefulWidget {
  ParseUser user;
  MessageView({super.key, required this.user});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ParseHandler().getMatches(myUser: widget.user),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return ConnectionServices().noneBody();
          case ConnectionState.waiting:
            return ConnectionServices().waitingBody();
          default:
            return (snapshot.hasData && snapshot.data!.isNotEmpty)
                ? ListView.separated(
                    separatorBuilder: ((context, int index) => const Divider()),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      UserConversation conversation = snapshot.data![index];
                      return MyConversationListTile(
                          user: snapshot.data![index], onTap: onTap);
                    },
                  )
                : ConnectionServices().noData();
        }
      },
    );
  }

  onTap(UserConversation userConversation) {
    final next = ChatController(
      userConversation: userConversation,
      myId: widget.user.objectId!,
    );
    MaterialPageRoute route = MaterialPageRoute(builder: (context) => next);
    Navigator.of(context).push(route).then(refreshDatas);
  }

  // mettre a jour la page avec ses données en revenant en arriere
  FutureOr refreshDatas(dynamic value) {
    setState(() {
      print("ici nous mettons a jours");
    });
  }
}
