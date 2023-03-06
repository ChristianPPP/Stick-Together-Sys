import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_map_live/mymap.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class MyApp extends StatefulWidget {
  MyApp(User? user, String? equipo, String? nombre) {
    this.user = user;
    this.equipo = equipo;
    this.nombre = nombre;
  }
  User? user;
  String? equipo;
  String? nombre;
  @override
  _MyAppState createState() => _MyAppState(this.user, this.equipo, this.nombre);
}

class _MyAppState extends State<MyApp> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;

  _MyAppState(User? user, String? equipo, String? nombre) {
    this.user = user;
    this.equipo = equipo;
    this.nombre = nombre;
  }
  User? user;
  String? equipo;
  String? nombre;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.equipo.toString()),
      ),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                _getLocation();
              },
              child: Text('Unirse')),
          TextButton(
              onPressed: () {
                _listenLocation();
              },
              child: Text('Activar localización automática')),
          TextButton(
              onPressed: () {
                _stopListening();
              },
              child: Text('Desactivar localización automática')),
          Expanded(
              child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection(this.equipo.toString()).snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title:
                          Text(snapshot.data!.docs[index]['name'].toString()),
                      subtitle: Row(
                        children: [
                          Text(snapshot.data!.docs[index]['latitude']
                              .toString()),
                          SizedBox(
                            width: 20,
                          ),
                          Text(snapshot.data!.docs[index]['longitude']
                              .toString()),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.directions),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  MyMap(snapshot.data!.docs[index].id, this.equipo.toString())));
                        },
                      ),
                    );
                  });
            },
          )),
        ],
      ),
    );
  }

  _getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      await FirebaseFirestore.instance
          .collection(this.equipo.toString())
          .doc(this.user?.uid)
          .set({
        'latitude': _locationResult.latitude,
        'longitude': _locationResult.longitude,
        'name': this.nombre
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance
          .collection(this.equipo.toString())
          .doc(this.user?.uid)
          .set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'name': this.nombre
      }, SetOptions(merge: true));
    });
  }

  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('Hecho');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
