import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:tinderclone/services/connection_services.dart';
import 'package:tinderclone/services/parse_handler.dart';
import 'package:tinderclone/services/user_conversation.dart';
import 'package:tinderclone/view/chat_bubble_text.dart';
import 'package:tinderclone/view/chat_bubble_image.dart';
import 'package:tinderclone/view/round_image.dart';

class ChatController extends StatefulWidget {
  String myId;
  UserConversation userConversation;
  ChatController(
      {super.key, required this.userConversation, required this.myId});

  @override
  State<ChatController> createState() => _ChatControllerState();
}

class _ChatControllerState extends State<ChatController> {
  late TextEditingController messageController;
  StreamController<List<ParseObject>> streamController = StreamController();
  LiveQuery liveQuery = LiveQuery(debug: true);
  late Subscription<ParseObject> subscription;
  late QueryBuilder<ParseObject> queryMessages;
  List<ParseObject> messages = [];

  @override
  void initState() {
    messageController = TextEditingController();
    queryMessages = ParseHandler()
        .queryMessages(pointer: widget.userConversation.conversation.objectId!);
    getBasicInfos();
    startLiveQuery();
    super.initState();
  }

  @override
  void dispose() {
    messageController.dispose();
    stopQuery();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 2,
          automaticallyImplyLeading: false,
          flexibleSpace: SafeArea(
            child: Container(
              padding: const EdgeInsets.only(right: 18),
              child: Row(
                children: [
                  IconButton(
                      onPressed: (() => Navigator.pop(context)),
                      icon: const Icon(Icons.arrow_back)),
                  const SizedBox(
                    width: 5,
                  ),
                  RoundImage(user: widget.userConversation.user),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    widget.userConversation.user.username ?? "",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                      onPressed: (() {}),
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
          ),
        ),
        body: Container(
          child: InkWell(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Column(
              children: [
                Expanded(
                    child: StreamBuilder<List<ParseObject>>(
                  stream: streamController.stream,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return ConnectionServices().noneBody();
                      case ConnectionState.waiting:
                        return ConnectionServices().waitingBody();
                      default:
                        return (snapshot.hasError || !snapshot.hasData)
                            ? ConnectionServices().noData()
                            : ListView.builder(
                                itemCount: messages.length,
                                padding:
                                    const EdgeInsets.only(top: 10, bottom: 20),
                                //physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final message = messages[index];
                                  final from = message["from"] as String;
                                  final text = message["text"] as String?;
                                  final image = message["image"] as ParseFile?;
                                  bool isMe = (from == widget.myId);
                                  if (text != null && text != "") {
                                    // on retourne un chat message
                                    return ChatBubbleText(
                                        isMe: isMe, message: message);
                                  } else if (image != null) {
                                    // on retourne un chat image
                                    return ChatBubbleImage(
                                        isMe: isMe, message: message);
                                  } else {
                                    return Container();
                                  }
                                });
                    }
                  },
                )),
                Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.grey.shade200,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: (() => takePicture(ImageSource.gallery)),
                          icon: const Icon(Icons.photo_library)),
                      IconButton(
                          onPressed: (() => takePicture(ImageSource.camera)),
                          icon: const Icon(Icons.camera_alt)),
                      Flexible(
                          child: TextField(
                        controller: messageController,
                        decoration: const InputDecoration.collapsed(
                            hintText: "Envoyer un message..."),
                        maxLines: null,
                      )),
                      IconButton(
                          onPressed: (() => sendSms()),
                          icon: const Icon(Icons.send)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  sendSms() {
    FocusScope.of(context).requestFocus(FocusNode());
    // si le messacontroller est vide je ne fais rien
    if (messageController.text == "") return;
    // si ce nest pas vide
    ParseHandler()
        .sendMessage(
            from: widget.myId,
            to: widget.userConversation.user.objectId!,
            text: messageController.text)
        .then((value) {
      // print("succes---$value");
    });

    setState(() {
      messageController.text = "";
    });
  }

  takePicture(ImageSource source) async {
    ImagePicker picker = ImagePicker();
    XFile? xfile = await picker.pickImage(source: source);
    if (xfile == null) return;
    final imagePath = xfile.path;
    File file = File(imagePath);
    ParseFile parseFile = ParseFile(file);
    await parseFile.save();
    ParseHandler().sendMessage(
        from: widget.myId,
        to: widget.userConversation.user.objectId!,
        image: parseFile);
  }

  //recuperer les infos de base quand je me connecte
  getBasicInfos() async {
    ParseResponse response = await queryMessages.query();
    List<ParseObject> objects = ParseHandler().responseQuery(response);
    if (objects.isEmpty) {
      messages.clear();
      streamController.add([]);
    } else {
      messages.addAll(objects);
      streamController.add(objects);
    }
  }

  startLiveQuery() async {
    subscription = await liveQuery.client.subscribe(queryMessages);
    subscription.on(LiveQueryEvent.create, (newValue) {
      messages.add(newValue);
      streamController.add(messages);
    });
  }

  stopQuery() {
    liveQuery.client.unSubscribe(subscription);
  }
}
