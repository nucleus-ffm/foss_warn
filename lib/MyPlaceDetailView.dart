import 'package:flutter/material.dart';
import 'class/class_Place.dart';
import 'widgets/WarnCard.dart';
import 'services/markWarningsAsRead.dart';

class MyPlaceDetailScreen extends StatelessWidget {
  final Place myPlace;
  const MyPlaceDetailScreen({Key? key, required this.myPlace})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${myPlace.name}"),
        backgroundColor: Colors.green[700],
        brightness: Brightness.dark, //@TODO: fix
        actions: [
          //TextButton(onPressed: () {}, child: Text("Alle gelesen"))
          IconButton(
            onPressed: () {
              markAllWarningsAsRead(myPlace, context);
              final snackBar = SnackBar(
                content: const Text(
                  'Alle Warnungen als gelesen markiert',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.green[100],
              );

              // Find the ScaffoldMessenger in the widget tree
              // and use it to show a SnackBar.
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            },
            icon: Icon(Icons.mark_chat_read),
            tooltip: "Markiere alle Warnungen als gelesen",
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: myPlace.warnings
              .map((warning) => WarnCard(warnMessage: warning))
              .toList(),
        ),
      ),
    );
  }
}
