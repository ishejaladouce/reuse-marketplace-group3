# Reuse Marketplace (Flutter)

Michaella's screens from the user research and prototype document: Messages and chat, Checkout (Receive, Pay, Review), Orders (purchases and sales with delivery confirmation), Notifications, Community (Looking For feed and request form), Rating and review, Settings.

## Run
    flutter create . --platforms=android,ios   # generates android/ios folders once
    flutter pub get
    flutter run

## Notes
- Colours and the Manrope font follow the Figma prototype (see lib/theme/app_theme.dart).
- All data is in-memory (lib/data/mock_data.dart). Swap for Firestore streams later.
- Home, Explore and Sell tabs are placeholders for teammates' screens.
- Platform fee (5%) and delivery fee (3,000 RWF) in checkout are placeholders.
