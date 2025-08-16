import 'package:flutter/material.dart';
import 'package:meals/models/meal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/providers/favorites_provider.dart';

class MealDetailsScreen extends ConsumerWidget {
  const MealDetailsScreen({super.key, required this.meal});

  final Meal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoritesProvider).contains(meal);



    return Scaffold(
      // CustomScrollView + Slivers allow the flexible collapsing app bar effect.
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(bottom: 16),
              centerTitle: true,
              title: Container(
                // Semi-transparent background improves contrast over the image.
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  meal.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Hero(
                        // Tag matches the one used in the list item -> smooth image transition.
                        tag: meal.id,
                        child: Image.network(
                          meal.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle(context, 'Ingredients'),
                  const SizedBox(height: 12),
                  _buildIngredientsGrid(context),
                  const SizedBox(height: 24),
                  _buildSectionTitle(context, 'Steps'),
                  const SizedBox(height: 12),
                  ..._buildStepsList(context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        // Future enhancement: toggle favorite state (would require state mgmt solution)
        onPressed: () {
          final isFavorite = ref.read(favoritesProvider.notifier).toggleFavoriteStatus(meal);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isFavorite ? 'Meal added to favorites!' : 'Meal removed from favorites!'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: const Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }

  /// Renders a stylized section title with a subtle underline (bottom border).
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
      ),
    );
  }

  /// Displays each ingredient as a pill using [Wrap] so items flow to new lines gracefully.
  Widget _buildIngredientsGrid(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: meal.ingredients.map((ingredient) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            ingredient,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.white,
                ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds a numbered list of preparation steps. The step index is derived via [asMap].
  List<Widget> _buildStepsList(BuildContext context) {
    return meal.steps.asMap().entries.map((entry) {
      final index = entry.key;
      final step = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              child: Text('${index + 1}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
