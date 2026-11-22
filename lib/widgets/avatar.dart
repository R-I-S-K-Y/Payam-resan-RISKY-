import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.label,
    required this.color,
    this.radius = 24,
    this.icon,
  });

  final String label;
  final Color color;
  final double radius;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final initial = label.isEmpty ? '؟' : label.substring(0, 1);
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(color, Colors.white, 0.18)!,
            color,
          ],
        ),
      ),
      alignment: Alignment.center,
      child: icon != null
          ? Icon(icon, color: Colors.white, size: radius)
          : Text(
              initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.9,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }
}
