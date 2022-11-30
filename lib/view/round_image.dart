import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:tinderclone/services/parse_handler.dart';

class RoundImage extends StatelessWidget {
  ParseUser user;
  RoundImage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    String? urlString = ParseHandler().getImageForUser(user);
    return (urlString == null)
        ? CircleAvatar(
            child: Text(user.username?[0] ?? ""),
          )
        : CircleAvatar(
            backgroundImage: NetworkImage(urlString),
          );
  }
}
