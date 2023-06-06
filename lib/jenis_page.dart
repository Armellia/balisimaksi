
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class JenisPage extends StatefulWidget {
  const JenisPage({Key? key}) : super(key: key);

  @override
  _JenisPageState createState() => _JenisPageState();
}

class _JenisPageState extends State<JenisPage> {
  final List jenisFilm = ["3", "4", "5"];

  modalInfoSyarat(caseIn) {//fungsi memilih jenis pengajuan saat diklik
    var title = "";
    switch (caseIn) {
      case 1:
        title = "Penelitian dan Pengembangan";
        break;
      case 2:
        title = "Ilmu Pengetahuan dan Pendidikan";
        break;
      case 3:
        title = "Pembuatan Film Komersil";
        break;
      case 4:
        title = "Pembuatan Film Non Komersil";
        break;
      case 5:
        title = "Pembuatan Film Dokumenter";
        break;
      case 6:
        title = "Ekspedisi";
        break;
      case 7:
        title = "Jurnalistik";
        break;
    }

    return showDialog<void>(//menampilkan dialog/popup/modal
      context: context, barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text("Persyaratan",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                const Text("Warga Negara Asing (WNA)",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                const Text("Surat Keterangan Jalan Dari Kepolisian",
                    style: TextStyle(fontSize: 14.0)),
                const Text("Proposal Kegiatan",
                    style: TextStyle(fontSize: 14.0)),
                const Text("Fotokopi Paspor", style: TextStyle(fontSize: 14.0)),
                const Text(
                    "Surat Pernyataan Tentang Kesanggupan Untuk Mematuhi Ketentuan Perundang-undangan, Dengan Format yang Berlaku",
                    style: TextStyle(fontSize: 14.0)),
                Visibility(
                  visible: caseIn.toString() == '1' ? true : false,
                  child: const Text(
                      "Surat Izin Penelitian dari Kementrian Riset dan Teknologi",
                      style: TextStyle(fontSize: 14.0)),
                ),
                const Text("Surat Rekomendasi dari Mitra Kerja",
                    style: TextStyle(fontSize: 14.0)),
                Visibility(
                  visible: jenisFilm.contains(caseIn) ? true : false,
                  child: const Text(
                      "Surat Izin Produksi Pembuatan Film Non Cerita/Cerita di Indonesia dari Kementrian Pariwisata dan Ekonomi Kreatif",
                      style: TextStyle(fontSize: 14.0)),
                ),
                Visibility(
                  visible:jenisFilm.contains(caseIn.toString()) ? true : false,
                  child: const Text("Sinopsis", style: TextStyle(fontSize: 14.0))),
                Visibility(
                  visible: jenisFilm.contains(caseIn.toString()) ? true : false,
                  child: const Text("Daftar Peralatan",
                      style: TextStyle(fontSize: 14.0)),
                ),
                const Text("Daftar Anggota Tim",
                    style: TextStyle(fontSize: 14.0)),
                Visibility(
                  visible: caseIn.toString() == "7" ? true :false,
                  child: const Text("Kartu Pers dari Lembaga yang Berwenang",
                      style: TextStyle(fontSize: 14.0)),
                ),
                const SizedBox(height: 20),
                const Text("Warga Negara Indonesia (WNI)",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                const Text("Proposal Kegiatan",
                    style: TextStyle(fontSize: 14.0)),
                const Text("Fotokopi Tanda Pengenal",
                    style: TextStyle(fontSize: 14.0)),
                const Text(
                    "Surat Pernyataan Tentang Kesanggupan Untuk Mematuhi Ketentuan Perundang-undangan, Dengan Format yang Berlaku",
                    style: TextStyle(fontSize: 14.0)),
                const Text("Surat Rekomendasi dari Mitra Kerja",
                    style: TextStyle(fontSize: 14.0)),
                Visibility(
                  visible: caseIn.toString() == "7" ? true :false,
                  child: const Text("Kartu Pers dari Lembaga yang Berwenang",
                      style: TextStyle(fontSize: 14.0)),
                ),
                const SizedBox(height: 20),
                const Text("Biaya",
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                Visibility(
                    visible: caseIn == 1 ? true : false,
                    child: ListBody(
                      children: [
                        const Text("Warga Negara Asing (WNA)",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold)),
                        Table(
                            columnWidths: const <int, TableColumnWidth>{
                              0: IntrinsicColumnWidth(),
                              1: FlexColumnWidth(),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: const <TableRow>[
                              TableRow(children: <Widget>[
                                Text("Lama Penelitian",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold)),
                                Text("PNBP",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold)),
                              ]),
                              TableRow(children: <Widget>[
                                Text("<1 Bulan",
                                    style: TextStyle(fontSize: 14.0)),
                                Text(
                                  "Rp. 5.000.000/ orang",
                                  textAlign: TextAlign.right,
                                ),
                              ]),
                              TableRow(children: <Widget>[
                                Text("1 Bulan - 6 Bulan",
                                    style: TextStyle(fontSize: 14.0)),
                                Text(
                                  "Rp. 10.000.000/ orang",
                                  textAlign: TextAlign.right,
                                ),
                              ]),
                              TableRow(children: <Widget>[
                                Text("7 Bulan - 12 Bulan",
                                    style: TextStyle(fontSize: 14.0)),
                                Text(
                                  "Rp. 15.000.000/ orang",
                                  textAlign: TextAlign.right,
                                ),
                              ])
                            ]),
                        const Text("Warga Negara Indonesia (WNI)",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.bold)),
                        Table(
                            columnWidths: const <int, TableColumnWidth>{
                              0: IntrinsicColumnWidth(),
                              1: FlexColumnWidth(),
                            },
                            defaultVerticalAlignment:
                                TableCellVerticalAlignment.middle,
                            children: const <TableRow>[
                              TableRow(children: <Widget>[
                                Text("Lama Penelitian",
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold)),
                                Text("PNBP",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.bold)),
                              ]),
                              TableRow(children: <Widget>[
                                Text("<1 Bulan",
                                    style: TextStyle(fontSize: 14.0)),
                                Text(
                                  "Rp. 100.000/ orang",
                                  textAlign: TextAlign.right,
                                ),
                              ]),
                              TableRow(children: <Widget>[
                                Text("1 Bulan - 6 Bulan",
                                    style: TextStyle(fontSize: 14.0)),
                                Text(
                                  "Rp. 150.000/ orang",
                                  textAlign: TextAlign.right,
                                ),
                              ]),
                              TableRow(children: <Widget>[
                                Text("7 Bulan - 12 Bulan",
                                    style: TextStyle(fontSize: 14.0)),
                                Text(
                                  "Rp. 250.000/ orang",
                                  textAlign: TextAlign.right,
                                ),
                              ])
                            ]),
                      ],
                    )),
                const SizedBox(height: 20),
                Visibility(
                    visible: caseIn == 1 ? false : true,
                    child: Text(caseIn == 3 ? "Rp. 10.000.000" : "Rp. 0",
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.bold))),
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
      },
    );
  }

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
          title: const Text("JENIS SIMAKSI"), backgroundColor: Colors.green),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          const SizedBox(height: 50),
          const Center(
            child: Text(
              "JENIS PENGAJUAN SIMAKSI",
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
              children: <Widget>[
                Card(
                  child: ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.search,
                      color: Colors.brown,
                    ),
                    title: const Text('Penelitian dan Pengembangan'),
                    trailing: IconButton(
                        onPressed: () => modalInfoSyarat(1),
                        icon: const FaIcon(FontAwesomeIcons.clipboardList)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.brain,
                      color: Colors.redAccent,
                    ),
                    title: const Text('Ilmu Pengetahuan dan Pendidikan'),
                    trailing: IconButton(
                        onPressed: () => modalInfoSyarat(2),
                        icon: const FaIcon(FontAwesomeIcons.clipboardList)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.video,
                      color: Colors.lightBlue,
                    ),
                    title: const Text('Pembuatan Film Komersil'),
                    trailing: IconButton(
                        onPressed: () => modalInfoSyarat(3),
                        icon: const FaIcon(FontAwesomeIcons.clipboardList)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.youtube,
                      color: Colors.blueGrey,
                    ),
                    title: const Text('Pembuatan Film Non Komersil'),
                    trailing: IconButton(
                        onPressed: () => modalInfoSyarat(4),
                        icon: const FaIcon(FontAwesomeIcons.clipboardList)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.fileVideo,
                      color: Colors.teal,
                    ),
                    title: const Text('Pembuatan Film Dokumenter'),
                    trailing: IconButton(
                        onPressed: () => modalInfoSyarat(5),
                        icon: const FaIcon(FontAwesomeIcons.clipboardList)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.route,
                      color: Colors.orange,
                    ),
                    title: const Text('Ekspedisi'),
                    trailing: IconButton(
                        onPressed: () => modalInfoSyarat(6),
                        icon: const FaIcon(FontAwesomeIcons.clipboardList)),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const FaIcon(
                      FontAwesomeIcons.newspaper,
                      color: Colors.green,
                    ),
                    title: const Text('Jurnalistik'),
                    trailing: IconButton(
                        onPressed: () => modalInfoSyarat(7),
                        icon: const FaIcon(FontAwesomeIcons.clipboardList)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 60,
          ),
        ],
      ),
    );
  }
}
