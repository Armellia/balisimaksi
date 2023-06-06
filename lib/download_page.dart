import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:balisimaksi/app.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'models/jenis.dart';
import 'widgets/dialog.dart';

class DownloadPage extends StatefulWidget {
  const DownloadPage({Key? key}) : super(key: key);

  @override
  _DownloadPageState createState() => _DownloadPageState();
}

class _DownloadPageState extends State<DownloadPage> {
  final GlobalKey<State> _keyLoader = GlobalKey<State>();
  String manualBookUrl = "https://cdn.sobatcoding.com/articles/manualbook.pdf";
  String urlFormAnggota =
      "https://cdn.sobatcoding.com/articles/FORM SURAT PERNYATAAN SIMAKSI - ILMU PENGETAHUAN DAN PENDIDIKAN 2021.docx";
  List<dynamic> linkSP = [
    "https://cdn.sobatcoding.com/articles/FORM SURAT PERNYATAAN SIMAKSI - PENELITIAN 2021.pdf", //link SP file penelitian dan pengembangan
    "https://cdn.sobatcoding.com/articles/FORM SURAT PERNYATAAN SIMAKSI - ILMU PENGETAHUAN DAN PENDIDIKAN 2021.docx", //link SP file ilmu pengetahuan dan pendidikan
    "https://cdn.sobatcoding.com/articles/FORM SURAT PERNYATAAN SIMAKSI - FILM KOMERSIAL 2021.pdf", //link SP file film komersil
    "https://cdn.sobatcoding.com/articles/FORM SURAT PERNYATAAN SIMAKSI - FILM NON KOMERSIAL 2021.pdf", //link SP file film non komersil
    "https://cdn.sobatcoding.com/articles/FORM SURAT PERNYATAAN SIMAKSI - FILM DOKUMENTER 2021.pdf", //link SP file film dokumenter
    "https://cdn.sobatcoding.com/articles/FORM SURAT PERNYATAAN SIMAKSI - EKSPEDISI 2021.pdf", //link SP file ekspedisi
    "https://cdn.sobatcoding.com/articles/FORM SURAT PERNYATAAN SIMAKSI - JURNALISTIK 2021" //link SP file journalistik
  ];
  String? txtJenis;
  List<Jenis> dataJenis = [];
  String fileNameDownloaded = "";
  String downloadedFilePath = "";
  int progress = 0;
  final ReceivePort _receivePort = ReceivePort();

  static void downloadingCallback(
      String id, DownloadTaskStatus status, int progress) {
    //Looking up for a send port
    SendPort? sendPort = IsolateNameServer.lookupPortByName("downloading");
    //sending the data
    sendPort!.send([id, status, progress]);
  }
  
  Future<void> downloadFile(String urlDownload, String filename) async { //fungsi download
    final status = await Permission.storage.request(); //perizinan file

    if (status.isGranted) { //jika izin akses file diberikan
      String pathDir = ""; 
      final Directory _appDocDirFolder =
          Directory('/storage/emulated/0/Download/'); //cek storage 
      if (await _appDocDirFolder.exists()) { //jika storage ada
        pathDir = "/storage/emulated/0/Download/"; 
      } else { //jika storage tidak ada
        final Directory _appDocDirNewFolder =
            await _appDocDirFolder.create(recursive: true); //buat baru
        pathDir = _appDocDirNewFolder.path;
      }

      //cek apakah file ada
      final String file = pathDir + "/" + filename;
      setState(() {
        downloadedFilePath = file;
        fileNameDownloaded = filename;
      });

      if (await File(file).exists()) { //jika file ada
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File ' + fileNameDownloaded + ' telah didownload'),
            action: SnackBarAction(
              label: 'BUKA',
              onPressed: () async {
                await OpenFile.open(file); //membuka file
              },
            ),
          ),
        );
      } else { //jika file tidak ada
        Dialogs.loading(context, _keyLoader, "Proses download file ");
        await FlutterDownloader.enqueue(
          url: urlDownload,
          savedDir:
              pathDir, //"/storage/emulated/0/Download/", //externalDir!.path,
          fileName: filename,
          showNotification: true,
          openFileFromNotification: true,
        );
      }
    } else {//jika izin akses file tidak diberikan
      debugPrint("Permission deined");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission deined'),
        ),
      );
    }
  }

  Future<void> openFile(String filePath) async { //fungsi membuka file
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      await OpenFile.open(filePath);
    } else {
      debugPrint("file not found");
    }
  }

  getJenisPengajuan() async { //mendownload surat pernyataan
    try {
      final response = await http.get(Uri.parse(apiSimaksiJenis), headers: {
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
      }); //mengambil data melalui API

      if (response.statusCode == 200) { //data berhasil diambil
        final dataDecode = jsonDecode(response.body);
        setState(() {
          for (var i = 0; i < dataDecode.length; i++) {
            dataJenis.add(Jenis.fromJson(dataDecode[i]));
          }
        });
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  void initState() {
    //register a send port for the other isolates
    IsolateNameServer.registerPortWithName(
        _receivePort.sendPort, "downloading");
    //Listening for the data is comming other isolataes
    _receivePort.listen((dynamic data) {
      //String id = data[0];
      DownloadTaskStatus status = data[1];
      int progressing = data[2];
      //debugPrint("id => " + id);
      if (status == DownloadTaskStatus.complete) { //menampilkan alert ketika proses download selesai
        debugPrint("Download complete ....");
        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('File ' + fileNameDownloaded + ' berhasil didownload'),
            action: SnackBarAction(
              label: 'BUKA',
              onPressed: () => openFile(downloadedFilePath), //memanggil fungsi membuka file
            ),
          ),
        );
      }
      if (progressing != -1) { //menampilkan alert ketika proses download berjalan
        debugPrint("Download progress ....");
        setState(() {
          progress = data[2];
        });
      }
    });

    FlutterDownloader.registerCallback(downloadingCallback);
    getJenisPengajuan();
    super.initState();
  }

  @override
  dispose() {
    IsolateNameServer.removePortNameMapping('downloading');
    super.dispose();
  }

  Widget buildOptionJenisPengajuan() { //widget memilih jenis pengajan 
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField(
        isExpanded: true,
        hint: const Text("Pilih Jenis Pengajuan"),
        value: txtJenis,
        items: dataJenis.map((item) {
          return DropdownMenuItem(
            child: Text(item.text.toString()),
            value: item.id.toString(),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            txtJenis = value.toString();
          });
        },
      ),
    );
  }

  Widget buttonDownload() { //widget tombol download berubah sesuai dengan jenis pengajuan yang dipilih
    String titleSurat = "";
    String urLFile = "";
    String downloadName = "surat-pernyataan-simaksi.docx";
    switch (txtJenis) {
      case "1":
        titleSurat = "Penelitian dan Pengembangan";
        urLFile = linkSP[0];
        downloadName = "surat-pernyataan-simaksi-penelitian-pengembangan.pdf";
        break;
      case "2":
        titleSurat = "Ilmu Pengetahuan dan Pendidikan";
        urLFile = linkSP[1];
        downloadName =
            "surat-pernyataan-simaksi-ilmu-pengetahuan-pendidikan.docx";
        break;
      case "3":
        titleSurat = "Pembuatan Film Komersil";
        urLFile = linkSP[2];
        downloadName = "surat-pernyataan-simaksi-film-komersil.pdf";
        break;
      case "4":
        titleSurat = "Pembuatan Film Non Komersil";
        urLFile = linkSP[3];
        downloadName = "surat-pernyataan-simaksi-film-nonkomersil.pdf";
        break;
      case "5":
        titleSurat = "Pembuatan Film Dokumenter";
        downloadName = "surat-pernyataan-simaksi-film-dokumenter.pdf";
        urLFile = linkSP[4];
        break;
      case "6":
        titleSurat = "Ekspedisi";
        urLFile = linkSP[5];
        downloadName = "surat-pernyataan-simaksi-ekspedisi.pdf";
        break;
      case "7":
        titleSurat = "Jurnalistik";
        urLFile = linkSP[6];
        downloadName = "surat-pernyataan-simaksi-jurnalistik.pdf";
        break;
    }

    debugPrint("linkFIle: " + urLFile);
    debugPrint("downloadName: " + downloadName);
    return Visibility(
      visible: titleSurat.isEmpty ? false : true, //cek apakah ada jenis pengajuan yang dipilih
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(primary: Colors.redAccent),
            onPressed: () => downloadFile(urLFile, downloadName),//memanggil fungsi download
            child: Text("DOWNLOAD SURAT " + titleSurat.toUpperCase(),
                style: const TextStyle(fontSize: 14.0))),
      ),
    );
  }

  //tampilan utama
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Panduan SIMAKSI"),
            backgroundColor: Colors.green),
        body: ListView(
          shrinkWrap: true,
          children: [
            ClipPath(
                child: Container(
              width: double.infinity,
              height: 380,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bingung-md.png'),
                  fit: BoxFit.contain,
                ),
              ),
            )),
            const Text(
              "Bingung Mengajukan SIMAKSI ?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            const Text(
              "Atau Ingin Tau Cara Perpanjang SIMAKSI?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
              child: Text("KLIK DISINI"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.lightBlue),
                  onPressed: () => downloadFile( //memanggil fungsi download
                      manualBookUrl, "manual-book-simaksi-online.pdf"),
                  child: const Text("MANUAL BOOK SIMAKSI ONLINE",
                      style: TextStyle(fontSize: 16.0))),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
              child: Text("SURAT PERNYATAAN"),
            ),
            buildOptionJenisPengajuan(), //memanggil widget memilih jenis pengajuan
            buttonDownload(),  //memanggil widget tulisan download
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
              child: Text("FORM DAFTAR ANGGOTA"),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0, right: 8.0),
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(primary: Colors.amber),
                  onPressed: () =>
                      downloadFile(urlFormAnggota, "form-anggota.docx"),//memanggil fungsi download
                  child: const Text("FORM DAFTAR ANGGOTA",
                      style: TextStyle(fontSize: 16.0))),
            ),
          ],
        ));
  }
}
