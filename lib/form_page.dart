import 'dart:convert';
import 'dart:io';

import 'package:balisimaksi/main.dart';
import 'package:balisimaksi/widgets/dialog.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:html/parser.dart';
import 'package:intl/intl.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'models/jenis.dart';
import 'models/kawasan.dart';
import 'models/identitas.dart';
import 'app.dart';

class FormPage extends StatefulWidget {
  const FormPage({Key? key}) : super(key: key);
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Jenis> dataJenis = [];
  List<Kawasan> lokasiKawasan = [];

  List<Identitas> dtIdentitas = [
    Identitas(code: "1", name: "KTP"),
    Identitas(code: "2", name: "SIM"),
    Identitas(code: "3", name: "PASSPOR"),
  ];

  final List jenisFilm = ["3", "4", "5"];

  String? csfr;
  String txtIdentitas = "KTP";
  String txtKodeIdentitas = "";
  String txtNama = "";
  String txtEmail = "";
  String txtTelp = "";
  String txtKegiatan = "";
  String? txtJenis;
  String _jmlanggota = "0";
  String totalAnggota = "0";
  String txtMulai = "";
  String txtSelesai = "";
  String txtTgl = "";
  String txtWn = "1";
  DateTimeRange? dateRange;
  String? txtLokasi;
  var txtDateRange = TextEditingController();
  var rangeTgl = MaskTextInputFormatter(mask: '00/00/0000 00/00/0000');

  var txtEditNoIdentitas = TextEditingController();
  var txtEditNama = TextEditingController();
  var txtEditEmail = TextEditingController();
  var txtEditHp = TextEditingController();
  var txtEditKegiatan = TextEditingController();
  var txtEditJmlAnggota = TextEditingController();
  var txtFileKetPolisi = TextEditingController();
  var txtProporsal = TextEditingController();
  var txtFileIdentitas = TextEditingController();
  var txtFileSp = TextEditingController();
  var txtFileRekom = TextEditingController();
  var txtFileAnggota = TextEditingController();
  var txtFileIzinRiset = TextEditingController();
  var txtFileIzinProduksi = TextEditingController();
  var txtFileSinopsis = TextEditingController();
  var txtFileListAlat = TextEditingController();
  var txtFileKartuPers = TextEditingController();

  File? fileProporsal,
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

  Widget optionWargaNegara() {//widget untuk memilih kewarganegaraan
    return Row(
      children: <Widget>[
        Radio(
          value: "1",
          groupValue: txtWn,
          onChanged: (value) {
            setState(() {
              txtWn = value.toString();
            });
          },
        ),
        const Text("WNI", style: TextStyle(fontSize: 16.0)),
        Radio(
          value: "0",
          groupValue: txtWn,
          onChanged: (value) {
            setState(() {
              txtWn = value.toString();
            });
          },
        ),
        const Text("WNA", style: TextStyle(fontSize: 16.0)),
      ],
    );
  }

  Widget buildOptionIdentitas() {//widget untuk memilih identitas
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        hint: const Text("Pilih Identitas", style: TextStyle(fontSize: 16.0)),
        value: txtIdentitas,
        items: dtIdentitas
            .map((data) => DropdownMenuItem<String>(
                  child: Text(data.name.toString()),
                  value: data.name.toString(),
                ))
            .toList(),
        onChanged: (value) {
          setState(() => txtIdentitas = value.toString());
        },
      ),
    );
  }

  Widget buildOptionLokasiKawasan() {//widget untuk memilih kawasan
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        hint: const Text("Pilih Lokasi Yang Dituju"),
        value: txtLokasi,
        items: lokasiKawasan
            .map((data) => DropdownMenuItem<String>(
                  child: Text(data.text.toString()),
                  value: data.id.toString(),
                ))
            .toList(),
        onChanged: (value) {
          setState(() => txtLokasi = value.toString());
        },
        validator: (value) => value == null ? 'Pilih lokasi yang dituju' : null,
      ),
    );
  }

  Widget buildOptionJenisPengajuan() {//widget untuk memilih jenis pengajuan
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButtonFormField<String>(
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
        validator: (value) => value == null ? 'Pilih jenis pengajuan' : null,
      ),
    );
  }

  Widget optionJmlAnggota() {//widget untuk memilih jumlah anggota
    return Row(
      children: <Widget>[
        Radio(
          value: "0",
          groupValue: _jmlanggota,
          onChanged: (value) {
            setState(() {
              _jmlanggota = value.toString();
            });
          },
        ),
        const Text("1 Orang", style: TextStyle(fontSize: 16.0)),
        Radio(
          value: "1",
          groupValue: _jmlanggota,
          onChanged: (value) {
            setState(() {
              _jmlanggota = value.toString();
              txtEditJmlAnggota.text = value.toString();
            });
          },
        ),
        const Text("> 1 Orang", style: TextStyle(fontSize: 16.0)),
        const SizedBox(width: 10),
        Visibility(
          visible: _jmlanggota == "0" ? false : true,
          child: Expanded(
            child: TextFormField(
                keyboardType: TextInputType.number,
                key: Key(txtKegiatan),
                controller: txtEditJmlAnggota,
                onSaved: (String? val) {
                  txtEditJmlAnggota.text = val!;
                },
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                  hintText: 'Jml Anggota',
                  contentPadding: EdgeInsets.all(10.0),
                ),
                style: const TextStyle(fontSize: 16.0)),
          ),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget buildDatePicker(context) {//widget untuk memilih tanggal
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                controller: txtDateRange,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal harus diisi';
                  } else {
                    return null;
                  }
                },
                inputFormatters: [rangeTgl],
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                  hintText: 'Tanggal Pengajuan',
                  contentPadding: EdgeInsets.all(10.0),
                ),
                style: const TextStyle(fontSize: 16.0)),
          ),
          const SizedBox(width: 5),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  primary: Colors.amber,
                  minimumSize: const Size(70, 48),
                  maximumSize: const Size(70, 48)),
              onPressed: () => pickDateRange(context),//memanggil fungsi pilih tanggal
              child: const FaIcon(
                FontAwesomeIcons.calendarAlt,
                color: Colors.black,
                size: 24.0,
              ))
        ],
      ),
    );
  }

  Widget buildPolisiFilePicker() {//widget menampilkan surat jalan dari kepolisian
    return Visibility(
      visible: txtWn == "0" ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  validator: (String? value) {
                    if (txtWn != "1") {
                      if (value == null || value.isEmpty) {
                        return 'Surat Jalan Kepolisian harus diupload';
                      } else {
                        return null;
                      }
                    }
                  },
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
                selectPolisiFile();//memanggil fungsi upload file surat jalan kepolisian
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

  Widget buildProporsalFilePicker() {//widget menampilkan proposal
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Proposal harus diupload';
                  } else {
                    return null;
                  }
                },
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
              selectProporsalFile();//memanggil fungsi upload file proposal
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

  Widget buildIdentitasFilePicker() {//widget menampilkan identitas //memanggil fungsi upload file identitas
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'file identitas harus diupload';
                  } else {
                    return null;
                  }
                },
                controller: txtFileIdentitas,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      borderSide: BorderSide(color: Colors.white, width: 2)),
                  hintText: 'Upload KTP/ SIM/ Passpor',
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
              selectIdentitasFile();//memanggil fungsi upload file identitas
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

  Widget buildSPFilePicker() { //widget menampilkan surat pernyataan //memanggil fungsi upload file surat pernyataan
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'file surat pernyataan harus diupload';
                  } else {
                    return null;
                  }
                },
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
              selectSpFile();//memanggil fungsi upload file surat pernyataan
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

  Widget buildRekomFilePicker() { //widget menampilkan surat rekomendasi //memanggil fungsi upload file surat rekomendasi
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                readOnly: true,
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'file rekomendasi harus diupload';
                  } else {
                    return null;
                  }
                },
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
              selectRekomFile();//memanggil fungsi upload file surat rekomendasi
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

  Widget buildFormAnggotaFilePicker() {//widget menampilkan form anggota 
    return Visibility(
      visible: _jmlanggota == "0" ? false : true,
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
                selectAnggotaFile();//memanggil fungsi upload file form anggota
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

  Widget buildIzinRisetFilePicker() {//widget menampilkan surat izin penelitian
    return Visibility(
      visible: txtJenis.toString() == "1" && txtWn == "0" ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  validator: (String? value) {
                    if (txtJenis.toString() == "1" && txtWn == "0") {
                      if (value == null || value.isEmpty) {
                        return 'Surat izin penelitian harus diupload';
                      } else {
                        return null;
                      }
                    }
                  },
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
                selectSuratIzinRiset();//memanggil fungsi upload file surat ijin penilitan
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

  Widget buildIzinProduksiFilePicker() {//widget menampilkan surat produksi film 
    return Visibility(
      visible: jenisFilm.contains(txtJenis.toString()) && txtWn == "0"
          ? true
          : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  validator: (String? value) {
                    if (jenisFilm.contains(txtJenis.toString()) &&
                        txtWn == "0") {
                      if (value == null || value.isEmpty) {
                        return 'Surat izin produksi harus diupload';
                      } else {
                        return null;
                      }
                    }
                  },
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
                selectSuratIzinProduksi();//memanggil fungsi upload file surat produksi film
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

  Widget buildSinopsisFilePicker() {//widget menampilkan sinopsis
    return Visibility(
      visible: jenisFilm.contains(txtJenis.toString()) && txtWn == "0"
          ? true
          : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  validator: (String? value) {
                    if (jenisFilm.contains(txtJenis.toString()) &&
                        txtWn == "0") {
                      if (value == null || value.isEmpty) {
                        return 'File sinopsis harus diupload';
                      } else {
                        return null;
                      }
                    }
                  },
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
                selectFileSinopsis(); //memanggil fungsi upload file sinopsis
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

  Widget buildDaftarAlatFilePicker() {//widget menampilkan daftar peralatan 
    return Visibility(
      visible: jenisFilm.contains(txtJenis.toString()) && txtWn == "0"
          ? true
          : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  validator: (String? value) {
                    if (jenisFilm.contains(txtJenis.toString()) &&
                        txtWn == "0") {
                      if (value == null || value.isEmpty) {
                        return 'Daftar alat harus diupload';
                      } else {
                        return null;
                      }
                    }
                  },
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
                selectDaftarAlat();//memanggil fungsi upload file daftar peralatan
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

  Widget buildKartuPersFilePicker() {//widget menampilkan kartu pres 
    return Visibility(
      visible: txtJenis.toString() == "7" ? true : false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                  readOnly: true,
                  validator: (String? value) {
                    if (txtJenis.toString() == "7") {
                      if (value == null || value.isEmpty) {
                        return 'Kartu pers harus diupload';
                      } else {
                        return null;
                      }
                    }
                  },
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
                selectKartuPers();//memanggil fungsi upload file kartu pers
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

  selectPolisiFile() async {//fungsi upload file surat kepolisian
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtFileKetPolisi.text = result.files.single.name;
        fileketkepolisian = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectProporsalFile() async {//fungsi upload file proposal
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtProporsal.text = result.files.single.name;
        fileProporsal = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectIdentitasFile() async {//fungsi upload file identitas
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtFileIdentitas.text = result.files.single.name;
        fileIdentitas = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectSpFile() async {//fungsi upload file surat pernyataan
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtFileSp.text = result.files.single.name;
        fileSP = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectRekomFile() async {//fungsi upload file surat rekomendasi
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtFileRekom.text = result.files.single.name;
        fileRekom = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectAnggotaFile() async {//fungsi upload file form anggota
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtFileAnggota.text = result.files.single.name;
        fileAnggota = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectSuratIzinRiset() async {//fungsi upload file surat izin penelitian
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtFileIzinRiset.text = result.files.single.name;
        fileIzinRiset = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectSuratIzinProduksi() async {//fungsi upload file surat izin produksi
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtFileIzinProduksi.text = result.files.single.name;
        fileIzinProduksi = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectFileSinopsis() async {//fungsi upload file sinopsis
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtFileSinopsis.text = result.files.single.name;
        fileSinopsis = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectDaftarAlat() async {//fungsi upload file daftar peralatan
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtFileListAlat.text = result.files.single.name;
        fileListAlat = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  selectKartuPers() async {//fungsi upload file kartu pers
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);//mengambil file hanya ekstensi pdf
    if (result != null) {
      setState(() {
        txtFileKartuPers.text = result.files.single.name;
        fileKartuPers = File(result.files.single.path.toString());
      });
    } else {
      // User canceled the picker
    }
  }

  Future pickDateRange(BuildContext context) async { //fungsi memilih tanggal
    final initialDateRange = DateTimeRange(
      start: DateTime.now().add(const Duration(hours: 24 * 14)),//14 hari dari hari ini
      end: DateTime.now().add(const Duration(hours: 24 * 21)),//21 hari dari hari ini
    );//tanggal awal ketika membuka kalender
    final newDateRange = await showDateRangePicker(//menampilkan kalender
        context: context,
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 5),
        initialDateRange: dateRange ?? initialDateRange,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxWidth: 400.0, maxHeight: 520.0),
                  child: child,
                ),
              )
            ],
          );
        });

    if (newDateRange == null) return;

    setState(() {
      debugPrint(newDateRange.toString());
      dateRange = newDateRange;
      //split
      String rawDaterange = newDateRange.toString();
      var explode = rawDaterange.split(" - ");
      var first = convertDateFromString(explode[0]).toString();
      var last = convertDateFromString(explode[1]).toString();
      txtTgl = first + " - " + last;
      txtMulai = first;
      txtSelesai = last;
      txtDateRange.text = first + " - " + last;
    });
  }

  convertDateFromString(String strDate) {//fungsi mengubah date menjadi string
    DateTime date = DateTime.parse(strDate);
    return DateFormat("dd/MM/yyyy").format(date);
  }

  getJenisPengajuan() async {//fungsi mengambil data jenis pengajuan dari API
    try {
      final response = await http.get(Uri.parse(apiSimaksiJenis), headers: {
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
      });//mengambil data melalui API

      if (response.statusCode == 200) {//data berhasil diambil
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

  getLokasiPengajuan() async {//fungsi mengambil data kawasan dari API
    try {
      final response = await http.get(Uri.parse(apiSimaksiLokasi), headers: {
        'Authorization': token,
        'Content-Type': 'application/json; charset=UTF-8',
      });//mengambil data melalui API

      if (response.statusCode == 200) {//data berhasil diambil
        final dataKawasan = jsonDecode(response.body);

        setState(() {
          for (var i = 0; i < dataKawasan.length; i++) {
            lokasiKawasan.add(Kawasan.fromJson(dataKawasan[i]));
          }
        });
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _validateInputs() {//fungsi validasi data
    if (_formKey.currentState!.validate()) {
      //If all data are correct then save data to out variables
      _formKey.currentState!.save();
      if (_jmlanggota == "1" && txtEditJmlAnggota.text.isEmpty) {
        Dialogs.popUp(context, "Jumlah Anggota harus diisi");
        return;
      }

      if (_jmlanggota == "1" && txtFileAnggota.text.isEmpty) {
        Dialogs.popUp(context, "Upload form anggota tim");
        return;
      }

      simpan();
    }
  }

  simpan() async {//fungsi simpan data
    final String wni = txtWn;
    final String identitas = txtIdentitas;
    final String noidentitas = txtEditNoIdentitas.text; //txtKodeIdentitas;
    final String nama = txtEditNama.text; //txtNama;
    final String email = txtEditEmail.text; //txtEmail;
    final String hp = txtEditHp.text; //txtTelp;
    final String idlokasi = txtLokasi.toString();
    final String idjenis = txtJenis.toString();
    final String kegiatan = txtEditKegiatan.text; //txtKegiatan;

    var expMulai = txtMulai.split("/");
    var yM = expMulai[2];
    var mM = expMulai[1];
    var dM = expMulai[0];

    final String mulai = yM + "-" + mM + "-" + dM;

    var expSelesai = txtSelesai.split("/");
    var yS = expSelesai[2];
    var mS = expSelesai[1];
    var dS = expSelesai[0];

    final String selesai = yS + "-" + mS + "-" + dS;
    final GlobalKey<State> _keyLoader = GlobalKey<State>();
    Dialogs.loading(context, _keyLoader, "proses penyimpanan ...");
    try {
      //post date
      Map<String, String> headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token
      };
      var request = http.MultipartRequest('POST', Uri.parse(apiSimaksiPost));//fungsi menyimpan data melalui API

      request.headers.addAll(headers);
      //request.fields['_token'] = csfr.toString();
      request.fields['wni'] = wni;
      request.fields['identitas'] = identitas;
      request.fields['noidentitas'] = noidentitas;
      request.fields['nama'] = nama;
      request.fields['email'] = email;
      request.fields['hp'] = hp;
      request.fields['idlokasi'] = idlokasi;
      request.fields['idjenissimaksi'] = idjenis;
      //request.fields['tgl'] = mulai + " - " + selesai;
      request.fields['mulai'] = mulai;
      request.fields['selesai'] = selesai;
      request.fields['namakegiatan'] = kegiatan;
      request.fields['total_anggota'] = txtEditJmlAnggota.text;

      request.files.add(http.MultipartFile('proporsal',
          fileProporsal!.readAsBytes().asStream(), fileProporsal!.lengthSync(),
          filename: fileProporsal!.path.split("/").last));

      request.files.add(http.MultipartFile('tandapengenal',
          fileIdentitas!.readAsBytes().asStream(), fileIdentitas!.lengthSync(),
          filename: fileIdentitas!.path.split("/").last));

      request.files.add(http.MultipartFile('suratpernyataan',
          fileSP!.readAsBytes().asStream(), fileSP!.lengthSync(),
          filename: fileSP!.path.split("/").last));

      request.files.add(http.MultipartFile(
          'rekom', fileRekom!.readAsBytes().asStream(), fileRekom!.lengthSync(),
          filename: fileRekom!.path.split("/").last));

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
      }

      request.fields['group'] = _jmlanggota;
      var res = await request.send();
      var responseBytes = await res.stream.toBytes();
      var responseString = utf8.decode(responseBytes);

      debugPrint("response code: " + res.statusCode.toString());
      debugPrint("response: " + responseString.toString());

      final dataDecode = jsonDecode(responseString);
      if (res.statusCode == 200) {//penyimpanan data berhasil
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
                    Text(
                        "Pengajuan berhasil. Silahkan cek email untuk melakukan konfirmasi pembayaran"),
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
    getJenisPengajuan();
    getLokasiPengajuan();
    txtEditJmlAnggota.text = "0";
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FORMULIR PENGAJUAN SIMAKSI"),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Kewarganegaraan", style: TextStyle(fontSize: 16.0)),
            ),
            optionWargaNegara(),//memanggil widget warga negara
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Jenis Identitas", style: TextStyle(fontSize: 16.0)),
            ),
            buildOptionIdentitas(),//memanggil widget identitas
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Identitas", style: TextStyle(fontSize: 16.0)),
            ),
            //inputNoIdentitas,
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  key: Key(txtKodeIdentitas),
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Kode Identitas harus diisi';
                    } else {
                      return null;
                    }
                  },
                  controller: txtEditNoIdentitas,
                  onSaved: (String? val) {
                    txtEditNoIdentitas.text = val!;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Masukkan Kode Identitas',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  style: const TextStyle(fontSize: 16.0)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Nama Pemohon", style: TextStyle(fontSize: 16.0)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  key: Key(txtNama),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Pemohon harus diisi';
                    } else {
                      return null;
                    }
                  },
                  controller: txtEditNama,
                  onSaved: (String? val) {
                    txtEditNama.text = val!;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Nama Pemohon',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  style: const TextStyle(fontSize: 16.0)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("*Informasi Akan Dikirim Ke Email",
                  style: TextStyle(fontSize: 16.0)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  key: Key(txtEmail),
                  keyboardType: TextInputType.emailAddress,
                  validator: (email) =>
                      email != null && !EmailValidator.validate(email)
                          ? 'Masukkan email yang valid'
                          : null,
                  controller: txtEditEmail,
                  onSaved: (String? val) {
                    txtEditEmail.text = val!;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Email Pemohon',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  style: const TextStyle(fontSize: 16.0)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Telpon", style: TextStyle(fontSize: 16.0)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  key: Key(txtTelp),
                  keyboardType: TextInputType.number,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'No. Telp harus diisi';
                    } else {
                      return null;
                    }
                  },
                  //initialValue: txtTelp,
                  controller: txtEditHp,
                  onSaved: (String? val) {
                    txtEditHp.text = val!;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'No. Telp Pemohon',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  style: const TextStyle(fontSize: 16.0)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Lokasi Kawasan", style: TextStyle(fontSize: 16.0)),
            ),
            buildOptionLokasiKawasan(),//memanggil widget kawasan
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Jenis Pengajuan", style: TextStyle(fontSize: 16.0)),
            ),
            buildOptionJenisPengajuan(),//memanggil widget jenis pengajuan
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  "Tanggal Pengajuan (mulai - berakhir) *Minimal 2 Minggu dari hari ini",
                  style: TextStyle(fontSize: 16.0)),
            ),
            buildDatePicker(context),//memanggil widget memilih tanggal
            Visibility(
              visible: txtWn == "0" ? true : false,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Surat Keterangan Jalan dari Kepolisian",
                    style: TextStyle(fontSize: 16.0)),
              ),
            ),
            buildPolisiFilePicker(),//memanggil widget upload surat jalan kepolisian
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Nama Kegiatan", style: TextStyle(fontSize: 16.0)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                  key: Key(txtKegiatan),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama Kegiatan harus diisi';
                    } else {
                      return null;
                    }
                  },
                  controller: txtEditKegiatan,
                  onSaved: (String? val) {
                    txtEditKegiatan.text = val!;
                  },
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(5.0),
                        ),
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    hintText: 'Nama Kegiatan',
                    contentPadding: EdgeInsets.all(10.0),
                  ),
                  style: const TextStyle(fontSize: 16.0)),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Text("Proposal Kegiatan", style: TextStyle(fontSize: 16.0)),
            ),
            buildProporsalFilePicker(),//memanggil widget upload proposal
            const Padding(
              padding: EdgeInsets.all(8.0),
              child:
                  Text("KTP / Paspor / SIM", style: TextStyle(fontSize: 16.0)),
            ),
            buildIdentitasFilePicker(),//memanggil upload widget identitas
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Surat Pernyataan", style: TextStyle(fontSize: 16.0)),
            ),
            buildSPFilePicker(),//memanggil widget upload surat pernyataan
            Visibility(
              visible:
                  txtJenis.toString() == "1" && txtWn == "0" ? true : false,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    "Surat Izin Penelitian dari Kementrian Riset dan Teknologi",
                    style: TextStyle(fontSize: 16.0)),
              ),
            ),
            buildIzinRisetFilePicker(),//memanggil widget upload surat izin penelitian
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  "Surat Rekomendasi / Pengantar dari Mitra Kerja / Instansi",
                  style: TextStyle(fontSize: 16.0)),
            ),
            buildRekomFilePicker(),//memanggil widget upload surat rekomendasi
            Visibility(
              visible: txtJenis.toString() == "7" ? true : false,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Kartu Pers dari Lembaga yang Berwenang",
                    style: TextStyle(fontSize: 16.0)),
              ),
            ),
            buildKartuPersFilePicker(),//memanggil widget upload kartu pers
            Visibility(
              visible: jenisFilm.contains(txtJenis.toString()) && txtWn == "0"
                  ? true
                  : false,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                    "Surat Izin Produksi Pembuatan Film Non Cerita/Cerita di Indonesia dari Kementrian Pariwisata dan Ekonomi Kreatif",
                    style: TextStyle(fontSize: 16.0)),
              ),
            ),
            buildIzinProduksiFilePicker(),//memanggil widget upload surat izin produksi
            Visibility(
              visible: jenisFilm.contains(txtJenis.toString()) && txtWn == "0"
                  ? true
                  : false,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Sinopsis", style: TextStyle(fontSize: 16.0)),
              ),
            ),
            buildSinopsisFilePicker(),//memanggil widget upload sinopsis
            Visibility(
              visible: jenisFilm.contains(txtJenis.toString()) && txtWn == "0"
                  ? true
                  : false,
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child:
                    Text("Daftar Peralatan", style: TextStyle(fontSize: 16.0)),
              ),
            ),
            buildDaftarAlatFilePicker(),//memanggil widget upload daftar peralatan
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text("Jumlah Orang Masuk Kawasan",
                  style: TextStyle(fontSize: 16.0)),
            ),
            optionJmlAnggota(),//memanggil widget memilih jumlah anggota
            buildFormAnggotaFilePicker(),//memanggil widget upload jumlah anggota
            Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.only(bottom: 10),
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 32.0,
                ),
                label: const Text('BUAT PENGAJUAN',
                    style: TextStyle(fontSize: 18.0)),
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
          ],
        ),
      ),
    );
  }
}
