# Copilot Project Instructions

Concise, project-specific guidance for AI coding agents working in this repo.

## Big Picture
This is a small Flutter demo app ("meals") showing category -> meals -> meal detail flow. Architecture is deliberately simple, using:
- Stateless widgets only (no state mgmt libs yet).
- In-memory dummy data lists in `lib/data/`.
- Basic model classes in `lib/models/`.
- UI layered as: screens (navigation + layout) -> widgets (reusable UI parts) -> models & data.
- Navigation uses imperative `Navigator.of(context).push(MaterialPageRoute(...))` (no named routes yet).

## Key Directories
- `lib/main.dart`: App entrypoint, defines global `theme` and sets `home: CategoriesScreen()`.
- `lib/data/dummy_data.dart`: Defines `dummyCategories` and (expected) `dummyMeals` lists. Extend here for more sample content; keep IDs consistent with `Meal.categories` references.
- `lib/models/`: Plain data holders (`Category`, `Meal`, enums `Complexity`, `Affordability`). Keep immutable (`final` fields, const constructors) and avoid methods with side-effects.
- `lib/screens/`: High-level pages (`CategoriesScreen`, `MealsScreen`, `MealDetailsScreen`). Navigation & composition happen here.
- `lib/widgets/`: Reusable presentational widgets (`CategoryGridItem`, `MealItem`, `MealItemTrait`). Keep them focused & stateless.

## Data Flow & Conventions
- Category selection filters meals via `dummyMeals.where((m) => m.categories.contains(category.id))` in `CategoriesScreen` before pushing `MealsScreen`.
- `MealsScreen` decides empty vs list UI locally (no external controller).
- `MealDetailsScreen` receives a full `Meal` instance; no extra fetch or provider pattern used.
- IDs: Category IDs are strings like `c1`, `c2`, ...; refer to them in `Meal.categories` (string list). Maintain uniqueness; don't repurpose an ID.
- Colors: `Category.color` uses Material `Color` constants; prefer `Colors.*Accent` or theme-derived colors for consistency.

## Theming
- Global `theme` in `main.dart` uses Material 3 and a dark `ColorScheme.fromSeed`. When adding text styling, prefer `Theme.of(context).textTheme.*.copyWith(...)`.
- Use `.withValues(alpha: ...)` pattern (already adopted) instead of deprecated `withOpacity` if staying consistent.

## Adding Features (Patterns to Follow)
When implementing a new feature:
1. Model: Create/extend models in `lib/models/` (immutable, const constructor).
2. Data: Add sample entries in `lib/data/dummy_data.dart` (keep lists ordered & readable; group related entries).
3. UI: If it's a full screen, put it in `lib/screens/`; smaller visual pieces go in `lib/widgets/`.
4. Navigation: Use `Navigator.of(context).push(MaterialPageRoute(builder: ...))`. Keep routes inline unless growth justifies a central route map.
5. Reuse: Factor out repeated visual rows (like trait chips) into widgets in `widgets/`.

## Common Pitfalls to Avoid
- Don't introduce mutable global state; if state management becomes necessary, propose Provider or Riverpod before adding.
- Keep network image loading via `FadeInImage` if adding more image-based widgets for consistent placeholder handling.
- Avoid mixing concerns: filtering logic stays in the screen that initiates navigation (like categories filtering meals).
- Maintain null-safety and avoid using `!` unless already proven non-null (current code uses `!` only on `textTheme` lookups).

## Android Build / Environment Notes
- Android config uses AGP 8.7.3 & Kotlin 2.1.0 (`android/settings.gradle.kts`). Needs JDK 17.
- `local.properties` expects a valid `flutter.sdk` path; align with VS Code `dart.flutterSdkPath`.
- If encountering `aapt` issues: Ensure `ANDROID_HOME` / `ANDROID_SDK_ROOT` and build-tools (>= 34 / 36) installed. Run `flutter doctor -v`.

## Testing & Extensibility
- Only default `test/widget_test.dart` exists. When adding tests, follow: place in `test/`, mirror `lib/` path, import widgets/models directly.
- Write simple golden or widget tests for new screens; keep them deterministic (avoid network calls—mock image providers if needed).

## Example Tasks for Agents
- Add a favorites feature: create a state management layer (e.g., `ChangeNotifier`) and wrap `MaterialApp` with `ChangeNotifierProvider` in `main.dart`.
- Add filtering: introduce a `FiltersScreen` and a model struct for filters; apply filtering before pushing `MealsScreen`.

## Coding Style Summary
- Use `const` constructors & widgets where possible.
- Keep lines < 100 chars where feasible; wrap arguments each on its own line for readability (current style mixes but aim for clarity).
- Prefer explicit types for public fields.

## When Unsure
If adding architecture changes (state mgmt, routing overhaul, persistence), pause and request confirmation with a short proposal (why, impact, file list) before implementing.

---
Feel free to extend or refine this file as the project grows. Provide diffs, not whole file rewrites, for small adjustments.
