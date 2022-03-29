import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'main.dart';

class HomePage extends StatelessWidget {
  final String jwt;
  final Map<String, dynamic> payload;

  const HomePage(this.jwt, this.payload);

  factory HomePage.fromBase64(String jwt) => HomePage(
        jwt,
        json.decode(
          utf8.decode(
            base64.decode(
              base64.normalize(jwt.split(".")[1]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
      ),
      body: Center(
        child: FutureBuilder(
          future: http.read(
            Uri.parse('$SERVER_IP/data'),
            headers: {'Authorization': jwt},
          ),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.toString());
            } else if (snapshot.hasError) {
              return const Text("An error occured");
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget buildBody(AsyncSnapshot snapshot) {
    return Column(
      children: [
        Text("${payload['username']},here is the data:"),
        Text(
          snapshot.data,
          style: const TextStyle(fontSize: 36),
        )
      ],
    );
  }
}
