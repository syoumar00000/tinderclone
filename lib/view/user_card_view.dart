import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:tinderclone/services/parse_handler.dart';

class UserCardView extends StatelessWidget {
  final ParseUser parseUser;
  const UserCardView({super.key, required this.parseUser});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.shade800,
                    offset: const Offset(0, 2),
                    blurRadius: 2)
              ],
              borderRadius: BorderRadius.circular(25),
            ),
            height: size.height * 0.75,
            width: size.width - 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: (ParseHandler().getImageForUser(parseUser) == null)
                  ? Image.asset("assets/tkf_logo.png")
                  : Image.network(
                      ParseHandler().getImageForUser(parseUser)!,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  parseUser.username ?? "",
                  style: const TextStyle(fontSize: 50, color: Colors.teal
                      //Theme.of(context).colorScheme.primary
                      ),
                ),
                Text(
                  parseUser["description"] as String? ?? "",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
