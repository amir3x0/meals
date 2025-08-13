import 'package:flutter/material.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/widgets/main_drawer.dart';
import 'package:meals/screens/filters.dart';

const Initialfilters = {
    Filter.glutenFree: false,
    Filter.lactoseFree: false,
    Filter.veganFree: false,
    Filter.vegetarianFree: false,
  };

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  _TabsScreenState createState() => _TabsScreenState();
}
class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favoritemeals = [];
  Map<Filter, bool> _selectedFilters = Initialfilters;

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

  void _selectScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'meals') {
      setState(() {
        _selectedPageIndex = 0;
      });
    } else if (identifier == 'filters') {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) => FiltersScreen( currentFilters: _selectedFilters),
        ),
      );
      setState(() {
        _selectedFilters = result ?? Initialfilters;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMeals = dummyMeals.where((meal) {
      if (_selectedFilters[Filter.glutenFree]! && !meal.isGlutenFree) {
        return false;
      }
      if (_selectedFilters[Filter.lactoseFree]! && !meal.isLactoseFree) {
        return false;
      }
      if (_selectedFilters[Filter.vegetarianFree]! && !meal.isVegetarian) {
        return false;
      }
      if (_selectedFilters[Filter.veganFree]! && !meal.isVegan) {
        return false;
      }
      return true;
    }).toList();

    Widget currentPage = CategoriesScreen(onToggleFavorite: _toggleFavorite, avalibaleMeals: filteredMeals);
    var activePageTitle = 'Pick a Categorie';
    if (_selectedPageIndex == 1) {
      currentPage =
          MealsScreen(meals: _favoritemeals, onToggleFavorite: _toggleFavorite);
      activePageTitle = 'Your Favorites';
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      drawer: MainDrawer(
        onSelectScreen: _selectScreen,
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
