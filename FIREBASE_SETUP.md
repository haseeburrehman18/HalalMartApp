# Firebase Setup & Admin System Configuration

## 1. Firestore Security Rules

Update your Firebase Firestore rules to protect admin operations. Go to **Firebase Console** → **Firestore Database** → **Rules** and apply these rules:

```firebase_rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth.token.get('role') == 'admin';
    }
    
    // Helper function to check if user is seller
    function isSeller() {
      return request.auth.token.get('role') == 'seller';
    }

    // ─────────────────────────────────────────────────────
    // USERS COLLECTION
    // ─────────────────────────────────────────────────────
    match /users/{userId} {
      // Anyone can read their own profile
      allow read: if request.auth.uid == userId;
      
      // Admins can read all users
      allow read: if isAdmin();
      
      // Users can create their own account
      allow create: if request.auth.uid == userId && 
                       'name' in request.resource.data &&
                       'email' in request.resource.data &&
                       'role' in request.resource.data;
      
      // Users can update their own profile
      allow update: if request.auth.uid == userId &&
                       !('isEnabled' in request.resource.data);
      
      // Only admins can update isEnabled field
      allow update: if isAdmin() && 
                       request.resource.data.isEnabled is bool;
      
      // Only admins can delete users
      allow delete: if isAdmin();
    }

    // ─────────────────────────────────────────────────────
    // PRODUCTS COLLECTION
    // ─────────────────────────────────────────────────────
    match /products/{productId} {
      // Anyone authenticated can read approved products
      allow read: if request.auth != null && 
                     resource.data.certStatus == 'approved';
      
      // Sellers can read their own products
      allow read: if request.auth != null && 
                     request.auth.uid == resource.data.sellerId;
      
      // Admins can read all products (including pending/rejected)
      allow read: if isAdmin();
      
      // Sellers can create products
      allow create: if request.auth != null &&
                       isSeller() &&
                       request.resource.data.sellerId == request.auth.uid &&
                       request.resource.data.certStatus == 'pending' &&
                       'name' in request.resource.data &&
                       'price' in request.resource.data;
      
      // Sellers can update their own products only if not approved
      allow update: if request.auth.uid == resource.data.sellerId &&
                       isSeller() &&
                       resource.data.certStatus == 'pending';
      
      // Only admins can update certification status and rejection reason
      allow update: if isAdmin() &&
                       ('certStatus' in request.resource.data ||
                        'rejectionReason' in request.resource.data);
      
      // Sellers can delete their own pending products
      allow delete: if request.auth.uid == resource.data.sellerId &&
                       isSeller() &&
                       resource.data.certStatus == 'pending';
    }

    // ─────────────────────────────────────────────────────
    // ORDERS COLLECTION
    // ─────────────────────────────────────────────────────
    match /orders/{orderId} {
      allow read: if request.auth != null &&
                     (request.auth.uid == resource.data.userId ||
                      isAdmin());
      
      allow create: if request.auth != null &&
                       request.auth.uid == request.resource.data.userId;
      
      allow update: if isAdmin() ||
                       (request.auth.uid == resource.data.userId &&
                        request.resource.data.status == 'cancelled');
    }

    // ─────────────────────────────────────────────────────
    // CERTIFICATES COLLECTION
    // ─────────────────────────────────────────────────────
    match /certificates/{certId} {
      allow read: if request.auth != null &&
                     (request.auth.uid == resource.data.sellerId ||
                      isAdmin());
      
      allow create: if request.auth != null &&
                       isSeller() &&
                       request.auth.uid == request.resource.data.sellerId;
      
      allow update, delete: if isAdmin();
    }
  }
}
```

---

## 2. Firebase Auth Custom Claims Setup

To use the admin security rules, you need to set custom claims in Firebase Auth. This is done via **Firebase Admin SDK** (server-side).

### Option A: Using Firebase Admin SDK (Recommended)

**Create a Cloud Function** to set custom claims:

1. Go to **Firebase Console** → **Functions**
2. Deploy this function:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.setUserRole = functions.https.onCall(async (data, context) => {
  // Only admins can set roles
  if (!context.auth.token.admin) {
    throw new functions.https.HttpsError('permission-denied',
      'Only admins can set user roles');
  }

  const { uid, role } = data;
  
  try {
    await admin.auth().setCustomUserClaims(uid, { role: role });
    return { success: true, message: `User role set to ${role}` };
  } catch (error) {
    throw new functions.https.HttpsError('internal', error.message);
  }
});

exports.setAdminOnUserCreate = functions.auth.user().onCreate(async (user) => {
  // Set default role to 'user' for new accounts
  try {
    await admin.auth().setCustomUserClaims(user.uid, { role: 'user' });
  } catch (error) {
    console.error('Error setting default role:', error);
  }
});
```

### Option B: Using Firebase Admin CLI

```bash
# Install Firebase Admin SDK
npm install -g firebase-admin

# Set role for a specific user
firebase functions:shell
> const uid = "USER_UID_HERE";
> admin.auth().setCustomUserClaims(uid, { role: "admin" });
```

---

## 3. Setting Up Admin Users in Flutter

After creating a user account, promote them to admin via Firebase Console:

1. **Firebase Console** → **Authentication** → **Users**
2. Find the user you want to make admin
3. Click on the user to view details
4. Click the **Custom claims** section (scroll down)
5. Add custom claim:
   ```json
   {"role": "admin"}
   ```

Or use the Firebase CLI:
```bash
firebase auth:set-custom-claims <UID> --claims='{"role":"admin"}'
```

---

## 4. Verify Setup in Flutter

Add this test code to verify your setup is working:

```dart
// In admin_provider.dart or admin_service.dart, add a test method:

Future<void> testAdminAccess() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    print('Current user: ${user?.email}');
    print('Custom claims: ${user?.getIdTokenResult()}');
    
    // Try fetching all products
    final snapshot = await FirebaseFirestore.instance
        .collection('products')
        .get();
    
    print('Successfully fetched ${snapshot.docs.length} products');
    print('Admin access verified!');
  } catch (e) {
    print('Admin access denied: $e');
  }
}
```

Call this method in the Admin Dashboard to verify:

```dart
// In admin_dashboard_screen.dart initState:
WidgetsBinding.instance.addPostFrameCallback((_) {
  // Uncomment to test:
  // context.read<AdminProvider>().testAdminAccess();
  context.read<AdminProvider>().loadDashboardStats();
});
```

---

## 5. Testing the Admin System

### Test Scenario 1: Product Approval

1. **Create a test seller account** (role: "seller")
2. **Add a product** via seller dashboard
3. **Switch to admin account** (role: "admin")
4. **Go to Product Approval** screen
5. **Verify** pending products appear
6. **Click Approve** → Product status changes to "approved" in Firestore
7. **Product appears** in regular user/customer search

### Test Scenario 2: User Management

1. **Create 2-3 test user accounts**
2. **Switch to admin account**
3. **Go to User Management** screen
4. **Verify** all users appear in correct tabs
5. **Search for a user** by name/email
6. **Toggle Enable/Disable** → Status updates in Firestore
7. **Disabled user** shows "DISABLED" badge

### Test Scenario 3: Dashboard Stats

1. **Create some products and users**
2. **Go to Admin Dashboard**
3. **Verify stats** show correct counts
4. **Create more data** in Firebase
5. **Refresh dashboard** → Stats update

---

## 6. Troubleshooting

### Issue: Admin can't see products
**Solution:**
- Check Firestore rules are deployed correctly
- Verify admin user has `role: "admin"` custom claim
- Check browser console for security rule violations in Firebase logs

### Issue: "Permission denied" error
**Solution:**
- Verify user is authenticated
- Check custom claims are set: `firebase auth:get <UID>`
- Review Firestore rules for typos
- Check Firebase Auth is properly initialized

### Issue: Stats not updating
**Solution:**
- Verify Firestore queries in `admin_service.dart`
- Check collection names match exactly (case-sensitive)
- Verify data exists in Firestore collections
- Check network tab in DevTools

### Issue: Search not working
**Solution:**
- Firestore doesn't support full-text search by default
- The app implements client-side search (filters in memory)
- For large datasets, consider using Algolia or Typesense

---

## 7. Production Deployment Checklist

- [ ] Set up Firestore rules in production
- [ ] Create first admin user via Firebase CLI
- [ ] Test admin operations thoroughly
- [ ] Enable Firestore backups
- [ ] Set up Firebase monitoring/alerts
- [ ] Document admin onboarding process
- [ ] Train admins on the system
- [ ] Set up audit logging (optional enhancement)

---

## 8. Useful Firebase CLI Commands

```bash
# Set custom claims for a user
firebase auth:set-custom-claims <UID> --claims='{"role":"admin"}'

# Get user info with custom claims
firebase auth:get <UID>

# List all users (requires Auth admin)
firebase auth:list

# Delete a user
firebase auth:delete <UID>

# View Firestore rules
firebase firestore:rules:describe

# Deploy Firestore rules
firebase deploy --only firestore:rules
```

---

## 9. Testing with Emulator (Local Development)

Use Firebase Emulator for local development:

```bash
# Install emulator
firebase emulators:start

# In pubspec.yaml, add:
dev_dependencies:
  firebase_emulator_setup: ^1.0.0
```

In `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    // Connect to emulator
    await Firebase.initializeApp();
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  } else {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  
  runApp(const HalalVerifyApp());
}
```

---

**Last Updated:** April 28, 2026
**Version:** 1.0
