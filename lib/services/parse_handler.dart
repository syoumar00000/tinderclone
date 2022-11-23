import 'dart:io';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:tinderclone/main.dart';
import 'package:tinderclone/services/login_response_service.dart';

class ParseHandler {
  //logique de l'auth

  // si on est auth
  Future<ParseUser?> isAuth() async {
    //exist il?
    ParseUser? currentUser = await ParseUser.currentUser() as ParseUser?;
    //verifier sil est null
    if (currentUser == null) return null;
    //attendre une reponse
    final ParseResponse? userResponse =
        await ParseUser.getCurrentUserFromServer(currentUser.sessionToken!);
    if (userResponse == null && !userResponse!.success) {
      await currentUser.logout();
      return null;
    }
    return currentUser;
  }

  // creation
  Future<LoginResponseService> createUser(
      {required String username,
      required String emailAddress,
      required password}) async {
    ParseUser user = ParseUser(username, password, emailAddress);
    ParseResponse response = await user.signUp();
    return responseLog(response);
  }

  //connexion
  Future<LoginResponseService> signIn(
      {required String username, required password}) async {
    ParseUser user = ParseUser(username, password, null);
    ParseResponse response = await user.login();
    return responseLog(response);
  }

  //deconnexion
  logout(ParseUser user, BuildContext context) {
    user.logout();
    goBack(context);
  }

  // gestion de la reponse
  LoginResponseService responseLog(ParseResponse response) {
    if (response.success) {
      return LoginResponseService(result: true, error: null);
    } else {
      return LoginResponseService(
          result: false, error: response.error?.message);
    }
  }

  // go to main
  goBack(BuildContext context) {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
        (Route<dynamic> route) => false);
  }

  // update user info
  Future<bool> updateUser(
      {required ParseUser user,
      required String key,
      required dynamic value}) async {
    user.set(key, value);
    await user.save();
    return true;
  }

  // gestion des images

  Future<ParseFile?> saveImage(File file) async {
    final ParseFile parseFile = ParseFile(file);
    final result = await parseFile.save();
    return (result.success) ? parseFile : null;
  }

  String? getImageForUser(ParseUser user) {
    ParseFile? parseFile = user["image"] as ParseFile?;

    return (parseFile == null) ? null : parseFile["url"] as String;
  }

  //obtenir users
  Future<List<ParseObject>> getAllUsers() async {
    QueryBuilder<ParseUser> queryBuilder =
        QueryBuilder<ParseUser>(ParseUser.forQuery());
    ParseResponse parseResponse = await queryBuilder.query();
    return responseQuery(parseResponse);
  }

  Future<List<ParseObject>> noMatch({required ParseUser parseUser}) async {
    //ParseObject? matches = await getContactTable(id: parseUser.objectId!);
    //final list = matches!["matches"] ?? [];
    QueryBuilder<ParseUser> queryBuilder =
        QueryBuilder<ParseUser>(ParseUser.forQuery());
    queryBuilder.whereNotEqualTo("objectId", parseUser.objectId);
    //queryBuilder.whereNotContainedIn("objectId", list);
    ParseResponse parseResponse = await queryBuilder.query();
    return responseQuery(parseResponse);
  }

  List<ParseObject> responseQuery(ParseResponse response) {
    if (response.success && response.result != null) {
      return response.results as List<ParseObject>;
    } else {
      return [];
    }
  }

  //ajout de like
  Future<bool> addLikes({required ParseUser user, required String? id}) async {
    if (id == null) {
      return false;
    } else {
      List<dynamic> likes = user["likes"] ?? [];
      if (!likes.contains(id)) {
        likes.add(id);
      }
      final updated = await updateUser(user: user, key: "likes", value: likes);
      return updated;
    }
  }

  //Matches
  Future<bool> checkMatch(
      {required ParseUser me, required ParseUser potentialMatch}) async {
    List<dynamic>? potentialLikes = potentialMatch["likes"];
    if (potentialLikes == null) return false;
    if (potentialLikes.contains(me.objectId!)) {
      await updateLikes(me: me, newLike: potentialMatch);
      await updateLikes(me: potentialMatch, newLike: me);
      return true;
    } else {
      return false;
    }
  }

  //mettre ajour les likes
  Future<bool> updateLikes(
      {required ParseUser me, required ParseUser newLike}) async {
    ParseObject? object = await getContactTable(id: me.objectId!);
    if (object == null) {
      List<dynamic> list = [newLike.objectId!];
      final newO = ParseObject("Contacts")
        ..set("userId", me.objectId!)
        ..set("matches", list);
      await newO.save();
      await conversation(from: me.objectId!, to: newLike.objectId!);
      return true;
    } else {
      List<dynamic> list = object["matches"];
      list.add(newLike.objectId!);
      object.set("matches", list);
      await object.save();
      // creation d'objet conversation
      await conversation(from: me.objectId!, to: newLike.objectId!);
      return true;
    }
  }
// creer objet conversation

  Future<ParseObject> conversation({
    required String from,
    required String to,
  }) async {
    ParseObject conv = ParseObject("Conversation");
    QueryBuilder<ParseObject> queryBuilder = QueryBuilder<ParseObject>(conv);
    queryBuilder.whereArrayContainsAll("participants", [from, to]);
    ParseResponse r = await queryBuilder.query();
    List<ParseObject> result = responseQuery(r);
    if (result.isEmpty) {
      //creer nouvelle conversation
      ParseObject object = ParseObject("Conversation")
        ..set("participants", [from, to]);
      await object.save();
      return object;
    } else {
      return result.first;
    }
  }

  Future<ParseObject?> getContactTable({required String id}) async {
    ParseObject parseObject = ParseObject("Contacts");
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(parseObject);
    queryBuilder.whereContains("userId", id);
    ParseResponse response = await queryBuilder.query();
    final result = responseQuery(response);
    if (result.isEmpty) return null;
    return result.first;
  }
}
