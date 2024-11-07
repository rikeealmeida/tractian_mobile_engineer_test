import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class CompanyUnityModel {
  String id;
  String name;
  CompanyUnityModel({
    required this.id,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
    };
  }

  factory CompanyUnityModel.fromMap(Map<String, dynamic> map) {
    return CompanyUnityModel(
      id: map['id'] as String,
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory CompanyUnityModel.fromJson(String source) =>
      CompanyUnityModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
