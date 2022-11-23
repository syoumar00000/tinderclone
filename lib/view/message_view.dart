import 'package:flutter/material.dart';
import 'package:tinderclone/services/connection_services.dart';

class MessageView extends StatefulWidget {
  const MessageView({super.key});

  @override
  State<MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends State<MessageView> {
  @override
  Widget build(BuildContext context) {
    return ConnectionServices().noData();
  }
}
