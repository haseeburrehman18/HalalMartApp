# 🌿 HalalVerify Marketplace
### A Flutter Final Year Project — Multi-Vendor Halal E-Commerce App

---

## 📱 App Overview

HalalVerify Marketplace is a halal-certified multi-vendor e-commerce mobile application where:
- **Users** shop verified halal products
- **Sellers** upload halal-certified products
- **Admins** verify certificates and approve listings

---

## 🗂️ Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── app_constants.dart        # App-wide constants, roles, categories
│   ├── theme/
│   │   └── app_theme.dart            # Emerald green + gold theme
│   └── routes/
│       ├── app_routes.dart           # All named route strings
│       └── route_generator.dart      # Route factory (onGenerateRoute)
│
├── models/
│   ├── user_model.dart               # User data + Firestore mapping
│   ├── product_model.dart            # Product data + mock data
│   └── order_model.dart              # Cart items + order model
│
├── services/
│   └── auth_service.dart             # Firebase Auth placeholder
│
├── providers/
│   ├── auth_provider.dart            # Auth state management
│   └── cart_provider.dart            # Shopping cart state
│
├── views/
│   ├── user/                         # 12 user screens
│   │   ├── splash_screen.dart        # Screen 1
│   │   ├── onboarding_screen.dart    # Screen 2
│   │   ├── login_screen.dart         # Screen 3
│   │   ├── register_screen.dart      # Screen 4
│   │   ├── home_screen.dart          # Screen 5 (+ BottomNavBar)
│   │   ├── categories_screen.dart    # Screen 6
│   │   ├── product_list_screen.dart  # Screen 7
│   │   ├── product_detail_screen.dart# Screen 8
│   │   ├── cart_screen.dart          # Screen 9
│   │   ├── checkout_screen.dart      # Screen 10
│   │   ├── order_confirmation_screen.dart # Screen 11
│   │   └── user_profile_screen.dart  # Screen 12
│   │
│   ├── seller/                       # 4 seller screens
│   │   ├── seller_dashboard_screen.dart  # Screen 13 (+ Drawer)
│   │   ├── add_product_screen.dart       # Screen 14
│   │   ├── seller_orders_screen.dart     # Screen 15
│   │   └── upload_certificate_screen.dart# Screen 16
│   │
│   └── admin/                        # 4 admin screens
│       ├── admin_dashboard_screen.dart   # Screen 17 (+ Drawer)
│       ├── certificate_review_screen.dart# Screen 18
│       ├── product_approval_screen.dart  # Screen 19
│       └── user_management_screen.dart   # Screen 20
│
├── widgets/
│   ├── custom_button.dart            # Reusable button (filled + outlined)
│   ├── input_field.dart              # Reusable text field + password toggle
│   ├── product_card.dart             # Product card with Add to Cart
│   └── status_chip.dart             # Status badge + AppDrawer widget
│
└── main.dart                         # App entry + providers + routing
```

---

## 🚀 Getting Started

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Demo Login Credentials
| Role | Email | Password |
|------|-------|----------|
| Customer | `user@test.com` | any text |
| Seller | `seller@test.com` | any text |
| Admin | `admin@test.com` | any text |

---

## 🔥 Firebase Setup (Production)

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Add Android/iOS app and download `google-services.json` / `GoogleService-Info.plist`
3. Uncomment Firebase initialization in `main.dart`
4. Replace mock methods in `auth_service.dart` with real Firebase calls:

```dart
// auth_service.dart — replace mock login with:
final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email, password: password,
);
final doc = await FirebaseFirestore.instance
    .collection('users')
    .doc(credential.user!.uid)
    .get();
return UserModel.fromMap(doc.data()!);
```

---

## 🎨 Design System

| Element | Value |
|---------|-------|
| Primary Color | `#10B981` (Emerald Green) |
| Accent Color | `#F59E0B` (Gold) |
| Background | `#FFFFFF` |
| Border Radius | `12–16px` |
| Default Padding | `16px` |

---

## 🧭 Navigation Flow

```
Splash → Onboarding → Login/Register
                           ↓
            role == user → Home (BottomNavBar)
                           ├── Categories
                           ├── Product List → Product Detail → Cart → Checkout → Confirmation
                           └── Profile

            role == seller → Seller Dashboard (Drawer)
                              ├── Add Product
                              ├── Orders
                              └── Upload Certificate

            role == admin → Admin Dashboard (Drawer)
                             ├── Certificate Review
                             ├── Product Approval
                             └── User Management
```

---

## 📦 Dependencies

```yaml
provider: ^6.1.1          # State management
firebase_core: ^2.24.2    # Firebase core
firebase_auth: ^4.16.0    # Authentication
cloud_firestore: ^4.14.0  # Database
firebase_storage: ^11.6.0 # File storage
image_picker: ^1.0.7      # Image upload
cached_network_image: ^3.3.1 # Image caching
```

---

## ✅ Features Implemented

- [x] 20 screens — exactly as specified
- [x] Named routing with route generator
- [x] Role-based navigation (user/seller/admin)
- [x] Provider state management (Auth + Cart)
- [x] Emerald green + gold theme
- [x] BottomNavigationBar (User)
- [x] Drawer navigation (Seller + Admin)
- [x] Product grid with mock data
- [x] Cart with quantity management
- [x] Checkout flow
- [x] Certificate upload & review workflow
- [x] Product approval workflow
- [x] User management with toggle
- [x] Reusable widgets (CustomButton, InputField, ProductCard, StatusChip)
- [x] Firebase-ready architecture
- [x] Null safety
- [x] Clean folder structure

---

*Built for Final Year Project — HalalVerify Marketplace*
