import 'package:flutter/material.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/models/meal.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favoritemeals = [];

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _toggleFavorite(Meal meal) {
    setState(() {
      if (_favoritemeals.contains(meal)) {
        _favoritemeals.remove(meal);
      } else {
        _favoritemeals.add(meal);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage = const CategoriesScreen();
    var activePageTitle = 'Pick a Categorie';

    if (_selectedPageIndex == 1) {
      currentPage = const MealsScreen(meals: []);
      activePageTitle = 'Your Favorites';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      body: currentPage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category_sharp),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_sharp),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedPageIndex,
      ),
    );
  }
}