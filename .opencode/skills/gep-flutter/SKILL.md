---
name: gep-flutter
description: Project conventions and architecture for the GEP (Gramora English Planet) Flutter app. Use when editing any Dart file under lib/, adding screens, widgets, cubits, routes, or theming in this repository.
---

# GEP (Gramora English Planet) Flutter App

## Overview

Flutter app for an English learning institute. User-facing dashboard plus an
admin panel for content management (notes, courses, banners, admissions,
enrolled students, updates).

## Stack

- **State management:** flutter_bloc (Cubits in `lib/cubits/<feature>/`)
- **Routing:** go_router via `lib/router/app_router.dart` (route table),
  `lib/router/app_routes.dart` (name/path constants),
  `lib/router/app_navigation.dart` (`AppNavigation` helpers)
- **Backend:** Firebase Auth, Firebase Analytics, Supabase
- **UI kit:** `material_ui` package
- **Charts:** fl_chart · **Animations:** flutter_animate · **Lottie:** lottie

## Critical Conventions

1. **Never import `flutter/material.dart`.** Always use
   `import 'package:material_ui/material_ui.dart';` — the whole codebase was
   migrated to it.
2. **Never hardcode routes.** Use `AppRoutes.kXxxRoute` constants with
   `AppNavigation.push / pushReplacement / goAndClearStack`.
3. **Theming:** read `Theme.of(context).colorScheme` instead of hardcoded
   colors. Brand colors/gradients/lottie paths live in
   `lib/core/constants/constants.dart` (`AppColors`, `AppGradients`,
   `AppLotties`). Themes are defined in `lib/core/themes/themes.dart`.
4. **`UpgradeAlert` (upgrader package) must live INSIDE the Navigator tree**
   (e.g., wrapping a screen's Scaffold). Placing it above `MaterialApp` causes
   a `No MaterialLocalizations found` crash; placing it in
   `MaterialApp.router`'s `builder` causes a `Navigator` crash.
5. **Auth flow:** `AuthCubit` wraps the app; `MyApp` in `lib/gep_app.dart`
   builds `MaterialApp.router` inside `AppWrapper` (which handles in-app
   review only).

## Directory Layout

```
lib/
  main.dart                  # bootstrap (Firebase, Supabase, env)
  gep_app.dart               # MyApp -> MaterialApp.router
  core/constants/            # AppColors, AppGradients, AppLotties, AppIcons
  core/themes/               # AppThemes.lightTheme / darkTheme
  cubits/<feature>/          # one cubit per feature
  models/                    # data models
  router/                    # AppRouter (go_router), AppRoutes, AppNavigation
  services/                  # auth, analytics, supabase services
  view/
    screens/user/            # user-facing screens (dashboard, notes, ...)
    screens/admin/           # admin panel screens
    widgets/                 # shared widgets (AppDrawer, BannerSlider, ...)
```

## Theme Toggle

`ThemeCubit` + `BlocBuilder<ThemeCubit, ThemeState>` toggles light/dark.
Dark mode uses true black scaffold; test new UI in both modes.

## Analysis & Run

The project requires Dart SDK ^3.10.0 (Flutter 3.38+). The default `flutter`
on PATH (3.35) is too old — use the Puro environment:

```bash
~/.puro/envs/3.47.0/flutter/bin/flutter analyze
~/.puro/envs/3.47.0/flutter/bin/flutter run
```

## Style

- Keep code short, minimal, and easy to read; no comments unless requested.
- Private widgets (`_Foo`) inside the same file for screen-local components.
- Staggered entrance animations via `flutter_animate` (see
  `dashboard_screen.dart` for the pattern).
