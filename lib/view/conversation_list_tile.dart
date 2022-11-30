import 'package:flutter/material.dart';
import 'package:tinderclone/services/user_conversation.dart';
import 'package:tinderclone/view/round_image.dart';

class MyConversationListTile extends StatelessWidget {
  UserConversation user;
  Function(UserConversation) onTap;
  MyConversationListTile({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: RoundImage(user: user.user),
      title: Text(user.user.username ?? ""),
      subtitle: Text(user.lastMessage()),
      trailing: Text(user.lastDate()),
      onTap: (() => onTap(user)),
    );
  }
}
