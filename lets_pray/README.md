# lets_pray

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

APP_KEY="$(php artisan key:generate --show)" && flyctl secrets set --app sales-plus APP_KEY="$APP_KEY" APP_ENV=production APP_DEBUG=false APP_URL=https://sales-plus.fly.dev LOG_CHANNEL=stderr DB_CONNECTION=pgsql DB_HOST=sales-plus-db.internal DB_PORT=5432 DB_DATABASE=sales_plus DB_USERNAME=sales_plus DB_PASSWORD='yz4o7IPmIzwwAK8'