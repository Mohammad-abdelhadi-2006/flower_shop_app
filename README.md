# Flower Shop App

A cross-platform flower shop mobile app built with **Flutter** and **Firebase**. Users can browse products, sign in (email/password or Google), manage a shopping cart, and place orders.

---

## Tech Stack

- **Flutter** / **Dart**
- **Provider** — state management
- **Firebase Authentication** — email/password + Google Sign-In
- **Cloud Firestore** — user data and orders
- **Firebase Storage** — images

---

## Features

- **Authentication**
  - Email & password sign up / login
  - Google Sign-In
  - Email verification
  - Forgot / reset password
- **Products**
  - Product listing on the home screen
  - Product details screen
- **Cart**
  - Add and remove products
  - Live total price
- **Checkout**
  - Review cart items and place an order
- **Profile**
  - View and manage user info

---

## Project Structure

```
lib/
├── pages/
│   ├── home.dart
│   ├── login.dart
│   ├── register.dart
│   ├── verify_email.dart
│   ├── forget_password.dart
│   ├── details_screen.dart
│   ├── checkout.dart
│   └── profile_page.dart
├── provider/
│   ├── cart.dart
│   ├── user_provider.dart
│   └── google_sign_in_provider.dart
├── model/
└── shared/
```

---

## Getting Started

### Prerequisites
- Flutter SDK
- A Firebase project

### 1. Clone the repo
```bash
git clone https://github.com/Mohammad-abdelhadi-2006/flower_shop_app.git
cd flower_shop_app
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Set up Firebase
This app needs your own Firebase configuration:
- Create a Firebase project
- Enable **Authentication** (Email/Password + Google) and **Cloud Firestore**
- Add your app and place the config files (`google-services.json` for Android)
- Run `flutterfire configure` to generate `firebase_options.dart`

### 4. Run the app
```bash
flutter run
```

---

## Related Project

This app pairs with a separate **ASP.NET Core Web API** backend (products, users, orders):
[FlowerShop API](https://github.com/Mohammad-abdelhadi-2006/FlowerShop)

---

## Author

**Mohammad Abdelhadi** — [GitHub](https://github.com/Mohammad-abdelhadi-2006)
