// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum NodeType {
  location,
  subLocation,
  asset,
  subAsset,
  component,
}

class CompanyAssetModel {
  String id;
  String name;
  String? parentId;
  String? gatewayId;
  String? locationId;
  String? sensorId;
  String? sensorType;
  String? status;
  List<CompanyAssetModel> children = [];
  NodeType? type;

  CompanyAssetModel({
    required this.id,
    required this.name,
    this.type,
    this.parentId,
    this.gatewayId,
    this.locationId,
    this.sensorId,
    this.sensorType,
    this.status,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'parentId': parentId,
      'gatewayId': gatewayId,
      'locationId': locationId,
      'sensorId': sensorId,
      'sensorType': sensorType,
      'status': status,
      'children': children.map((child) => child.toMap()).toList(),
    };
  }

  factory CompanyAssetModel.fromMap(Map<String, dynamic> map) {
    return CompanyAssetModel(
      id: map['id'] as String,
      name: map['name'] as String,
      parentId: map['parentId'] != null ? map['parentId'] as String : null,
      gatewayId: map['gatewayId'] != null ? map['gatewayId'] as String : null,
      locationId:
          map['locationId'] != null ? map['locationId'] as String : null,
      sensorId: map['sensorId'] != null ? map['sensorId'] as String : null,
      sensorType:
          map['sensorType'] != null ? map['sensorType'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CompanyAssetModel.fromJson(String source) =>
      CompanyAssetModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
