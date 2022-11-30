import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class ChatBubbleText extends StatelessWidget {
  final bool isMe;
  final ParseObject message;
  ChatBubbleText({super.key, required this.isMe, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10.0),
      child: Align(
        alignment: (isMe) ? Alignment.topRight : Alignment.topLeft,
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color:
                  (isMe) ? Theme.of(context).colorScheme.primary : Colors.teal),
          padding: const EdgeInsets.all(16),
          child: Text(message["text"] as String),
        ),
      ),
    );
  }
}
