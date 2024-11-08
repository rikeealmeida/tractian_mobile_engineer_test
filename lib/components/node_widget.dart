import 'package:flutter/material.dart';
import 'package:tractian_mobile_engineer_test/models/company_asset_model.dart';

class NodeWidget extends StatefulWidget {
  final Map<String, dynamic> node;

  const NodeWidget({super.key, required this.node});

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  var isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.node['children'].isEmpty
                ? () {
                    // print(widget.node);
                  }
                : () {
                    // print(widget.node);
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
            child: Row(
              children: [
                SizedBox(
                    width: widget.node['nivel'] == 0
                        ? 0
                        : widget.node['nivel'] * 15.0),
                if (widget.node['children'].isNotEmpty)
                  Icon(
                    isExpanded ? Icons.expand_more : Icons.chevron_right,
                    size: 20,
                  )
                else
                  const SizedBox(width: 20),
                Image.asset(getNodeIcon(widget.node), width: 20),
                const SizedBox(width: 5),
                Text(
                  widget.node['name'],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 5),
                if (widget.node['status'] != null) ...[
                  if (widget.node['status'] == 'operating') ...[
                   const Icon(Icons.bolt_outlined, color: Colors.green, size: 18)
                  ] else if (widget.node['status'] == 'alert') ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Colors.red),
                    )
                  ] else ...[
                    const SizedBox()
                  ]
                ],
                //colocar indicadores aqui
              ],
            ),
          ),
          if (isExpanded && widget.node['children'].isNotEmpty)
            ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.node['children'].length,
              itemBuilder: (context, index) {
                var childNode = widget.node['children'][index];
                childNode['nivel'] = widget.node['nivel'] + 1;
                return NodeWidget(node: childNode);
              },
            ),
        ],
      ),
    );
  }
}

String getNodeIcon(Map<String, dynamic> node) {
  if (node['type'] == NodeType.location) {
    return 'assets/images/location.png';
  } else if (node['children'].isNotEmpty) {
    return 'assets/images/asset.png';
  } else {
    return 'assets/images/component.png';
  }
}
