import 'package:flutter/material.dart';

void main() {
  runApp(const VecDrawApp());
}

class VecDrawApp extends StatelessWidget {
  const VecDrawApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VecDraw by Topz',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A), // Dark Navy/Blue
        primaryColor: const Color(0xFFFFD700), // Gold Accent
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B192C),
          elevation: 2,
        ),
      ),
      home: const MainCanvasScreen(),
    );
  }
}

class MainCanvasScreen extends StatefulWidget {
  const MainCanvasScreen({super.key});

  @override
  State<MainCanvasScreen> createState() => _MainCanvasScreenState();
}

class _MainCanvasScreenState extends State<MainCanvasScreen> {
  // Panel Toggles (CorelDraw UI Customization)
  bool showToolbox = true;
  bool showProperties = true;
  bool showColorPalette = true;

  // Selected Tool
  String selectedTool = 'Pick Tool';

  // Floating Position for Toolbox
  Offset toolboxPosition = const Offset(16, 80);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.draw, color: Color(0xFFFFD700)),
            SizedBox(width: 8),
            Text(
              'VecDraw by Topz',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFFFD700),
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          // UI Panel Toggles
          IconButton(
            icon: Icon(
              Icons.build,
              color: showToolbox ? Colors.yellow : Colors.grey,
            ),
            tooltip: 'Toggle Toolbox',
            onPressed: () => setState(() => showToolbox = !showToolbox),
          ),
          IconButton(
            icon: Icon(
              Icons.tune,
              color: showProperties ? Colors.yellow : Colors.grey,
            ),
            tooltip: 'Toggle Properties',
            onPressed: () => setState(() => showProperties = !showProperties),
          ),
          IconButton(
            icon: Icon(
              Icons.palette,
              color: showColorPalette ? Colors.yellow : Colors.grey,
            ),
            tooltip: 'Toggle Color Palette',
            onPressed: () => setState(() => showColorPalette = !showColorPalette),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Core Vector Drawing Canvas (Interactive Pan & Zoom)
          InteractiveViewer(
            boundaryMargin: const EdgeInsets.all(2000),
            minScale: 0.1,
            maxScale: 10.0,
            child: SizedBox(
              width: 3000,
              height: 3000,
              child: CustomPaint(
                painter: VectorCanvasPainter(),
              ),
            ),
          ),

          // 2. Property Bar (Top Panel - Modular)
          if (showProperties)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 48,
                color: const Color(0xFF1E293B),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Tool: $selectedTool',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const VerticalDivider(color: Colors.white24, indent: 8, endIndent: 8),
                    const Text('Unit: mm'),
                    const SizedBox(width: 16),
                    const Text('Stroke: 1.0 pt'),
                  ],
                ),
              ),
            ),

          // 3. Draggable Toolbox Panel (Left Side / Floating)
          if (showToolbox)
            Positioned(
              left: toolboxPosition.dx,
              top: toolboxPosition.dy,
              child: GestureDetachedToolbox(
                selectedTool: selectedTool,
                onToolSelected: (tool) => setState(() => selectedTool = tool),
                onDrag: (delta) {
                  setState(() {
                    toolboxPosition += delta;
                  });
                },
              ),
            ),

          // 4. Color Palette (Bottom Bar)
          if (showColorPalette)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 50,
                color: const Color(0xFF1E293B),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    Colors.black,
                    Colors.white,
                    Colors.red,
                    Colors.blue,
                    Colors.green,
                    Colors.yellow,
                    Colors.orange,
                    Colors.purple,
                    const Color(0xFFFFD700), // Gold
                  ].map((color) {
                    return Container(
                      width: 40,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Draggable & Modular Toolbox Component
class GestureDetachedToolbox extends StatelessWidget {
  final String selectedTool;
  final Function(String) onToolSelected;
  final Function(Offset) onDrag;

  const GestureDetachedToolbox({
    super.key,
    required this.selectedTool,
    required this.onToolSelected,
    required this.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'name': 'Pick Tool', 'icon': Icons.near_me},
      {'name': 'Shape Tool', 'icon': Icons.gesture},
      {'name': 'Pen Tool', 'icon': Icons.create},
      {'name': 'Rectangle', 'icon': Icons.crop_square},
      {'name': 'Ellipse', 'icon': Icons.circle_outlined},
      {'name': 'Text Tool', 'icon': Icons.title},
      {'name': 'Interactive Fill', 'icon': Icons.format_color_fill},
    ];

    return GestureDetector(
      onPanUpdate: (details) => onDrag(details.delta),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF1E293B),
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
              const Divider(color: Colors.white12),
              ...tools.map((tool) {
                final isSelected = selectedTool == tool['name'];
                return IconButton(
                  icon: Icon(
                    tool['icon'] as IconData,
                    color: isSelected ? const Color(0xFFFFD700) : Colors.white70,
                  ),
                  tooltip: tool['name'] as String,
                  onPressed: () => onToolSelected(tool['name'] as String),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// Vector Engine - Custom Painter (Handles grid & render paths)
class VectorCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    // Draw Background Grid Lines
    const double gridSize = 50.0;
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Sample Vector Path Render (Gold Curve)
    final pathPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path()
      ..moveTo(200, 200)
      ..cubicTo(300, 100, 400, 300, 500, 200);

    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
