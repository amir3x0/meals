import 'package:flutter/material.dart';


class MealItemTrait extends StatelessWidget{
  const MealItemTrait({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white,),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500,
        )),
      ],
    );
  }

}