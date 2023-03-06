import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_map_live/auth.dart';
import 'package:google_map_live/principal.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _State();
}

class _State extends State<AuthPage> {
  String _pwd = "";
  String _mail = "";
  User? _user;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.authStateChanges().listen((user) {
      setState(() {
        _user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Center(child: Text("Stick Together APP"))),
      body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Stack(children: [
            ListView(children: [
              Card(
                color: Colors.grey.shade300,
                child: Column(children: [
                  Container(height: 10),
                  const Text("Correo y contraseña",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _mail = value;
                          });
                        },
                        decoration:
                            const InputDecoration(label: Text("Email"))),
                  ),
                  Container(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _pwd = value;
                          });
                        },
                        decoration:
                            const InputDecoration(label: Text("Contraseña"))),
                  ),
                  Container(height: 10),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                            onPressed: () async {
                              var res = await Auth.mailSignIn(_mail, _pwd);
                              if (res == null) {
                                var collection = FirebaseFirestore.instance
                                    .collection('usuarios');
                                var docSnapshot =
                                    await collection.doc(_user?.uid).get();
                                if (docSnapshot.exists) {
                                  Map<String, dynamic>? data =
                                      docSnapshot.data();
                                  var equipo = data?[
                                      'equipo'];
                                  var nombre = data?[
                                      'nombre'];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MyApp(_user, equipo, nombre))); // <-- The value you want to retrieve.
                                  // Call setState if needed.
                                }
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: res == null
                                          ? Colors.green
                                          : Colors.red,
                                      content: Text(res ?? "Sesión iniciada!")));
                            },
                            child: const Text("Inicio de sesión"))
                      ]),
                  Container(height: 10)
                ]),
              ),
              Container(height: 10),
              Card(
                color: Colors.grey.shade300,
                child: Column(children: [
                  Container(height: 10),
                  const Text("Cierre de sesión",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(height: 10),
                  ElevatedButton(
                      onPressed: () async {
                        var res = await Auth.signOut();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor:
                                res == null ? Colors.green : Colors.red,
                            content: Text(res ?? "Sesión cerrada!")));
                      },
                      child: const Text("Cierre de sesión")),
                  Container(height: 10)
                ]),
              ),
            ]),
            Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  _user != null ? "Sesión iniciada" : "Sesión cerrada",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _user != null ? Colors.green : Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ))
          ])),
    );
  }
}
