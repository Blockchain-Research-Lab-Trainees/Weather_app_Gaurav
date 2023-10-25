import 'package:flutter/material.dart';

class AdditionalInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const AdditionalInfo(
      {super.key,
      required this.icon,
      required this.label,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        
//         Container(
//           height: 60, width: 60, padding: const EdgeInsets.all(16),
// decoration: BoxDecoration(


// borderRadius: BorderRadius.circular (15)),
// child: image,
//         ),

      Icon(
          icon,
          size: 40,
        ),


        
        
        const SizedBox(
          height: 8.0,
        ),
        Text(label),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
