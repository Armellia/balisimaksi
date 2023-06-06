import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LangkahPage extends StatefulWidget {
  const LangkahPage({Key? key}) : super(key: key);

  @override
  _LangkahPageState createState() => _LangkahPageState();
}

class _LangkahPageState extends State<LangkahPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("LANGKAH PENGAJUAN SIMAKSI"),
            backgroundColor: Colors.green),
        body: ListView(shrinkWrap: true, children: <Widget>[
          const SizedBox(height: 50),
          const Center(
            child: Text(
              "LANGKAH-LANGKAH PENGAJUAN SIMAKSI",
              style: TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Container(
            margin: const EdgeInsets.all(0),
            child: ListView(
              shrinkWrap: true,
              children: const <Widget>[
                Card(
                  child: ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.fileAlt,
                      color: Colors.brown,
                    ),
                    title: Text('Mengisi Formulir Pengajuan SIMAKSI'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.dollarSign,
                      color: Colors.orange,
                    ),
                    title: Text('Melakukan Pembayaran'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: FaIcon(
                      FontAwesomeIcons.handshake,
                      color: Colors.deepOrange,
                    ),
                    title: Text('Mengambil SIMAKSI'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 40,
          ),
        ]));
  }
}
