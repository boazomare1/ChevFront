import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AnimatedLogo(),
        ),
      ),
    );
  }
}

class AnimatedLogo extends StatefulWidget {
  @override
  _AnimatedLogoState createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<Offset> starPositions = [];
  static const int starCount = 50;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..addListener(() {
        setState(() {
          if (_controller.value < 0.5) {
            // Random movement phase
            starPositions = List.generate(starCount, (index) => Offset(
              math.Random().nextDouble() * 200,
              math.Random().nextDouble() * 200,
            ));
          } else {
            // Organize into "POWER GAS" shape
            starPositions = calculatePowerGasPositions();
          }
        });
      });
    _controller.repeat();
    starPositions = List.generate(starCount, (index) => Offset(
      math.Random().nextDouble() * 200,
      math.Random().nextDouble() * 200,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 100,
          child: CustomPaint(
            painter: StarPainter(starPositions),
          ),
        ),
        const SizedBox(height: 24),
        Shimmer.fromColors(
          baseColor: Colors.green,
          period: const Duration(milliseconds: 1500),
          highlightColor: Colors.pinkAccent,
          child: const Text(
            'Rafiki Jikoni',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }

  List<Offset> calculatePowerGasPositions() {
    const letters = "POWER GAS";
    final positions = <Offset>[];
    const double letterWidth = 20.0;
    const double startX = 0.0;
    double x = startX;
    double y = 50.0;

    for (int i = 0; i < letters.length; i++) {
      if (letters[i] == ' ') {
        x += letterWidth;
        continue;
      }
      for (int j = 0; j < starCount ~/ letters.length; j++) {
        positions.add(Offset(
          x + (math.Random().nextDouble() - 0.5) * letterWidth / 2,
          y + (math.Random().nextDouble() - 0.5) * 20,
        ));
      }
      x += letterWidth;
    }
    return positions;
  }
}

class StarPainter extends CustomPainter {
  final List<Offset> starPositions;

  StarPainter(this.starPositions);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    for (var pos in starPositions) {
      final path = Path();
      path.moveTo(pos.dx, pos.dy - 5);
      path.lineTo(pos.dx + 5, pos.dy + 5);
      path.lineTo(pos.dx - 5, pos.dy + 5);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}