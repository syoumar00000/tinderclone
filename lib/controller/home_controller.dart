import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:tinderclone/view/match_view.dart';
import 'package:tinderclone/view/message_view.dart';
import 'package:tinderclone/view/profil_view.dart';

class HomeController extends StatefulWidget {
  final ParseUser user;
  const HomeController({super.key, required this.user});

  @override
  State<HomeController> createState() => _HomeControllerState();
}

class _HomeControllerState extends State<HomeController>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TabBar(
              indicatorColor: Colors.transparent,
              controller: tabController,
              tabs: [
                Icon(
                  Icons.local_fire_department,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Icon(
                  Icons.message,
                  color: Theme.of(context).colorScheme.primary,
                ),
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ]),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: TabBarView(controller: tabController, children: [
          MatchView(
            user: widget.user,
          ),
          MessageView(),
          ProfilView(
            user: widget.user,
          )
        ]));
  }
}
