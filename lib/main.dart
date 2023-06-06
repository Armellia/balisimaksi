import 'dart:convert';

import 'package:balisimaksi/app.dart';
import 'package:balisimaksi/download_page.dart';
import 'package:balisimaksi/form_bayar.dart';
import 'package:balisimaksi/form_page.dart';
import 'package:balisimaksi/form_revisi.dart';
import 'package:balisimaksi/jenis_page.dart';
import 'package:balisimaksi/langkah_page.dart';
import 'package:balisimaksi/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug: true // optional: set false to disable printing logs to console
      );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMAKSI BKSDA BALI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'SIMAKSI BKSDA BALI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class CustomClipPath extends CustomClipper<Path> {
  //membuat clippath
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(
        size.width / 4, size.height - 40, size.width / 2, size.height - 20);
    path.quadraticBezierTo(
        3 / 4 * size.width, size.height, size.width, size.height - 30);
    path.lineTo(size.width, 0);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  late TextEditingController txtkodeSimasi;

  String idPengajuan = "";
  String kodeSimaksi = "";
  String namaPemohon = "";
  String jenisPengajuan = "";
  String idJenis = "";
  String txtWni = "";
  String lokasiPengajuan = "";
  String namaKegiatan = "";
  String startTgl = "";
  String endTgl = "";
  String statusBerkas = "";
  String idStatus = "";
  String totalBiaya = "0";
  String alasanDitolak = "";
  List<TableRow> rows = [];

  cekSimaksi() async {
    //fungsi caru simaksi
    if (txtkodeSimasi.text.isEmpty) {
      //field kosong
      popupSimaksi(""); //memanggil widget popup simaksi dengan parameter kosong
    } else {
      Dialogs.loading(context, _keyLoader, "loading ...");
      try {
        final apiSimaksi = apicekSimaksi + txtkodeSimasi.text;

        debugPrint('API URL :' + apiSimaksi);

        final response = await http.get(Uri.parse(apiSimaksi), headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token
        }); //mengambil data melalui api
        debugPrint('response : ' + response.statusCode.toString());
        if (response.statusCode == 200) {
          //data berhasil diambil
          final dataDecode = jsonDecode(response.body);
          debugPrint(dataDecode.toString());

          if (dataDecode.toString() != "{}") {
            //set state
            setState(() {
              idPengajuan = dataDecode['id'].toString();
              kodeSimaksi = dataDecode['kodeunik'];
              namaPemohon = dataDecode['nama'];
              namaKegiatan = dataDecode['namakegiatan'];
              jenisPengajuan = dataDecode['jenis']['keterangan'];
              lokasiPengajuan = dataDecode['lokasi']['nama'];
              startTgl = dataDecode['mulai'];
              endTgl = dataDecode['selesai'];
              statusBerkas = dataDecode['status_simaksi']['status'];
              idStatus = dataDecode['status'].toString();
              totalBiaya = dataDecode['biaya'].toString();
              idJenis = dataDecode['idjenissimaksi'].toString();
              txtWni = dataDecode['wni'].toString();
              alasanDitolak = dataDecode['alasan'].toString();

              var berkas = dataDecode['berkas'];
              rows.clear();
              for (var file in berkas) {
                rows.add(TableRow(children: <Widget>[
                  Text(file['jenis']['keterangan'].toString(),
                      style: const TextStyle(
                          height: 2.0,
                          fontSize: 14.0,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    child: IconButton(
                        onPressed: () {
                          launchInBrowser(baseURL +
                              file['file']
                                  .toString()); //memanggil fungsi buka di browser
                        },
                        icon: const Icon(
                          Icons.cloud_download_outlined,
                          color: Colors.lightBlue,
                        )),
                  ),
                ]));
              }
              //txtkodeSimasi.text = "";
            });
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
            popupSimaksi(txtkodeSimasi.text);
          } else {
            //data tidak ditemukan
            Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
            Dialogs.popUp(context, "Data tidak ditemukan");
          }
        }
      } catch (e) {
        Navigator.of(_keyLoader.currentContext!, rootNavigator: true).pop();
        debugPrint('$e');
      }
    }
  }

  popupSimaksi(kodeSimaksi) {
    //widget untuk menampilkan popup pencarian simaksi
    return showDialog<void>(
      context: context, barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        if (kodeSimaksi.isEmpty) {
          //jika kode simaksi kosong
          return AlertDialog(
            title: const Text('Informasi'),
            content: SingleChildScrollView(
              child: ListBody(
                children: const <Widget>[
                  Text("Kode SIMAKSI harus diisi"),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        } else {
          //jika kode simaksi ada
          return AlertDialog(
            title: const Text('SIMAKSI'),
            content: SingleChildScrollView(
                child: ListBody(children: <Widget>[
              const Text("Kode Pengajuan :", style: TextStyle(fontSize: 16.0)),
              Text(kodeSimaksi,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Lokasi - Jenis :", style: TextStyle(fontSize: 16.0)),
              Text(lokasiPengajuan + " - " + jenisPengajuan,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Waktu :", style: TextStyle(fontSize: 16.0)),
              Text(startTgl + " sd " + endTgl,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Biaya :", style: TextStyle(fontSize: 16.0)),
              Text(totalBiaya,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Status Pengerjaan :",
                  style: TextStyle(fontSize: 16.0)),
              Text(statusBerkas,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Visibility(
                  visible: idStatus == "5" ? true : false,
                  child: const Text("Alasan Ditolak :",
                      style: TextStyle(fontSize: 16.0))),
              Visibility(
                visible: idStatus == "5" ? true : false,
                child: Text(
                    (alasanDitolak.toString() == "null"
                        ? ""
                        : alasanDitolak.toString()),
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold)),
              ),
              Visibility(
                  visible: idStatus == "5" ? true : false,
                  child: const SizedBox(height: 20)),
              const Text("Berkas yang telah diupload :",
                  style: TextStyle(fontSize: 16.0)),
              buildListBerkas(), //memanggil widget menampilkan berkas
              const SizedBox(height: 20),
              Visibility(
                visible: idStatus == "1" || idStatus == "5" ? true : false,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(primary: Colors.amber),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PageRevisi(
                                    kode: kodeSimaksi,
                                    jenis: idJenis,
                                    wni: txtWni,
                                  )));
                    },
                    icon: const Icon(Icons.attach_file),
                    label: const Text("PERBAIKI BERKAS")),
              ),
              Visibility(
                visible: idStatus == "2" && totalBiaya != "0" ? true : false,
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(primary: Colors.lightBlue),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FormBayar(
                                  id: idPengajuan,
                                  kode: kodeSimaksi,
                                  biaya: totalBiaya)));
                    },
                    icon: const Icon(Icons.payment),
                    label: const Text("Konfirmasi Pembayaran")),
              ),
            ])),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> launchInBrowser(String url) async {
    //fungsi membuka berkas pada browser
    if (!await launch(
      Uri.encodeFull(url),
      forceSafariVC: false,
      forceWebView: false,
      headers: <String, String>{'my_header_key': 'my_header_value'},
    )) {
      debugPrint('Could not launch $url');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("Info"),
              content: Text('Could not launch $url'),
              actions: [
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        },
      );
    }
  }

  Widget buildListBerkas() {
    //widget menampilkan list berkas
    return Table(
        columnWidths: const <int, TableColumnWidth>{
          0: IntrinsicColumnWidth(),
          1: FlexColumnWidth()
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: rows);
  }

  @override
  void initState() {
    super.initState();
    txtkodeSimasi = TextEditingController();
  }

  @override
  void dispose() {
    txtkodeSimasi.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 60,
                width: double.infinity,
                padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
                color: Colors.green,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 40,
                      height: 40,
                      child: const CircleAvatar(
                        backgroundImage:
                            AssetImage("assets/images/logo-md.png"),
                      ),
                    ),
                    Text(
                      widget.title,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    const Spacer(),
                    PopupMenuButton(
                      child: ElevatedButton(
                        onPressed: null,
                        child: const Icon(Icons.menu, color: Colors.white),
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(0),
                          primary: Colors.blue, // <-- Button color
                          onPrimary: Colors.red, // <-- Splash color
                        ),
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem<int>(
                          value: 0,
                          child: Text(
                            "Jenis SIMAKSI",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const PopupMenuItem<int>(
                          value: 1,
                          child: Text(
                            "Langkah Pengajuan SIMAKSI",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        const PopupMenuItem<int>(
                          value: 2,
                          child: Text(
                            "Download",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ],
                      onSelected: (item) => selectedItem(context, item),
                    ),
                  ],
                ),
              ),
            ),
            ClipPath(
              clipper: CustomClipPath(), //memanggil class customclippath
              child: Container(
                  width: double.infinity,
                  height: 400,
                  color: Colors.green.shade500,
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        const SizedBox(
                          height: 50,
                        ),
                        const Text(
                          'SIMAKSI',
                          style: TextStyle(
                              fontSize: 45.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        const Text(
                          'SURAT IJIN MASUK KAWASAN SUAKA ALAM DAN KAWASAN PELESTARIAN ALAM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        const Text(
                          'Mau Masuk Kawasan ? Cek Status SIMAKSI ?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          child: TextField(
                            obscureText: false,
                            controller: txtkodeSimasi,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              labelText: 'Masukkan Kode SIMAKSI',
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              cekSimaksi(); //memanggil fungsi cari simaksi
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(12.0),
                              child: Text(
                                "CEK SIMAKSI",
                                style: TextStyle(
                                    fontSize: 17.0, color: Colors.white),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                elevation: 10,
                                onPrimary: Colors.white,
                                primary: Colors.lightBlue),
                          ),
                        )
                      ],
                    ),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              margin: const EdgeInsets.all(0),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 140,
                    height: 140,
                    child: const CircleAvatar(
                      backgroundImage: AssetImage("assets/images/logo-md.png"),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "TENTANG KAMI",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const Text("KEMENTRIAN LINGKUNGAN HIDUP DAN KEHUTANAN",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w400)),
                  const Text(
                      "Jln. Suwung Batan Kendal No. 37 Sesetan, Denpasar 80223, Bali",
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w400)),
                  const Text("info@ksda-bali.go.id",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w400)),
                  const Text("(0361) 720 063",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w400)),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const FormPage()));
        },
        label: const Text('BUAT PERMOHONAN SIMAKSI',
            style: TextStyle(fontSize: 12.0)),
        icon: const Icon(Icons.app_registration),
        backgroundColor: Colors.pink,
      ),
    );
  }

  void selectedItem(BuildContext context, item) {
    //fungsi untuk memilih popup menu
    switch (item) {
      case 0:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const JenisPage()));
        break;
      case 1:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => const LangkahPage()));
        break;
      case 2:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DownloadPage()));
        break;
    }
  }
}
