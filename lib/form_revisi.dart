import 'dart:convert';
import 'dart:io';

import 'package:balisimaksi/widgets/dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app.dart';
import 'main.dart';

class PageRevisi extends StatefulWidget {
  const PageRevisi(
      {Key? key, required this.kode, required this.jenis, required this.wni})
      : super(key: key);
  final String kode;
  final String jenis;
  final String wni;
  @override
  _PageRevisiState createState() => _PageRevisiState();
}

class _PageRevisiState extends State<PageRevisi> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<Map> listBerkas = [
    {"id": "1", "name": "Proporsal"},
    {"id": "2", "name": "Identitas"},
    {"id": "3", "name": "Surat Pernyataan"},
    //{"id" : "4", "name" : "Surat Keterangan Jalan dari Kepolisian"},
    //{"id" : "5", "name" : "Surat Izin Penelitian dari Kementrian Riset & Teknologi"},
    {"id": "6", "name": "Surat Rekomendasi dari Mitra Kerja"},
    //{"id" : "7", "name" : "Surat Izin Produksi Pembuatan Film Non Cerita/Cerita di Indonesia"},
    //{"id" : "8", "name" : "Sinopsis"},
    //{"id" : "9", "name" : "Daftar Peralatan"},
    {"id": "10", "name": "Daftar Anggota Tim"},
    //{"id" : "11", "name" : "Kartu Pers"},
  ];

  final List jenisFilm = ["3", "4", "5"];
  var txtFileBerkas = TextEditingController();
  var txtProporsal = TextEditingController();
  var txtFileIdentitas = TextEditingController();
  var txtFileSp = TextEditingController();
  var txtFileRekom = TextEditingController();
  var txtFileAnggota = TextEditingController();
  var txtFileKetPolisi = TextEditingController();
  var txtFileIzinRiset = TextEditingController();
  var txtFileIzinProduksi = TextEditingController();
  var txtFileSinopsis = TextEditingController();
  var txtFileListAlat = TextEditingController();
  var txtFileKartuPers = TextEditingController();
  var txtPwd = TextEditingController();
  String? txtIdBerkas;
  String? txtBerkas;

  File? fileBerkas,
      fileProporsal,
      fileIdentitas,
      fileSP,
      fileketkepolisian,
      fileIzinRiset,
      fileRekom,
      fileIzinProduksi,
      fileSinopsis,
      fileListAlat,
      fileAnggota,
      fileKartuPers;

  Widget buildSelectBerkas() {
    //widget memilih berkas yang ingin diperbaiki
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        hint: const Text("Pilih Berkas Yang Akan Diperbaiki"),
        value: txtIdBerkas,
        items: listBerkas.map((Map item) {
          return DropdownMenuItem(
            child: Text(item['name'].toString()),
            value: item['id'].toString(),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            txtIdBerkas = value.toString();
          });
        },
        validator: (value) =>
            value == null ? 'Pilih Berkas Yang Akan Diperbaiki' : null,
      ),
    );
  }

  Widget buildBerkasFilePicker() {
    //widget upload berkas yg diperbaiki
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                controller: txtFileBerkas,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                  hintText: 'Upload Berkas Yang Dipilih',
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
              selectFileBerkas(); //memanggil fungsi upload berkas
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

  Widget buildProporsalFilePicker() {
    //widget upload proposal
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                controller: txtProporsal,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                  hintText: 'Upload Proposal Kegiatan',
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
              selectProporsalFile(); //memanggil fungsi upload proposal
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

  Widget buildIdentitasFilePicker() {
    //widget upload identitas
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                controller: txtFileIdentitas,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                  hintText: 'Upload KTP/ SIM/ spor',
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
              selectIdentitasFile(); //memanggil fungsi upload identitas
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

  Widget buildSPFilePicker() {
    //widget upload surat pernyataan
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                controller: txtFileSp,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                  hintText: 'Upload Surat Pernyataan',
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
              selectSpFile(); //memanggil fungsi upload identi
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

  Widget buildRekomFilePicker() {
    //widget upload surat rekomendasi
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                controller: txtFileRekom,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                  hintText: 'Upload Surat Rekomendasi/ Pengantar',
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
              selectRekomFile(); //memanggil fungsi upload surat rekomendasi
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

  Widget buildPolisiFilePicker() {
    //widget upload surat rekomendasi
    return Visibility(
      visible: widget.wni == "0" ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  controller: txtFileKetPolisi,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Upload Surat Jalan Kepolisian',
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
                selectPolisiFile(); //memanggil fungsi upload surat kepolisian
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
      ),
    );
  }

  Widget buildFormAnggotaFilePicker() {
    //widget upload form anggota
    return Visibility(
      visible: true,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  controller: txtFileAnggota,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Upload Daftar Anggota Tim',
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
                selectAnggotaFile(); //memanggil fungsi upload form anggota
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
      ),
    );
  }

  Widget buildIzinRisetFilePicker() {
    //widget upload surat izin penelitian
    return Visibility(
      visible: widget.jenis == "1" && widget.wni == "0" ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  controller: txtFileIzinRiset,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Upload Surat Izin Penelitian',
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
                selectSuratIzinRiset(); //memanggil fungsi upload surat izin penelitian
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
      ),
    );
  }

  Widget buildIzinProduksiFilePicker() {
    //widget upload surat izin produksi
    return Visibility(
      visible: widget.jenis == "1" && widget.wni == "0" ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  controller: txtFileIzinProduksi,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Upload Surat Izin Produksi',
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
                selectSuratIzinProduksi(); //memanggil fungsi upload surat izin produksi
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
      ),
    );
  }

  Widget buildSinopsisFilePicker() {
    //widget upload sinopsis
    return Visibility(
      visible: widget.jenis == "1" && widget.wni == "0" ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  controller: txtFileSinopsis,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Upload File Sinopsis',
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
                selectFileSinopsis(); //memanggil fungsi upload sinopsis
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
      ),
    );
  }

  Widget buildDaftarAlatFilePicker() {
    //widget upload daftar perlatan
    return Visibility(
      visible: widget.jenis == "1" && widget.wni == "0" ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  controller: txtFileListAlat,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Upload Daftar Alat',
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
                selectDaftarAlat(); //memanggil fungsi upload daftar perlatan
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
      ),
    );
  }

  Widget buildKartuPersFilePicker() {
    //widget upload kartu pers
    return Visibility(
      visible: widget.jenis == "7" ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  controller: txtFileKartuPers,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Upload Kartu Pers',
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
                selectDaftarAlat(); //memanggil fungsi upload kartu pers
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
      ),
    );
  }

  selectFileBerkas() async {
    //fungsi upload berkas
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileBerkas.text = result.files.single.name;
        fileBerkas = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectProporsalFile() async {
    //fungsi upload proposal
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtProporsal.text = result.files.single.name;
        fileProporsal = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectIdentitasFile() async {
    //fungsi upload identitas
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileIdentitas.text = result.files.single.name;
        fileIdentitas = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectSpFile() async {
    //fungsi upload surat pernyataan
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileSp.text = result.files.single.name;
        fileSP = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectRekomFile() async {
    //fungsi upload surat rekomendasi
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileRekom.text = result.files.single.name;
        fileRekom = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectPolisiFile() async {
    //fungsi upload surat kepolisian
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileKetPolisi.text = result.files.single.name;
        fileketkepolisian = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectAnggotaFile() async {
    //fungsi upload form anggota
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileAnggota.text = result.files.single.name;
        fileAnggota = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectSuratIzinRiset() async {
    //fungsi upload surat izin penelitian
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileIzinRiset.text = result.files.single.name;
        fileIzinRiset = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectSuratIzinProduksi() async {
    //fungsi upload surat izin produksi
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileIzinProduksi.text = result.files.single.name;
        fileIzinProduksi = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectFileSinopsis() async {
    //fungsi upload sinopsis
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileSinopsis.text = result.files.single.name;
        fileSinopsis = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectDaftarAlat() async {
    //fungsi upload daftar perlatan
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileListAlat.text = result.files.single.name;
        fileListAlat = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectKartuPers() async {
    //fungsi upload kartu pers
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']); //memilih file dengan ekstension pdf
    if (result != null) {
      setState(() {
        txtFileKartuPers.text = result.files.single.name;
        fileKartuPers = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  void _validateInputs() {
    //fungsi validasi data
    if (_formKey.currentState!.validate()) {
      //If all data are correct then save data to out variables
      _formKey.currentState!.save();

      simpan();
    }
  }

  simpan() async {
    //fungsi simpan data
    final GlobalKey<State> _keyLoader = GlobalKey<State>();
    Dialogs.loading(context, _keyLoader, "proses penyimpanan ...");
    try {
      //post date
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse(apiSimaksiUpdate)); //menyimpan data melalui API

      debugPrint("API URL: " + apiSimaksiUpdate);
      debugPrint("kodunik: " + widget.kode);
      debugPrint("pwd: " + txtPwd.text);

      request.headers.addAll(headers);
      request.fields['kodeunik'] = widget.kode;
      request.fields['password'] = txtPwd.text;

      if (fileBerkas != null) {
        //berkas tida kosongkosong

        var txtFormFileBerkas = "";
        //select tipe berkas
        switch (txtIdBerkas) {
          case "1":
            txtFormFileBerkas = "proporsal";
            break;
          case "2":
            txtFormFileBerkas = "tandapengenal";
            break;
          case "3":
            txtFormFileBerkas = "suratpernyataan";
            break;
          case "4":
            txtFormFileBerkas = "ket_polisi";
            break;
          case "5":
            txtFormFileBerkas = "fileizinriset";
            break;
          case "6":
            txtFormFileBerkas = "rekom";
            break;
          case "7":
            txtFormFileBerkas = "fileizinproduksi";
            break;
          case "8":
            txtFormFileBerkas = "filesinopsis";
            break;
          case "9":
            txtFormFileBerkas = "listalat";
            break;
          case "10":
            txtFormFileBerkas = "daftaranggota";
            break;
          case "11":
            txtFormFileBerkas = "kartupers";
            break;
        }

        request.files.add(http.MultipartFile(txtFormFileBerkas,
            fileBerkas!.readAsBytes().asStream(), fileBerkas!.lengthSync(),
            filename: fileBerkas!.path.split("/").last));
      }

      /*if (fileProporsal != null) {
        request.files.add(http.MultipartFile(
            'proporsal',
            fileProporsal!.readAsBytes().asStream(),
            fileProporsal!.lengthSync(),
            filename: fileProporsal!.path.split("/").last));
      }

      if (fileIdentitas != null) {
        request.files.add(http.MultipartFile(
            'tandapengenal',
            fileIdentitas!.readAsBytes().asStream(),
            fileIdentitas!.lengthSync(),
            filename: fileIdentitas!.path.split("/").last));
      }

      if (fileSP != null) {
        request.files.add(http.MultipartFile('suratpernyataan',
            fileSP!.readAsBytes().asStream(), fileSP!.lengthSync(),
            filename: fileSP!.path.split("/").last));
      }

      if (fileRekom != null) {
        request.files.add(http.MultipartFile('rekom',
            fileRekom!.readAsBytes().asStream(), fileRekom!.lengthSync(),
            filename: fileRekom!.path.split("/").last));
      }

      if (txtFileKetPolisi.text.isNotEmpty) {
        request.files.add(http.MultipartFile(
            'ket_polisi',
            fileketkepolisian!.readAsBytes().asStream(),
            fileketkepolisian!.lengthSync(),
            filename: fileketkepolisian!.path.split("/").last));
      }

      if (txtFileAnggota.text.isNotEmpty) {
        request.files.add(http.MultipartFile('daftaranggota',
            fileAnggota!.readAsBytes().asStream(), fileAnggota!.lengthSync(),
            filename: fileAnggota!.path.split("/").last));
      }

      if (txtFileIzinRiset.text.isNotEmpty) {
        request.files.add(http.MultipartFile(
            'fileizinriset',
            fileIzinRiset!.readAsBytes().asStream(),
            fileIzinRiset!.lengthSync(),
            filename: fileIzinRiset!.path.split("/").last));
      }

      if (txtFileIzinProduksi.text.isNotEmpty) {
        request.files.add(http.MultipartFile(
            'fileizinproduksi',
            fileIzinProduksi!.readAsBytes().asStream(),
            fileIzinProduksi!.lengthSync(),
            filename: fileIzinProduksi!.path.split("/").last));
      }

      if (txtFileSinopsis.text.isNotEmpty) {
        request.files.add(http.MultipartFile('filesinopsis',
            fileSinopsis!.readAsBytes().asStream(), fileSinopsis!.lengthSync(),
            filename: fileSinopsis!.path.split("/").last));
      }

      if (txtFileListAlat.text.isNotEmpty) {
        request.files.add(http.MultipartFile('listalat',
            fileListAlat!.readAsBytes().asStream(), fileListAlat!.lengthSync(),
            filename: fileListAlat!.path.split("/").last));
      }

      if (txtFileKartuPers.text.isNotEmpty) {
        request.files.add(http.MultipartFile(
            'kartupers',
            fileKartuPers!.readAsBytes().asStream(),
            fileKartuPers!.lengthSync(),
            filename: fileKartuPers!.path.split("/").last));
      }*/

      var res = await request.send();
      debugPrint(res.toString());

      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      debugPrint("response code: " + res.statusCode.toString());
      debugPrint("response: " + responseString.toString());

      final dataDecode = jsonDecode(responseString);
      if (res.statusCode == 200) {
        //perbaikan berhasil
        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
        return showDialog<void>(
          context: context,
          barrierDismissible: false, // user must tap button!
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Informasi Perbaikan'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text(dataDecode['message'].toString()),
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
      } else {
        Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
        Dialogs.popUp(context, 'Proses perbaikan gagal!' + dataDecode['error']);
      }
    } catch (e) {
      debugPrint('$e');
      Navigator.of(_keyLoader.currentContext!, rootNavigator: false).pop();
      Dialogs.popUp(context, '$e');
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.wni.toString() == "0") //wna
    {
      listBerkas
          .add({"id": "4", "name": "Surat Keterangan Jalan dari Kepolisian"});
      if (widget.jenis.toString() == "1") {
        listBerkas.add({
          "id": "5",
          "name": "Surat Izin Penelitian dari Kementrian Riset & Teknologi"
        });
      }

      if (jenisFilm.contains(widget.jenis.toString())) {
        listBerkas.add({
          "id": "7",
          "name":
              "Surat Izin Produksi Pembuatan Film Non Cerita/Cerita di Indonesia"
        });
        listBerkas.add({"id": "8", "name": "Sinopsis"});
        listBerkas.add({"id": "9", "name": "Daftar Peralatan"});
      }
    }

    if (widget.jenis.toString() == "7") {
      listBerkas.add({"id": "11", "name": "Kartu Pers"});
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PERBAIKAN BERKAS"),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Berkas Yang Ingin Diperbaiki",
                  style: TextStyle(fontSize: 16.0)),
            ),
            buildSelectBerkas(), //memanggil widget memilih berkas
            buildBerkasFilePicker(), //memanggil widget upload berkas
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Password", style: TextStyle(fontSize: 16.0)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(

                  //keyboardType: TextInputType.text,
                  obscureText: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Password harus diisi';
                    } else {
                      return null;
                    }
                  },
                  controller: txtPwd,
                  onSaved: (String? val) {
                    txtPwd.text = val!;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Masukkan Password',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  style: const TextStyle(fontSize: 16.0)),
            ),
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
                  _validateInputs(); //memanggil fungsi validasi
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
          ],
        ),
      ),
    );
  }
}
