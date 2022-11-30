import 'package:intl/intl.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';

class UserConversation {
  ParseUser user;
  ParseObject conversation;

  UserConversation({required this.user, required this.conversation});

  Map<String, dynamic>? toMap() =>
      conversation["lastMessage"] as Map<String, dynamic>?;
  String lastMessage() {
    String message = "";
    //  si sms aucun message n'a été encore ecrit alors retourne message vide
    if (toMap() == null) return message;
    // voir si cest lautre user qui a envoyé le sms
    if (toMap()?["from"] != user.objectId) {
      message += "Vous : ";
    }
    if (toMap()?["text"] != null) {
      message += toMap()?["text"];
    } else {
      message += "photo ";
    }
    return message;
  }

  String lastDate() {
    if (toMap() == null) return "";
    int? timestamp = toMap()!["date"] as int?;
    if (timestamp == null) return "";
    var now = DateTime.now();
    var format = DateFormat("HH: mm");
    var lastPostDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
    var difference = now.difference(lastPostDate);
    var days = difference.inDays;
    if (days == 0) {
      return format.format(lastPostDate);
    } else if (days == 1) {
      return "$days Jour";
    } else if (days < 7) {
      return "$days Jours";
    } else if (days >= 7) {
      return "1 Semaines";
    } else {
      return "${(days / 7).floor()} Semaines";
    }
  }
}
