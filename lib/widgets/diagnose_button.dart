import 'package:flutter/material.dart';

class DiagnoseButton extends StatelessWidget {
  final VoidCallback onTap;

  const DiagnoseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2563EB),
              Color(0xFF4F46E5),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.white, size: 30),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Diagnosa",
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                Text("Mulai diagnosa",
                    style: TextStyle(color: Colors.white70)),
              ],
            )
          ],
        ),
      ),
    );
  }
}