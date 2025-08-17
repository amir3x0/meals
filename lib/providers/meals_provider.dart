import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/providers/user_meals_provider.dart';

final mealsProvider = Provider((ref) {
  final userMeals = ref.watch(userMealsProvider);
  return [...dummyMeals, ...userMeals];
});