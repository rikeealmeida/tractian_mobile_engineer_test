import 'package:flutter/material.dart';
import 'package:tractian_mobile_engineer_test/components/node_widget.dart';
import 'package:tractian_mobile_engineer_test/controllers/assets_controller.dart';
import 'package:tractian_mobile_engineer_test/models/company_asset_model.dart';
import 'package:tractian_mobile_engineer_test/theme/colors.dart';

class AssetsPage extends StatefulWidget {
  final String unitId;
  const AssetsPage({super.key, required this.unitId});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  late AssetsController controller;

  @override
  void initState() {
    controller = AssetsController();
    controller.searchController = TextEditingController();
    controller.getAssets(widget.unitId);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assets"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.onSearchChanged,
                decoration: const InputDecoration(
                  hintText: "Buscar Ativo ou Local",
                  hintStyle: TextStyle(color: Colors.grey),
                  contentPadding: EdgeInsets.zero,
                  focusedBorder: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ValueListenableBuilder(
                      valueListenable: controller.isFilteredByEnergy,
                      builder: (context, v, child) {
                        return InkWell(
                            onTap: () =>
                                controller.togleFilter(FilterType.energy),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        v ? Colors.transparent : Colors.grey),
                                borderRadius: BorderRadius.circular(3),
                                color: v ? buttonColor : Colors.transparent,
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.bolt_outlined,
                                      size: 20,
                                      color: v ? Colors.white : Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    "Sensor de Energia",
                                    style: TextStyle(
                                        color: v ? Colors.white : Colors.grey),
                                  )
                                ],
                              ),
                            ));
                      }),
                  const SizedBox(width: 10),
                  ValueListenableBuilder(
                      valueListenable: controller.isFilteredByCritical,
                      builder: (context, v, contr) {
                        return InkWell(
                          onTap: () =>
                              controller.togleFilter(FilterType.critical),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: v ? Colors.transparent : Colors.grey),
                              borderRadius: BorderRadius.circular(3),
                              color: v ? buttonColor : Colors.transparent,
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.error_outline,
                                    size: 20,
                                    color: v ? Colors.white : Colors.grey),
                                SizedBox(width: 5),
                                Text(
                                  "Crítico",
                                  style: TextStyle(
                                      color: v ? Colors.white : Colors.grey),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                ],
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                  listenable: controller,
                  builder: (context, value) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (controller.isEmpty) {
                      return const Center(
                          child: Text("Nenhum ativo encontrado"));
                    } else if (controller.haveError) {
                      return Center(child: Text(controller.errorMsg));
                    } else {
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        itemCount: (controller.isFilteredByQuery.value ||
                                controller.isFilteredByCritical.value ||
                                controller.isFilteredByEnergy.value)
                            ? controller.filteredAssets.length
                            : controller.assets.length,
                        itemBuilder: (context, index) {
                          var node = (controller.isFilteredByQuery.value ||
                                  controller.isFilteredByCritical.value ||
                                  controller.isFilteredByEnergy.value)
                              ? controller.filteredAssets[index]
                              : controller.assets[index];
                          if (node['parentId'] == null &&
                              node['locationId'] == null &&
                              node['sensorType'] == null) {
                            node['type'] = NodeType.location;
                          } else {
                            node['type'] = NodeType.component;
                          }
                          node['nivel'] = 0;
                          return NodeWidget(node: node);
                        },
                      );
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
