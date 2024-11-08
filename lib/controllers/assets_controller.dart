import 'package:flutter/material.dart';
import 'package:tractian_mobile_engineer_test/models/company_asset_model.dart';
import 'package:tractian_mobile_engineer_test/services/http.dart';

class AssetsController extends ChangeNotifier {
  bool isLoading = true;
  bool haveError = false;
  bool isEmpty = false;
  String errorMsg = '';
  bool isFiltered = false;
  List<Map<String, dynamic>> assets = [];
  List<Map<String, dynamic>> filteredAssets = [];

  Future<void> getAssets(String id) async {
    isLoading = true;
    haveError = false;
    errorMsg = "";
    isEmpty = false;
    notifyListeners();
    try {
      var locations = await getUnitLocations(id);
      var assets = await getUnitAssets(id);
      var nodes = [...locations, ...assets];
      if (nodes.isEmpty) {
        isEmpty = true;
      }
      this.assets = buildTree(nodes);
    } catch (err) {
      haveError = true;
      errorMsg = err.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Map<String, dynamic>> buildTree(List<CompanyAssetModel> assets) {
    Map<String, CompanyAssetModel> nodes = {}; // Todos os nós
    Map<String, List<String>> adjacencyList = {};

    for (var item in assets) {
      CompanyAssetModel node = item;
      nodes[node.id] = node;

      adjacencyList[node.id] = [];
    }

    for (var node in nodes.values) {
      if (node.locationId != null && nodes.containsKey(node.locationId!)) {
        adjacencyList[node.locationId!]!.add(node.id);
      }

      if (node.parentId != null && nodes.containsKey(node.parentId!)) {
        adjacencyList[node.parentId!]!.add(node.id);
      }
    }

    List<Map<String, dynamic>> rootNodesAsMap = [];
    Set<String> visited = {};

    void buildTree(CompanyAssetModel node) {
      visited.add(node.id);

      for (var childId in adjacencyList[node.id]!) {
        if (!visited.contains(childId)) {
          CompanyAssetModel childNode = nodes[childId]!;
          node.children.add(childNode);
          buildTree(childNode);
        }
      }
    }

    for (var node in nodes.values) {
      if (node.parentId == null && node.locationId == null) {
        buildTree(node);
        rootNodesAsMap.add(node.toMap());
      }
    }

    return rootNodesAsMap;
  }

  void filterAssets(String query) {
    filteredAssets = _filterTree(assets, query);
    isFiltered = true;
    notifyListeners();
  }

  List<Map<String, dynamic>> _filterTree(
      List<Map<String, dynamic>> nodes, String query) {
    List<Map<String, dynamic>> filteredNodes = [];

    for (var node in nodes) {
      if (_containsQuery(node, query)) {
        filteredNodes.add(node);
      } else if (node['children'] != null && node['children'].isNotEmpty) {
        var filteredChildren = _filterTree(
            List<Map<String, dynamic>>.from(node['children']), query);
        if (filteredChildren.isNotEmpty) {
          var newNode = Map<String, dynamic>.from(node);
          newNode['children'] = filteredChildren;
          filteredNodes.add(newNode);
        }
      }
    }

    return filteredNodes;
  }

  bool _containsQuery(Map<String, dynamic> node, String query) {
    if (node['name'] != null &&
        node['name'].toString().toLowerCase().contains(query.toLowerCase())) {
      return true;
    }
    return false;
  }
}
