import 'dart:convert';
import 'dart:io';

import 'package:balisimaksi/app.dart';
import 'package:balisimaksi/main.dart';
import 'package:balisimaksi/widgets/dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'models/rekening.dart';

class FormBayar extends StatefulWidget {
  const FormBayar(
      {Key? key, required this.id, required this.kode, required this.biaya}) //construction
      : super(key: key);
  final String id;
  final String kode;
  final String biaya;

  @override
  _FormBayarState createState() => _FormBayarState();
}

class _FormBayarState extends State<FormBayar> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Rekening> dataRekening = [];
  String txtKode = "";
  String txtBiaya = "0";
  String? txtRekening;
  File? fileBuktiBayar;
  var txtEditKode = TextEditingController();
  var txtEditBiaya = TextEditingController();
  var txtBuktiBayar = TextEditingController();

  Widget buildBuktiBayarFilePicker() {//widget untuk memilih bukti pembayara
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Bukti Bayar harus diupload';
                  } else {
                    return null;
                  }
                },
                controller: txtBuktiBayar,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                  hintText: 'Upload Bukti Bayar',
                  contentPadding: EdgeInsets.all(10.0),
                ),
                style: const TextStyle(fontSize: 16.0)),
          ),
          const SizedBox(width: 5),
          ElevatedButton.icon(
            icon: const Icon(
              Icons.upload_file,
              color: Colors.white,
              size: 24.0,
            ),
            label: const Text('Pilih File', style: TextStyle(fontSize: 16.0)),
            onPressed: () {
              selectBuktiBayarFile(); //memanggil fungsi upload file 
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.amber,
              minimumSize: const Size(122, 48),
              maximumSize: const Size(122, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildOptionRekening() { //widget untuk memilih rekening
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        hint: const Text("Pilih Lokasi Yang Dituju"),
        value: txtRekening,
        items: dataRekening
            .map((data) => DropdownMenuItem<String>(
                  child: Text(data.text.toString()),
                  value: data.id.toString(),
                ))
            .toList(),
        onChanged: (value) {
          setState(() => txtRekening = value.toString());
        },
        validator: (value) =>
            value == null ? 'Pilih rekening pembayaran' : null,
      ),
    );
  }

  selectBuktiBayarFile() async { //fungsi untuk upload file
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']); //mengambil file hanya dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtBuktiBayar.text = result.files.single.name;
        fileBuktiBayar = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  getRekening() async { //fungsi mengambil data rekening dari API
    try {
      final response = await http.get(Uri.parse(apiRekening), headers: {
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
      });//mengambil data rekening melalui api

      if (response.statusCode == 200) {//mengambil data sukses
        final dataDecode = jsonDecode(response.body);
        setState(() {
          for (var i = 0; i < dataDecode.length; i++) {
            dataRekening.add(Rekening.fromJson(dataDecode[i]));
          }
        });
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _validateInputs() {//fungsi validasi
    if (_formKey.currentState!.validate()) {
      //If all data are correct then save data to out variables
      _formKey.currentState!.save();
      simpan();//memanggil fungsi simpan data
    }
  }

  simpan() async { //fungsi penyimpanan proses pembayaran
    final GlobalKey<State> _keyLoader = GlobalKey<State>();
    Dialogs.loading(context, _keyLoader, "proses penyimpanan ...");

    try {
      //post date
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      };
      var request = http.MultipartRequest('POST', Uri.parse(apibayar));//menyimpan data pembayaran melalui API

      request.headers.addAll(headers);
      //request.fields['_token'] = csfr.toString();
      request.fields['id'] = widget.id;
      request.fields['idrek'] = txtRekening.toString();
      request.fields['biaya'] = widget.biaya;

      request.files.add(http.MultipartFile(
          'bukti',
          fileBuktiBayar!.readAsBytes().asStream(),
          fileBuktiBayar!.lengthSync(),
          filename: fileBuktiBayar!.path.split("/").last));

      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      debugPrint("response code: " + res.statusCode.toString());
      debugPrint("response: " + responseString.toString());

      final dataDecode = jsonDecode(responseString);
      if (res.statusCode == 200) {//menyimpan data berhasil
        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Informasi Pendaftaran'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text("Upload data berhasil."),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MyApp()));
                  },
                ),
              ],
            );
          },
        );
      } else {//penyimpanan gagal
        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
        Dialogs.popUp(
            context, 'Proses penyimpanan gagal!' + dataDecode['error']);
      }
    } catch (e) {
      debugPrint('$e');
      Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
      Dialogs.popUp(context, '$e');
    }
  }

  @override
  void initState() {
    txtKode = widget.kode;
    txtEditKode.text = widget.kode;
    txtBiaya = widget.biaya;
    txtEditBiaya.text = widget.biaya;
    getRekening();
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
        title: const Text("FORM PEMBAYARAN"),
        backgroundColor: Colors.green,
      ),
      body: Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Kode Pengajuan", style: TextStyle(fontSize: 16.0)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  key: Key(txtKode),
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode Pengajuan harus diisi';
                    } else {
                      return null;
                    }
                  },
                  controller: txtEditKode,
                  onSaved: (String? val) {
                    txtEditKode.text = val!;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Masukkan Kode Pengajuan',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  style: const TextStyle(fontSize: 16.0)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Total Biaya", style: TextStyle(fontSize: 16.0)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  key: Key(txtBiaya),
                  readOnly: true,
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Biaya harus diisi';
                    } else {
                      return null;
                    }
                  },
                  controller: txtEditBiaya,
                  onSaved: (String? val) {
                    txtEditBiaya.text = val!;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Masukkan Biaya',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  style: const TextStyle(fontSize: 16.0)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Pilih Rekening", style: TextStyle(fontSize: 16.0)),
            ),
            buildOptionRekening(),//memanggil widget menampilkan data rekening
            const Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Text("Upload Bukti Bayar", style: TextStyle(fontSize: 16.0)),
            ),
            buildBuktiBayarFilePicker(),//menampilkan widget upload file
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 32.0,
                ),
                label: const Text('SIMPAN', style: TextStyle(fontSize: 18.0)),
                onPressed: () {
                  _validateInputs();//memanggil fungsi validasi
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.lightBlue,
                  minimumSize: const Size(115, 55),
                  maximumSize: const Size(115, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            )
          ])),
    );
  }
}
