# Expense Tracker

A polished offline Flutter Android app for tracking personal income and expenses in Bangladeshi Taka (৳).

## Features

- Dashboard with total income, expenses, current balance, and recent activity
- SQLite-backed create, view, edit, and delete transaction flow
- Income and expense categories, validation, date picker, confirmation dialog, and responsive Material 3 interface
- Locally persisted data in `expense_tracker.db`; no account or network is required

## Technology

Flutter and Dart, Material 3, `sqflite`, `path`, and `intl`.

## Run in Android Studio

1. Open this project folder in Android Studio.
2. Select an Android emulator or physical Android device.
3. Run `flutter pub get`, then run the app from the Flutter configuration.

You can also run `flutter run` from the project root. The database table is `transactions` with fields `id`, `title`, `amount`, `category`, `type`, and ISO-8601 `date`.

## Structure

`lib/models` contains the transaction model, `lib/database` contains SQLite access, `lib/screens` contains the application flow, `lib/widgets` contains reusable UI, and `lib/utils` defines the theme.

## GitHub submission

Commit source, `pubspec.yaml`, the lock file, README, and platform folders. The included `.gitignore` excludes generated artifacts and local IDE files.
