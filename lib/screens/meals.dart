import 'package:flutter/material.dart';
import 'package:meals/models/meal.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key, required this.title, required this.meals});

  final String title;
  final List<Meal> meals;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView.builder(
        itemCount: meals.length,
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, index) => ListTile(
          title: Text(meals[index].title),
          onTap: () {
            Navigator.of(context).pushNamed(
              '/meal-detail',
              arguments: meals[index],
            );
          },
        ),
      ),
    );
  }
}