import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk.dart';
import 'package:tinderclone/controller/auth_controller.dart';
import 'package:tinderclone/controller/home_controller.dart';
import 'package:tinderclone/services/connection_services.dart';
import 'package:tinderclone/services/parse_handler.dart';
import 'package:tinderclone/settings/keys.dart';

Future<void> main() async {
  //binding
  WidgetsFlutterBinding.ensureInitialized();
  //set-up back4app et parse
  await Parse().initialize(Keys.applicationId, Keys.serverId,
      clientKey: Keys.clientId, autoSendSessionId: true);

  /*  final test = ParseObject("firstcall");
  test.set("message", "on y est");
  print("ajouté first object"); */
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const primaryColor = Color(0XFFFF5864);
  static const secondaryColor = Color(0XFFFF655B);
  static const tertiaryColor = Color(0XFFFF297B);

  static final MaterialColor materialColor = MaterialColor(0XFFFD297B, swatch);
  static final Map<int, Color> swatch = {
    50: const Color.fromRGBO(253, 41, 123, .1),
    100: const Color.fromRGBO(253, 41, 123, .2),
    200: const Color.fromRGBO(253, 41, 123, .3),
    300: const Color.fromRGBO(253, 41, 123, .4),
    400: const Color.fromRGBO(253, 41, 123, .5),
    500: const Color.fromRGBO(253, 41, 123, .6),
    600: const Color.fromRGBO(253, 41, 123, .7),
    700: const Color.fromRGBO(253, 41, 123, .8),
    800: const Color.fromRGBO(253, 41, 123, .9),
    900: const Color.fromRGBO(253, 41, 123, 1),
  };
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: materialColor,
        colorScheme: ThemeData().colorScheme.copyWith(
            primary: primaryColor,
            secondary: secondaryColor,
            tertiary: tertiaryColor),
        textTheme: const TextTheme(
          button: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<ParseUser?>(
        future: ParseHandler().isAuth(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return ConnectionServices().noneScaffold();
            case ConnectionState.waiting:
              return ConnectionServices().waitingScaffold();
            default:
              return (snapshot.hasData && snapshot.data != null)
                  ? HomeController(
                      user: snapshot.data!,
                    )
                  : AuthController();
          }
        },
      ),
    );
  }
}
