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