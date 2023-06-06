class Kawasan {
  int? id;
  String? text;

  Kawasan({this.id, this.text});
  Kawasan.fromJson(Map json)
      : id = json['id'],
        text = json['text'];
}
