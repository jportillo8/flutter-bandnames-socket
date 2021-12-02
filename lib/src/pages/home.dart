import 'dart:io';

import 'package:band_names/services/socket_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/src/models/band.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Naruto', votes: 7),
    // Band(id: '2', name: 'Pokemon', votes: 5),
    // Band(id: '3', name: 'Dragon ball', votes: 2),
    // Band(id: '4', name: 'Arcana', votes: 4),
  ];

  // Trayendo las bandas del servidor
  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.socket!.on('active-bands', _handlerActiveBands);
    super.initState();
  }

  _handlerActiveBands(dynamic payload) {
    // print(payload);
    // mapeando el objeto recibido
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket!.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    // print(socketService.serverStatus);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
              margin: EdgeInsets.only(right: 10),
              child: (socketService.serverStatus == ServerStatus.Online)
                  ? Icon(Icons.check_circle, color: Colors.blue[300])
                  : Icon(Icons.offline_bolt, color: Colors.red))
        ],
        centerTitle: true,
        title: Text('BandNames',
            style: TextStyle(
              color: Colors.black87,
            )),
      ),
      body: Column(children: [
        _showGraph(),
        Expanded(
          child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTitle(bands[i])),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
          elevation: 1, child: Icon(Icons.add), onPressed: addNewBand
          // Si nesecito mandar argumentos entonces
          // onPressed: () => addNewBand()
          ),
    );
  }

  Widget _bandTitle(Band band) {
    // Para el voto de las bandas
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      // onDismissed: (direction) {
      //   print('direction $direction banda eliminada : ${band.id}');
      //   socketService.emit('delete-band', {'id': band.id});
      // },
      onDismissed: (_) => socketService.emit('delete-band', {'id': band.id}),
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
        onTap: () =>
            // print(band.name);
            // print(band.id);
            socketService.emit('vote-band', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    // Para poder controlar el texto ingresado
    final textController = TextEditingController();

    // print(Platform.executableArguments);
    // Ahora si yo quiero un dialogo dif para ios entonces:
    if (Platform.isAndroid) {
      return showDialog(
          context: context,
          builder: (_) => AlertDialog(
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
              ));
    }

    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
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
            ));
  }

  // Este metodo es para poder cerrar el dialogo manualmente
  void addBandToList(String name) {
    // emitir: add-band { name : name }
    final socketService = Provider.of<SocketService>(context, listen: false);

    socketService.emit('add-band', {'name': name});
    print(name);
    Navigator.pop(context);
  }

  // Mostrar Grafica
  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    // Map<String, double> dataMap = {
    //   "Flutter": 5,
    //   "React": 3,
    //   "Xamarin": 2,
    //   "Ionic": 2,
    // };

    return Container(
        padding: EdgeInsets.only(top: 10),
        width: double.infinity,
        height: 320,
        child: PieChart(
          dataMap: dataMap,
          animationDuration: Duration(milliseconds: 800),
          chartLegendSpacing: 20,
          // chartRadius: MediaQuery.of(context).size.width / 3.2,
          // colorList: colorList,
          // initialAngleInDegree: 0,
          chartType: ChartType.ring,
          ringStrokeWidth: 15,
          // centerText: "HYBRID",
          legendOptions: LegendOptions(
            showLegendsInRow: false,
            legendPosition: LegendPosition.bottom,
            // showLegends: true,
            legendShape: BoxShape.circle,
            legendTextStyle: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          chartValuesOptions: ChartValuesOptions(
            showChartValueBackground: true,
            showChartValues: true,
            showChartValuesInPercentage: true,
            showChartValuesOutside: false,
            decimalPlaces: 0,
          ),
          // gradientList: ---To add gradient colors---
          // emptyColorGradient: ---Empty Color gradient---
        ));
  }
}
