import 'package:flutter/material.dart';
import 'package:tractian_mobile_engineer_test/models/company_asset_model.dart';

class NodeWidget extends StatefulWidget {
  final CompanyAssetModel node;

  const NodeWidget({super.key, required this.node});

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  var isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 1, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.node.children.isEmpty
                ? () {
                    print(widget.node.toJson());
                  }
                : () {
                    print(widget.node.toJson());
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
            child: Row(
              children: [
                if (widget.node.parentId != null ||
                    widget.node.locationId != null) ...[SizedBox(width: 20)],
                if (widget.node.children.isNotEmpty)
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                  )
                else
                  const SizedBox(width: 20),
                Image.asset(getNodeIcon(widget.node), width: 20),
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    widget.node.name,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                //colocar indicadores aqui
              ],
            ),
          ),
          if (isExpanded && widget.node.children.isNotEmpty)
            Column(
                children: widget.node.children
                    .map((e) => NodeWidget(node: e))
                    .toList()),
        ],
      ),
    );
  }
}

String getNodeIcon(CompanyAssetModel node) {
  if (node.parentId == null ||
      (node.parentId != null && node.children.isNotEmpty)) {
    return 'assets/images/location.png';
  } else if (node.children.isNotEmpty && node.locationId != null) {
    return 'assets/images/component.png';
  } else {
    return 'assets/images/asset.png';
  }
}
