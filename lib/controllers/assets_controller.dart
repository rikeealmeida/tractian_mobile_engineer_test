import 'package:flutter/material.dart';
import 'package:tractian_mobile_engineer_test/models/company_asset_model.dart';
import 'package:tractian_mobile_engineer_test/services/http.dart';

class AssetsController extends ChangeNotifier {
  bool isLoading = true;
  bool haveError = false;
  bool isEmpty = false;
  String errorMsg = '';
  Map<String, CompanyAssetModel> assets = {};

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
      this.assets = buildTree(locations, assets);
    } catch (err) {
      haveError = true;
      errorMsg = err.toString();
      notifyListeners();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, CompanyAssetModel> buildTree(
      List<CompanyAssetModel> locations, List<CompanyAssetModel> assets) {
    Map<String, CompanyAssetModel> allNodes = {};

    // First, add all locations to the map
    for (var location in locations) {
      allNodes[location.id] = location;
    }

    // Then add all assets to the map
    for (var asset in assets) {
      allNodes[asset.id] = asset;
    }

    // Build parent-child relationships
    for (var node in [...locations, ...assets]) {
      if (node.parentId != null && allNodes.containsKey(node.parentId)) {
        allNodes[node.parentId]?.children.add(node);
      }
      // Handle sublocations
      if (node.locationId != null && allNodes.containsKey(node.locationId)) {
        allNodes[node.locationId]?.children.add(node);
      }
    }

    // Return only root nodes (nodes without parents)
    return Map.fromEntries(
      allNodes.entries.where((entry) => entry.value.parentId == null && entry.value.locationId == null),
    );
  }
}
