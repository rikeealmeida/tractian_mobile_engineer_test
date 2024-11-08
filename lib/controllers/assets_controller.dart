import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tractian_mobile_engineer_test/models/company_asset_model.dart';
import 'package:tractian_mobile_engineer_test/services/http.dart';

enum FilterType { query, critical, energy }

class AssetsController extends ChangeNotifier {
  bool isLoading = true;
  bool haveError = false;
  bool isEmpty = false;
  String errorMsg = '';
  final isFilteredByQuery = ValueNotifier(false);
  final isFilteredByCritical = ValueNotifier(false);
  final isFilteredByEnergy = ValueNotifier(false);
  List<Map<String, dynamic>> assets = [];
  List<Map<String, dynamic>> filteredAssets = [];
  late TextEditingController searchController;
  Timer? _debounce;

  AssetsController() {
    searchController = TextEditingController();
    searchController.addListener(() {
      onSearchChanged(searchController.text);
    });
  }

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
      nodes[item.id] = item;
      adjacencyList[item.id] = [];
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

  void togleFilter(FilterType type) {
    var query = searchController.text;
    switch (type) {
      case FilterType.query:
        if (query.isEmpty) {
          filteredAssets = [];
          isFilteredByQuery.value = false;
        } else {
          filteredAssets = _filterTreeByName(assets, query);
          isFilteredByCritical.value = false;
          isFilteredByEnergy.value = false;
          isFilteredByQuery.value = true;
        }
      case FilterType.energy:
        if (isFilteredByEnergy.value) {
          isFilteredByEnergy.value = false;
        } else {
          filteredAssets = _filterTreeByEnergy(assets);
          isFilteredByCritical.value = false;
          isFilteredByEnergy.value = true;
        }
      case FilterType.critical:
        if (isFilteredByCritical.value) {
          isFilteredByCritical.value = false;
        } else {
          filteredAssets = _filterTreeByCritical(assets);
          isFilteredByEnergy.value = false;
          isFilteredByCritical.value = true;
        }
      default:
        isFilteredByQuery.value = false;
        isFilteredByCritical.value = false;
        isFilteredByEnergy.value = false;
    }

    notifyListeners();
  }

  List<Map<String, dynamic>> _filterTreeByName(
      List<Map<String, dynamic>> nodes, String query) {
    List<Map<String, dynamic>> filteredNodes = [];

    for (var node in nodes) {
      if (_containsQuery(node, query)) {
        filteredNodes.add(node);
      } else if (node['children'] != null && node['children'].isNotEmpty) {
        var filteredChildren = _filterTreeByName(
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

  List<Map<String, dynamic>> _filterTreeByCritical(
      List<Map<String, dynamic>> nodes) {
    List<Map<String, dynamic>> filteredNodes = [];

    for (var node in nodes) {
      if (_containsCritical(node)) {
        filteredNodes.add(node);
      } else if (node['children'] != null && node['children'].isNotEmpty) {
        var filteredChildren = _filterTreeByCritical(
            List<Map<String, dynamic>>.from(node['children']));
        if (filteredChildren.isNotEmpty) {
          var newNode = Map<String, dynamic>.from(node);
          newNode['children'] = filteredChildren;
          filteredNodes.add(newNode);
        }
      }
    }

    return filteredNodes;
  }

  List<Map<String, dynamic>> _filterTreeByEnergy(
      List<Map<String, dynamic>> nodes) {
    List<Map<String, dynamic>> filteredNodes = [];

    for (var node in nodes) {
      if (_containsEnergy(node)) {
        filteredNodes.add(node);
      } else if (node['children'] != null && node['children'].isNotEmpty) {
        var filteredChildren = _filterTreeByEnergy(
            List<Map<String, dynamic>>.from(node['children']));
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

  bool _containsCritical(Map<String, dynamic> node) {
    if (node['status'] != null && node['status'] == 'alert') {
      return true;
    }
    return false;
  }

  bool _containsEnergy(Map<String, dynamic> node) {
    if (node['sensorType'] != null && node['sensorType'] == 'energy') {
      return true;
    }
    return false;
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      togleFilter(FilterType.query);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }
}
