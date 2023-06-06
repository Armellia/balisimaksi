class Rekening {
  int? id;
  String? text;

  Rekening({this.id, this.text});
  Rekening.fromJson(Map json)
      : id = json['id'],
        text = json['text'];
}
