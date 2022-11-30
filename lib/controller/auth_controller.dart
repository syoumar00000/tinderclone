import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tinderclone/services/login_response_service.dart';
import 'package:tinderclone/services/parse_handler.dart';

class AuthController extends StatefulWidget {
  const AuthController({super.key});

  @override
  State<AuthController> createState() => _AuthControllerState();
}

class _AuthControllerState extends State<AuthController> {
  int authType = 0;
  Map<int, Widget> values = {
    0: const Text("Connexion"),
    1: const Text("Inscription")
  };

  late TextEditingController mailController = TextEditingController();
  late TextEditingController passwordController = TextEditingController();
  late TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    mailController = TextEditingController();
    passwordController = TextEditingController();
    usernameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    mailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
                Theme.of(context).colorScheme.tertiary
              ],
              stops: const [
                0,
                .5,
                1
              ]),
        ),
        child: SafeArea(
            child: Column(
          //mainAxisSize: MainAxisSize.max,
          children: [
            Image.asset(
              "assets/tkf_logo.png",
              height: MediaQuery.of(context).size.height / 9,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                //child: SingleChildScrollView(
                child: Column(
                  children: [
                    CupertinoSlidingSegmentedControl<int>(
                      children: values,
                      onValueChanged: (int? newValue) {
                        setState(() {
                          authType = newValue ?? 0;
                        });
                      },
                      backgroundColor: Colors.grey.shade300,
                      thumbColor: Theme.of(context).colorScheme.secondary,
                      groupValue: authType,
                    ),
                    const Spacer(),
                    myTextField(usernameController, "username", false),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    (authType == 1)
                        ? myTextField(mailController, "Adresse mail", false)
                        : Container(),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    myTextField(passwordController, "Mot de passe", true),
                    const Padding(padding: EdgeInsets.only(bottom: 10)),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: ElevatedButton(
                          onPressed: () {
                            handleAuth();
                          },
                          child: (authType == 1)
                              ? const Text("S'inscrire")
                              : const Text("Se Connecter")),
                    ),
                  ],
                ),
              ),
            ),
            // ),
          ],
        )),
      ),
    );
  }

  Widget myTextField(
      TextEditingController controller, String hint, bool isPassword) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hint),
      style: Theme.of(context).textTheme.button,
      obscureText: isPassword,
    );
  }

  handleAuth() async {
    FocusScope.of(context).requestFocus(FocusNode());
    final username = usernameController.text.trim();
    final emailAddress = mailController.text.trim();
    final password = passwordController.text.trim();

    if (authType == 1) {
      final loginResponse = await ParseHandler().createUser(
          username: username, emailAddress: emailAddress, password: password);
      handleAuthResponse(loginResponse);
    } else {
      final loginResponse =
          await ParseHandler().signIn(username: username, password: password);
      handleAuthResponse(loginResponse);
    }
  }

  handleAuthResponse(LoginResponseService loginResponseService) {
    if (loginResponseService.result == true) {
      // on goback
      ParseHandler().goBack(context);
    } else if (loginResponseService.error != null) {
      //show error
      SnackBar snackBar = SnackBar(content: Text(loginResponseService.error!));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}
