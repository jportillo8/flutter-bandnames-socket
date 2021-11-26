import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/src/models/band.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Naruto', votes: 7),
    Band(id: '2', name: 'Pokemon', votes: 5),
    Band(id: '3', name: 'Dragon ball', votes: 2),
    Band(id: '4', name: 'Arcana', votes: 4),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: Text('BandNames',
            style: TextStyle(
              color: Colors.black87,
            )),
      ),
      body: ListView.builder(
          itemCount: bands.length,
          itemBuilder: (context, i) => _bandTitle(bands[i])),
      floatingActionButton: FloatingActionButton(
          elevation: 1, child: Icon(Icons.add), onPressed: addNewBand
          // Si nesecito mandar argumentos entonces
          // onPressed: () => addNewBand()
          ),
    );
  }

  Widget _bandTitle(Band band) {
    return Dismissible(
      onDismissed: (direction) {
        print('direction $direction banda eliminada : ${band.id}');
        // TODO llamar el borrado
      },
      background: Container(
          padding: EdgeInsets.only(left: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text('Delete Band', style: TextStyle(color: Colors.white)),
          ),
          color: Colors.red),
      direction: DismissDirection.startToEnd,
      key: Key(band.id),
      child: ListTile(
        title: Text(band.name),
        trailing: Text('${band.votes}',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        leading: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: Text(band.name.substring(0, 2))),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  addNewBand() {
    // Para poder controlar el texto ingresado
    final textController = TextEditingController();

    // Ahora si yo quiero un dialogo dif para ios entonces:
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('New  band name:'),
              content: TextField(
                controller: textController,
              ),
              actions: [
                MaterialButton(
                    elevation: 5,
                    textColor: Colors.blue,
                    child: Text('Add'),
                    onPressed: () => addBandToList(textController.text))
              ],
            );
          });
    }

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('New band name'),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Add'),
                onPressed: () => addBandToList(textController.text),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Dissmis'),
                onPressed: () => Navigator.pop(context),
              )
            ],
          );
        });
  }

  // Este metodo es para poder cerrar el dialogo manualmente
  void addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      // Podemos agragar
      this.bands.add(
          new Band(id: DateTime.now().toString(), name: 'other', votes: 2));
      setState(() {});
    }
    Navigator.pop(context);
  }
}
