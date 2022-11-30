import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:tinderclone/services/parse_handler.dart';

class ChatBubbleImage extends StatelessWidget {
  final bool isMe;
  final ParseObject message;
  const ChatBubbleImage({super.key, required this.isMe, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Align(
        alignment: (isMe) ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(ParseHandler().getImageForChat(message)!),
          ),
        ),
      ),
    );
  }
}
