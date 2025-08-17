import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/models/meal.dart';

class UserMealsNotifier extends StateNotifier<List<Meal>> {
  UserMealsNotifier() : super(const []);

  void addMeal(Meal meal) {
    state = [...state, meal];
  }
}

final userMealsProvider = StateNotifierProvider<UserMealsNotifier, List<Meal>>(
  (ref) => UserMealsNotifier(),
);
