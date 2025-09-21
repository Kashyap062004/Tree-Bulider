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

class GraphHomePage extends StatelessWidget {
  const GraphHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Builder'),
      ),
      body: const Center(
        child: Text('Graph will go here!'),
      ),
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


// ...existing code...

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

  Widget buildNode(GraphNode node) {
    final isActive = node == activeNode;
    return Column(
      children: [
        GestureDetector(
          onTap: () => selectNode(node),
          onLongPress: () => deleteNode(node),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isActive ? Colors.blueAccent : Colors.grey,
                width: 2,
              ),
            ),
            child: Text(
              '${node.label}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        if (node.children.isNotEmpty)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: node.children.map(buildNode).toList(),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Builder'),
      ),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: buildNode(root),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addChild,
        child: const Icon(Icons.add),
        tooltip: 'Add Child Node',
      ),
    );
  }
}
// ...existing code...