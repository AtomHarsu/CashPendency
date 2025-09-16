class CompanyModal {
  String? id;
  String? text;

  CompanyModal({this.id, this.text});

  CompanyModal.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['text'] = this.text;
    return data;
  }
}
