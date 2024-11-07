import 'package:flutter/material.dart';
import 'package:tractian_mobile_engineer_test/components/node_widget.dart';
import 'package:tractian_mobile_engineer_test/controllers/assets_controller.dart';

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
    controller.getAssets(widget.unitId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assets"),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
              child: const TextField(
                decoration: InputDecoration(
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
            Expanded(
              child: ListenableBuilder(
                  listenable: (controller),
                  builder: (context, index) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (controller.isEmpty) {
                      return const Center(
                          child: Text("Nenhum ativo encontrado"));
                    } else if (controller.haveError) {
                      return Center(child: Text(controller.errorMsg));
                    } else {
                      return ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        itemCount: controller.assets.length,
                        itemBuilder: (context, index) {
                          var node = controller.assets.entries.toList()[index];
                          return NodeWidget(node: node.value);
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
