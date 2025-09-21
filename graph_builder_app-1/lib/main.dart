import 'package:flutter/material.dart';

void main() {
  runApp(const GraphBuilderApp());
}

class GraphBuilderApp extends StatelessWidget {
  const GraphBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graph Builder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GraphHomePage(),
    );
  }
}

class GraphNode {
  int label;
  GraphNode? parent;
  List<GraphNode> children = [];

  GraphNode({required this.label, this.parent});

  void addChild(GraphNode child) {
    child.parent = this;
    children.add(child);
  }

  void removeChild(GraphNode child) {
    children.remove(child);
  }
}

class GraphHomePage extends StatefulWidget {
  const GraphHomePage({super.key});

  @override
  State<GraphHomePage> createState() => _GraphHomePageState();
}

class _GraphHomePageState extends State<GraphHomePage> {
  late GraphNode root;
  GraphNode? activeNode;
  int nextLabel = 2;

  @override
  void initState() {
    super.initState();
    root = GraphNode(label: 1);
    // for demo you might want some children
    // root.addChild(GraphNode(label:2));
    activeNode = root;
  }

  void addChild() {
    setState(() {
      final newNode = GraphNode(label: nextLabel++);
      activeNode!.addChild(newNode);
    });
  }

  void selectNode(GraphNode node) {
    setState(() {
      activeNode = node;
    });
  }

  void deleteNode(GraphNode node) {
    if (node == root) return; // Don't delete root
    setState(() {
      node.parent?.removeChild(node);
      if (activeNode == node) {
        activeNode = root;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF19202A),
      appBar: AppBar(
        title: const Text('Graph Builder'),
        backgroundColor: const Color(0xFF22304A),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
            child: TreeNodeWidget(
              node: root,
              isActive: (node) => node == activeNode,
              onSelect: selectNode,
              onDelete: deleteNode,
              root: root,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addChild,
        icon: const Icon(Icons.add),
        label: const Text("Add Node"),
        backgroundColor: Colors.blue[700],
      ),
    );
  }
}

// Replace existing TreeNodeWidget and TreeEdgePainter with this code.

class TreeNodeWidget extends StatelessWidget {
  final GraphNode node;
  final bool Function(GraphNode) isActive;
  final void Function(GraphNode) onSelect;
  final void Function(GraphNode) onDelete;
  final GraphNode root;

  static const double nodeSize = 64;
  static const double verticalGap = 48;
  static const double horizontalGap = 24;

  const TreeNodeWidget({
    super.key,
    required this.node,
    required this.isActive,
    required this.onSelect,
    required this.onDelete,
    required this.root,
  });

  // Cache map for subtree widths to avoid repeated recursion during a single build.
  // Note: Use a new map on each build (stateless widget) by computing in-place via helper.
  double _computeSubtreeWidth(GraphNode n, Map<GraphNode, double> cache) {
    if (cache.containsKey(n)) return cache[n]!;
    if (n.children.isEmpty) {
      cache[n] = nodeSize;
      return nodeSize;
    }
    double sum = 0;
    for (var c in n.children) {
      sum += _computeSubtreeWidth(c, cache);
    }
    sum += (n.children.length - 1) * horizontalGap;
    final double w = sum.clamp(nodeSize, double.infinity);
    cache[n] = w;
    return w;
  }

  Widget _buildNodeCircle(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        GestureDetector(
          onTap: () => onSelect(node),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive(node) ? Colors.blue[400] : const Color(0xFFD9E1E6),
              border: Border.all(
                color: isActive(node) ? Colors.blueAccent : Colors.grey,
                width: isActive(node) ? 4 : 2,
              ),
              boxShadow: [
                if (isActive(node))
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.28),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                '${node.label}',
                style: TextStyle(
                  color: isActive(node) ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
          ),
        ),
        if (node != root)
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => onDelete(node),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red[200],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red, width: 2),
                ),
                padding: const EdgeInsets.all(2),
                child: const Icon(Icons.close, size: 16, color: Colors.red),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = node.children;

    final nodeWidget = _buildNodeCircle(context);

    // If no children, just return the node.
    if (children.isEmpty) {
      return nodeWidget;
    }

    // Build width cache for the whole subtree (single traversal).
    final widthCache = <GraphNode, double>{};
    _computeSubtreeWidth(node, widthCache);

    // Get widths for each child slot (these are the full subtree widths of children)
    final List<double> childWidths = children.map((c) => widthCache[c] ?? nodeSize).toList();

    // Compute total width of children area (children widths + gaps)
    final double childrenTotalWidth = childWidths.fold(0.0, (a, b) => a + b) +
        ((childWidths.length - 1) * horizontalGap);

    final double rowWidth = childrenTotalWidth.clamp(nodeSize, double.infinity);

    // Compute centers for each child relative to leftEdge (inside the rowWidth).
    final leftEdge = (rowWidth - childrenTotalWidth) / 2;
    final List<double> childCenters = [];
    double cursor = leftEdge;
    for (var w in childWidths) {
      childCenters.add(cursor + w / 2);
      cursor += w + horizontalGap;
    }

    // Choose which child to center the parent over:
    // pick the middle child (floor for odd, left-middle for even)
    final int parentIndex = (childCenters.length - 1) ~/ 2;
    final double parentCenterX = childCenters[parentIndex];

    // Build each child widget but force it into its computed slot width.
    final List<Widget> childSlotWidgets = [];
    for (int i = 0; i < children.length; i++) {
      final child = children[i];
      final w = childWidths[i];
    childSlotWidgets.add(SizedBox(
  width: w + (i < children.length - 1 ? horizontalGap : 0),
  child: Align(
    alignment: Alignment.topCenter,
    child: TreeNodeWidget(
      node: child,
      isActive: isActive,
      onSelect: onSelect,
      onDelete: onDelete,
      root: root,
    ),
  ),
));

    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Parent row: fixed width rowWidth, but we center the parent at parentCenterX
        SizedBox(
          width: rowWidth,
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              // Parent placed at (parentCenterX - nodeSize/2)
              Positioned(
                left: parentCenterX - nodeSize / 2,
                child: nodeWidget,
              ),
            ],
          ),
        ),
        SizedBox(height: verticalGap / 2),
        // Paint connectors with exact child centers and parent center
        SizedBox(
          width: rowWidth,
          height: verticalGap,
          child: CustomPaint(
            painter: _TreeEdgePainter(
              parentCenterX: parentCenterX,
              childCenters: childCenters,
              verticalGap: verticalGap,
            ),
          ),
        ),
        // Children row: constrained to rowWidth — each child uses its slot
        SizedBox(
          width: rowWidth,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: childSlotWidgets,
          ),
        ),
      ],
    );
  }
}

class _TreeEdgePainter extends CustomPainter {
  final double parentCenterX;
  final List<double> childCenters;
  final double verticalGap;

  _TreeEdgePainter({
    required this.parentCenterX,
    required this.childCenters,
    required this.verticalGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (childCenters.isEmpty) return;
    final paint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final double midY = verticalGap / 2;
    final double bottomY = verticalGap;

    // compute left-most and right-most child centers (within painter coords)
    final double leftMost = childCenters.first;
    final double rightMost = childCenters.last;

    // 1) vertical line down from parent center to connector midline
    canvas.drawLine(
      Offset(parentCenterX, 0),
      Offset(parentCenterX, midY),
      paint,
    );

    // 2) horizontal connector spanning from leftMost to rightMost at midY
    if (childCenters.length > 1) {
      canvas.drawLine(Offset(leftMost, midY), Offset(rightMost, midY), paint);
    }

    // 3) small verticals from midline to each child center (L-shaped)
    for (final cx in childCenters) {
      canvas.drawLine(Offset(cx, midY), Offset(cx, bottomY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreeEdgePainter old) {
    if (old.childCenters.length != childCenters.length) return true;
    for (int i = 0; i < childCenters.length; i++) {
      if (old.childCenters[i] != childCenters[i]) return true;
    }
    return old.parentCenterX != parentCenterX || old.verticalGap != verticalGap;
  }
}

