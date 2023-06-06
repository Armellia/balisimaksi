class Jenis {
  int? id;
  String? text;

  Jenis({this.id, this.text});
  Jenis.fromJson(Map json)
      : id = json['id'],
        text = json['text'];
}
