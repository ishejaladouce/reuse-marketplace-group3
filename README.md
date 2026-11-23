# ReUse Marketplace

**ReUse Marketplace** is a Flutter-based mobile application designed to promote sustainability by making it easier for users to buy, sell, and discover pre-owned items.

The application provides a marketplace where users can list items for sale, communicate with sellers, create requests for items they are looking for, and manage their marketplace activities.

## Features

### Authentication and User Profiles
- User registration and login using Firebase Authentication
- Email verification and password reset
- Profile viewing and editing
- User verification interface

### Marketplace Listings
- Browse available second-hand items
- View listing details, including images, descriptions, and prices
- Create, edit, and manage personal listings
- Upload listing images using Supabase Storage
- Explore listings by category

### Looking For Requests
- Create requests for items users want to find
- Browse requests posted by other users
- Edit and manage personal requests

### Messaging
- Start conversations with sellers
- Send and receive messages
- View existing conversations

### Orders and Reviews
- Checkout interface for marketplace purchases
- View and manage orders
- Track order statuses
- Submit reviews after completed orders
- View seller reviews

**Note:** Payments are currently simulated for demonstration purposes. No real transactions are processed.

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Firebase Authentication | User authentication |
| Cloud Firestore | Database for marketplace information |
| Supabase Storage | Listing image storage |
| Riverpod | State management |
| GoRouter | Application navigation |

## Project Structure

```text
lib/
├── app/
│   ├── router/
│   └── theme/
├── core/
│   ├── providers/
│   ├── utils/
│   └── widgets/
├── features/
│   ├── auth/
│   ├── chat/
│   ├── listings/
│   ├── looking_for/
│   ├── marketplace/
│   ├── orders/
│   ├── profile/
│   └── reviews/
├── screens/
├── firebase_options.dart
└── main.dart
```

The application uses a feature-based architecture, with relevant data, domain, and presentation components organized within each feature.

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android emulator or physical device
- Firebase project
- Supabase project

### Installation

**1. Clone the repository**

```bash
git clone https://github.com/ishejaladouce/reuse-marketplace-group3.git
```

**2. Navigate to the project**

```bash
cd reuse-marketplace-group3
```

**3. Install dependencies**

```bash
flutter pub get
```

**4. Configure backend services**

Configure Firebase Authentication and Cloud Firestore, including the appropriate security rules.

Configure Supabase Storage and the required environment variables using the project's existing configuration. Obtain authorized project credentials before running the application.

**5. Run the application**

```bash
flutter run
```

## Testing

The application has been manually tested across its core marketplace workflows, including authentication, listing management, messaging, profile management, and order interactions.

Automated test files are also included under the `test/` directory.

To execute automated tests:

```bash
flutter test
```

## Current Limitations

- Payments use a demonstration workflow rather than a real payment gateway.
- Backend services require valid Firebase and Supabase configuration.
- Additional production security validation and testing are recommended before public deployment.

## Project Information

**Project:** ReUse Marketplace  
**Group:** Group 3  
**Framework:** Flutter  
**Repository:** https://github.com/ishejaladouce/reuse-marketplace-group3

## Project Goal

ReUse Marketplace aims to encourage responsible consumption, reduce unnecessary waste, and extend the useful life of products through a convenient second-hand marketplace.
