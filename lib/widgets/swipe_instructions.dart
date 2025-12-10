import 'package:flutter/material.dart';

class SwipeInstructions extends StatelessWidget {
  const SwipeInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Row(
            children: [
              Icon(Icons.arrow_forward, size: 18, color: Colors.green),
              SizedBox(width: 6),
              Text("Swipe right to complete",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
          Row(
            children: [
              Text("Swipe left to delete",
                  style: TextStyle(fontSize: 14, color: Colors.black54)),
              SizedBox(width: 6),
              Icon(Icons.arrow_back, size: 18, color: Colors.red),
            ],
          ),
        ],
      ),
    );
  }
}
