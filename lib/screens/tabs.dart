import 'package:flutter/material.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/widgets/main_drawer.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favoritemeals = [];

  void _showInfoDialog(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _toggleFavorite(Meal meal) {
    setState(() {
      if (_favoritemeals.contains(meal)) {
        _favoritemeals.remove(meal);
        _showInfoDialog('Meal removed from favorites');
      } else {
        _favoritemeals.add(meal);
        _showInfoDialog('Meal added to favorites');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage = CategoriesScreen(onToggleFavorite: _toggleFavorite);
    var activePageTitle = 'Pick a Categorie';

    if (_selectedPageIndex == 1) {
      currentPage = MealsScreen(meals: _favoritemeals, onToggleFavorite: _toggleFavorite);
      activePageTitle = 'Your Favorites';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      drawer: const MainDrawer(),
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