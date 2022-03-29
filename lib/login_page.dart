import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Log In")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: "Username"),
          ),
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Log In"),
          ),
          TextButton(
            onPressed: () {},
            child: const Text("Sign Up"),
          )
        ]),
      ),
    );
  }

  void loginFunction(BuildContext context) async {
    var username = _usernameController.text;
    var password = _passwordController.text;

    var jwt = await attemptLogin(username, password);
    if (jwt != null) {
      storage.write(key: 'jwt', value: jwt);
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()));
    } else {
      displayDialog(context, "An error occured.",
          "No account was found matching that username and password");
    }
  }

  void signupFunction(BuildContext context) async {
    var username = _usernameController.text;
    var password = _passwordController.text;

    if (username.length < 4) {
      displayDialog(context, "Invalid Username",
          "The username should be at least 4 characters long");
    } else if (password.length < 4) {
      displayDialog(context, "Invalid Password",
          "The password should be at least 4 characters long");
    } else {
      var res = await attemptSignup(username, password);
      if (res == 201) {
        displayDialog(context, "Success", "Account created successfully");
      } else if (res == 409) {
        displayDialog(context, "An error occured.",
            "An account with that username already exists");
      } else {
        displayDialog(context, "An error occured.",
            "An unknown error occured. Please try again later");
      }
    }
  }

  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(text),
        ),
      );

  Future<String?> attemptLogin(String username, String password) async {
    var res = await http.post(
      Uri.parse("$SERVER_IP/login"),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (res.statusCode == 200) return res.body;
    return null;
  }

  Future<int?> attemptSignup(String username, String password) async {
    var res = await http.post(
      Uri.parse("$SERVER_IP/signup"),
      body: {
        'username': username,
        'password': password,
      },
    );

    return res.statusCode;
  }
}
