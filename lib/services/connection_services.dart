import 'package:flutter/material.dart';

class ConnectionServices {
  Widget noneBody() => const Center(child: Text("en attente de connection..."));
  Widget waitingBody() => const Center(child: CircularProgressIndicator());
  Widget noData() => const Center(child: Text("Aucune Donnée"));

  Scaffold noneScaffold() => Scaffold(
        body: noneBody(),
      );

  Scaffold waitingScaffold() => Scaffold(
        body: waitingBody(),
      );
}
