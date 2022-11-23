import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:tinderclone/services/parse_handler.dart';

class ProfilView extends StatefulWidget {
  final ParseUser user;
  const ProfilView({super.key, required this.user});

  @override
  State<ProfilView> createState() => _ProfilViewState();
}

class _ProfilViewState extends State<ProfilView> {
  late TextEditingController usernameController;
  late TextEditingController descriptionController;
  ImagePicker imagePicker = ImagePicker();
  String? url;
  @override
  void initState() {
    usernameController = TextEditingController();
    descriptionController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    usernameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    url = ParseHandler().getImageForUser(widget.user);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height / 3,
              child: (url == null)
                  ? const Icon(Icons.person)
                  : Image.network(url!),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    onPressed: (() => takePicture(ImageSource.gallery)),
                    child: const Text("Gallery")),
                ElevatedButton(
                    onPressed: (() => takePicture(ImageSource.camera)),
                    child: const Text("Camera")),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(hintText: widget.user.username),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: (() => updateUser(
                      key: "username", value: usernameController.text.trim())),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: descriptionController,
                    decoration:
                        InputDecoration(hintText: widget.user["description"]),
                    maxLines: null,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: (() => updateUser(
                      key: "description",
                      value: descriptionController.text.trim())),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.only(bottom: 45)),
            ElevatedButton(
                onPressed: () {
                  ParseHandler().logout(widget.user, context);
                },
                child: const Text("Se deconnecter"))
          ],
        ),
      ),
    );
  }

  takePicture(ImageSource source) async {
    final XFile? xFile = await imagePicker.pickImage(source: source);
    if (xFile == null) return;
    final File file = File(xFile.path);
    ParseFile? parseFile = await ParseHandler().saveImage(file);
    if (parseFile == null) return;
    updateUser(key: "image", value: parseFile);
  }

  updateUser({required String key, required dynamic value}) async {
    FocusScope.of(context).requestFocus(FocusNode()); //faire rentrer le clavier
    ParseHandler()
        .updateUser(user: widget.user, key: key, value: value)
        .then((value) => setState(() {}));
  }
}
