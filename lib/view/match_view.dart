import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:tinderclone/services/connection_services.dart';
import 'package:tinderclone/services/parse_handler.dart';
import 'package:tinderclone/view/user_card_view.dart';

class MatchView extends StatefulWidget {
  ParseUser user;
  MatchView({super.key, required this.user});

  @override
  State<MatchView> createState() => _MatchViewState();
}

class _MatchViewState extends State<MatchView> {
  List<ParseObject> objects = [];
  late SwipableStackController controller;

  @override
  void initState() {
    //get users
    getUsers();
    controller = SwipableStackController()..addListener(() => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (objects.isEmpty)
        ? ConnectionServices().noneBody()
        : Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.70,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SwipableStack(
                    controller: controller,
                    detectableSwipeDirections: const {
                      SwipeDirection.left,
                      SwipeDirection.right
                    },
                    stackClipBehaviour: Clip.none,
                    horizontalSwipeThreshold: 0.5,
                    verticalSwipeThreshold: 0.5,
                    onSwipeCompleted: onSwipeCompleted,
                    builder: (context, properties) {
                      final currentIndex = properties.index % objects.length;
                      return Stack(
                        children: [
                          UserCardView(
                              parseUser: objects[currentIndex] as ParseUser)
                        ],
                      );
                    },
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(25),
                ),
                height: MediaQuery.of(context).size.height * 0.10,
                margin: const EdgeInsets.all(20),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 35,
                        child: FittedBox(
                          child: FloatingActionButton(
                            onPressed: rewind,
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.loop_rounded,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      FloatingActionButton(
                        onPressed: disLike,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.close,
                          color: Colors.redAccent,
                        ),
                      ),
                      FloatingActionButton(
                        onPressed: like,
                        backgroundColor: Colors.white,
                        child: const Icon(
                          Icons.local_fire_department,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(
                        height: 35,
                        child: FittedBox(
                          child: FloatingActionButton(
                            onPressed: superLike,
                            backgroundColor: Colors.white,
                            child: const Icon(
                              Icons.star,
                              color: Colors.yellow,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  onSwipeCompleted(int index, SwipeDirection direction) {
    ParseUser user = objects[index] as ParseUser;
    if (index == objects.length - 1) {
      controller.currentIndex = -1;
    }
    switch (direction) {
      case SwipeDirection.left:
        break;
      case SwipeDirection.right:
        ParseHandler()
            .addLikes(user: widget.user, id: user.objectId)
            .then((success) {
          if (success) {
            //check match
            print("success---$success");
            ParseHandler()
                .checkMatch(me: widget.user, potentialMatch: user)
                .then((newMatch) {
              print("newMatch---$newMatch");
              if (newMatch) {
                const SnackBar snackBar =
                    SnackBar(content: Text("Vous avez un nouveau match"));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            });
          }
        });
        break;
      default:
        break;
    }
  }

  getUsers() async {
    final users = await ParseHandler().noMatch(parseUser: widget.user);
    setState(() {
      objects = users;
    });
  }

  rewind() => controller.rewind();
  superLike() {}
  like() => controller.next(swipeDirection: SwipeDirection.right);
  disLike() => controller.next(swipeDirection: SwipeDirection.left);
}
