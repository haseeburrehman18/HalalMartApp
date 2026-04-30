# Admin System - Visual Architecture & Flow Diagrams

## 1. System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    ADMIN SYSTEM ARCHITECTURE                    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         UI LAYER (Views)                        │
├─────────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐   │
│  │ Product Approval │  │ User Management  │  │ Admin        │   │
│  │ Screen           │  │ Screen           │  │ Dashboard    │   │
│  │                  │  │                  │  │              │   │
│  │ - Pending list   │  │ - User tabs      │  │ - Stats      │   │
│  │ - Approve btn    │  │ - Search bar     │  │ - Action     │   │
│  │ - Reject btn     │  │ - Role filter    │  │   cards      │   │
│  │ - Dialog         │  │ - Toggle switch  │  │              │   │
│  └────────┬─────────┘  └────────┬─────────┘  └──────┬───────┘   │
│           │                     │                    │           │
│           └─────────────────────┼────────────────────┘           │
│                                 │                                │
└────────────────────────────┬────┴────────────────────────────────┘
                             │ Consumer Widget
                             ↓
┌─────────────────────────────────────────────────────────────────┐
│                    STATE MANAGEMENT LAYER                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│         AdminProvider (ChangeNotifier)                          │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                                                        │    │
│  │  • pendingProducts: List<ProductModel>               │    │
│  │  • filteredUsers: List<UserModel>                    │    │
│  │  • totalUsers, totalSellers, totalProducts: int      │    │
│  │  • isLoading*, *Error: State properties              │    │
│  │                                                        │    │
│  │  Methods:                                              │    │
│  │  • listenToPendingProducts()                           │    │
│  │  • approveProduct(String id)                           │    │
│  │  • rejectProduct(String id, String reason)            │    │
│  │  • initializeUserManagement()                          │    │
│  │  • searchUsers(String query)                           │    │
│  │  • toggleUserStatus(String id, bool enabled)          │    │
│  │  • loadDashboardStats()                                │    │
│  │                                                        │    │
│  └────────────────────────────────────────────────────────┘    │
│           │                              │                     │
│           │ Uses                         │ notifyListeners()   │
│           ↓                              │                     │
└───────────┼──────────────────────────────┼─────────────────────┘
            │                              │
            ↓                              ↑
┌─────────────────────────────────────────────────────────────────┐
│                      SERVICE LAYER (Firebase)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│              AdminService (Firebase Operations)                │
│  ┌────────────────────────────────────────────────────────┐    │
│  │                                                        │    │
│  │  PRODUCTS METHODS:                                    │    │
│  │  • getPendingProducts() → Stream<List<ProductModel>>  │    │
│  │  • approveProduct(String id)                          │    │
│  │  • rejectProduct(String id, String reason)            │    │
│  │                                                        │    │
│  │  USERS METHODS:                                        │    │
│  │  • getAllUsers() → Stream<List<UserModel>>            │    │
│  │  • getUsersByRole(String role) → Stream              │    │
│  │  • searchUsers(String query) → Future<List>           │    │
│  │  • toggleUserStatus(String id, bool enabled)          │    │
│  │  • deleteUser(String id)                              │    │
│  │                                                        │    │
│  │  STATS METHODS:                                        │    │
│  │  • getTotalUsersCount() → Future<int>                │    │
│  │  • getSellersCount() → Future<int>                    │    │
│  │  • getProductsCount() → Future<int>                   │    │
│  │  • getPendingProductsCount() → Future<int>           │    │
│  │                                                        │    │
│  └────────────────────────────────────────────────────────┘    │
│           │                              │                     │
│           │ Queries/Updates             │ Streams              │
│           ↓                              │                     │
└───────────┼──────────────────────────────┼─────────────────────┘
            │                              │
            ↓                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                      DATABASE LAYER (Firestore)                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────────────┐    ┌──────────────────────┐         │
│  │  products Collection │    │   users Collection   │         │
│  │  ─────────────────   │    │  ─────────────────   │         │
│  │  - id                │    │  - uid               │         │
│  │  - sellerId          │    │  - name              │         │
│  │  - name              │    │  - email             │         │
│  │  - price             │    │  - role              │         │
│  │  - certStatus        │◄───┤  - isEnabled ✓NEW   │         │
│  │  - rejectionReason ✓ │    │  - createdAt         │         │
│  │  - createdAt         │    │  - photoUrl          │         │
│  │  - updatedAt         │    │                      │         │
│  │                      │    │                      │         │
│  └──────────────────────┘    └──────────────────────┘         │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Product Approval Flow

```
┌─────────────────────────────────────────────────────────────────┐
│               PRODUCT APPROVAL WORKFLOW                         │
└─────────────────────────────────────────────────────────────────┘

START
  │
  ├─→ [Admin Dashboard]
  │      │
  │      └─→ Click "Product Approvals" Card
  │           │
  │           ↓
  │   [Product Approval Screen]
  │           │
  │           ├─→ Call: AdminProvider.listenToPendingProducts()
  │           │           │
  │           │           ├─→ AdminService.getPendingProducts()
  │           │           │       │
  │           │           │       ↓
  │           │           │   Query Firestore:
  │           │           │   products WHERE certStatus == 'pending'
  │           │           │       │
  │           │           │       ↓
  │           │           │   Return Stream<List<ProductModel>>
  │           │           │
  │           │           ├─→ Listen to stream updates
  │           │           │   (Real-time updates when products change)
  │           │           │
  │           │           └─→ notifyListeners() → UI updates
  │           │
  │           ↓
  │   [Display Pending Products]
  │   (Cards with product details)
  │
  ├─→ APPROVAL PATH
  │   │
  │   └─→ Admin clicks "Approve" button
  │           │
  │           ↓
  │       Show loading spinner
  │           │
  │           ├─→ Call: AdminProvider.approveProduct(productId)
  │           │           │
  │           │           ├─→ AdminService.approveProduct(productId)
  │           │           │       │
  │           │           │       ├─→ FirebaseFirestore.update()
  │           │           │       │   {
  │           │           │       │     certStatus: 'approved'
  │           │           │       │     rejectionReason: null
  │           │           │       │     updatedAt: now()
  │           │           │       │   }
  │           │           │       │
  │           │           │       └─→ ✓ Success
  │           │           │
  │           │           └─→ notifyListeners()
  │           │
  │           ├─→ Stream updates (real-time)
  │           │
  │           ├─→ Product removed from pending list
  │           │
  │           ├─→ UI automatically refreshes
  │           │
  │           └─→ Show success snackbar
  │               "Product approved successfully"
  │
  ├─→ REJECTION PATH
  │   │
  │   └─→ Admin clicks "Reject" button
  │           │
  │           ↓
  │       [Rejection Dialog Opens]
  │       Input field for rejection reason
  │           │
  │           ├─→ Admin types reason
  │           │   (e.g., "Missing halal certificate")
  │           │
  │           ├─→ Admin clicks "Reject" button
  │           │
  │           ↓
  │       Show loading spinner
  │           │
  │           ├─→ Call: AdminProvider.rejectProduct(productId, reason)
  │           │           │
  │           │           ├─→ AdminService.rejectProduct(productId, reason)
  │           │           │       │
  │           │           │       ├─→ FirebaseFirestore.update()
  │           │           │       │   {
  │           │           │       │     certStatus: 'rejected'
  │           │           │       │     rejectionReason: reason
  │           │           │       │     updatedAt: now()
  │           │           │       │   }
  │           │           │       │
  │           │           │       └─→ ✓ Success
  │           │           │
  │           │           └─→ notifyListeners()
  │           │
  │           ├─→ Stream updates (real-time)
  │           │
  │           ├─→ Product removed from pending list
  │           │
  │           ├─→ UI automatically refreshes
  │           │
  │           └─→ Show success snackbar
  │               "Product rejected"
  │
  └─→ END (No more pending products)
      Admin sees: "No pending products - All products have been reviewed"
```

---

## 3. User Management Flow

```
┌─────────────────────────────────────────────────────────────────┐
│              USER MANAGEMENT WORKFLOW                           │
└─────────────────────────────────────────────────────────────────┘

START
  │
  ├─→ [Admin Dashboard]
  │      │
  │      └─→ Click "User Management" Card
  │           │
  │           ↓
  │   [User Management Screen]
  │           │
  │           ├─→ Call: AdminProvider.initializeUserManagement()
  │           │           │
  │           │           ├─→ AdminService.getAllUsers()
  │           │           │       │
  │           │           │       ├─→ Query Firestore:
  │           │           │       │   users collection (all)
  │           │           │       │
  │           │           │       └─→ Return Stream<List<UserModel>>
  │           │           │
  │           │           ├─→ Listen to stream updates
  │           │           │   (Real-time user changes)
  │           │           │
  │           │           └─→ notifyListeners() → UI updates
  │           │
  │           ├─→ [Tab View]
  │           │   ├─→ Tab 1: All Users
  │           │   ├─→ Tab 2: Customers (role == 'user')
  │           │   └─→ Tab 3: Sellers (role == 'seller')
  │           │
  │           ├─→ [Search Bar]
  │           │   │
  │           │   └─→ Admin types search query
  │           │           │
  │           │           ├─→ Call: AdminProvider.searchUsers(query)
  │           │           │           │
  │           │           │           ├─→ Client-side filtering:
  │           │           │           │   - Search in name
  │           │           │           │   - Search in email
  │           │           │           │
  │           │           │           └─→ notifyListeners()
  │           │           │
  │           │           └─→ UI shows filtered users
  │           │
  │           ↓
  │   [Display User List]
  │   (Cards with user info)
  │
  ├─→ TOGGLE USER STATUS
  │   │
  │   └─→ Admin toggles Enable/Disable switch
  │           │
  │           ↓
  │       Show loading spinner
  │           │
  │           ├─→ Call: AdminProvider.toggleUserStatus(userId, newStatus)
  │           │           │
  │           │           ├─→ AdminService.toggleUserStatus(userId, newStatus)
  │           │           │       │
  │           │           │       ├─→ FirebaseFirestore.update()
  │           │           │       │   {
  │           │           │       │     isEnabled: true/false
  │           │           │       │   }
  │           │           │       │
  │           │           │       └─→ ✓ Success
  │           │           │
  │           │           ├─→ Update local UserModel
  │           │           │
  │           │           └─→ notifyListeners()
  │           │
  │           ├─→ UI updates immediately
  │           │   - Toggle switch reflects new state
  │           │   - "DISABLED" badge shown (if disabled)
  │           │
  │           └─→ Show success snackbar
  │               "User enabled/disabled"
  │
  ├─→ FILTER BY ROLE (Tab Change)
  │   │
  │   └─→ Admin clicks on tab (All/Customers/Sellers)
  │           │
  │           ├─→ Call: AdminProvider.setUserRoleFilter(role)
  │           │           │
  │           │           ├─→ Filter users in memory
  │           │           │   (No new Firebase query)
  │           │           │
  │           │           └─→ notifyListeners()
  │           │
  │           └─→ UI shows users for selected role
  │
  └─→ END
      Admin can manage users efficiently
```

---

## 4. Admin Dashboard Stats Flow

```
┌─────────────────────────────────────────────────────────────────┐
│           ADMIN DASHBOARD STATS WORKFLOW                        │
└─────────────────────────────────────────────────────────────────┘

START
  │
  ├─→ [Admin Dashboard Screen Loaded]
  │      │
  │      └─→ initState() executes
  │           │
  │           ├─→ WidgetsBinding.addPostFrameCallback()
  │           │       │
  │           │       └─→ Call: AdminProvider.loadDashboardStats()
  │           │               │
  │           │               ├─→ Set isLoadingStats = true
  │           │               │   notifyListeners() → Show loading
  │           │               │
  │           │               ├─→ AdminService.getTotalUsersCount()
  │           │               │   └─→ Firestore query: users.count()
  │           │               │       → totalUsers
  │           │               │
  │           │               ├─→ AdminService.getSellersCount()
  │           │               │   └─→ Firestore query:
  │           │               │       users WHERE role == 'seller'
  │           │               │       → totalSellers
  │           │               │
  │           │               ├─→ AdminService.getProductsCount()
  │           │               │   └─→ Firestore query: products.count()
  │           │               │       → totalProducts
  │           │               │
  │           │               ├─→ AdminService.getPendingProductsCount()
  │           │               │   └─→ Firestore query:
  │           │               │       products WHERE
  │           │               │       certStatus == 'pending'
  │           │               │       → pendingCount
  │           │               │
  │           │               ├─→ Set isLoadingStats = false
  │           │               │
  │           │               └─→ notifyListeners() → UI updates
  │           │
  │           ↓
  │   [Display Stats]
  │   ┌────────────────────────────────────────┐
  │   │ Total Users: 1,248      │              │
  │   ├─────────────────────────┼──────────────┤
  │   │ Sellers: 87             │              │
  │   ├─────────────────────────┼──────────────┤
  │   │ Products: 342           │              │
  │   ├─────────────────────────┼──────────────┤
  │   │ Pending: 14             │              │
  │   └────────────────────────────────────────┘
  │
  ├─→ REAL-TIME UPDATES (Optional Enhancement)
  │   │
  │   └─→ If using Firestore listeners instead of count():
  │           │
  │           ├─→ Stats update in real-time
  │           │   (as new products/users are added)
  │           │
  │           └─→ UI refreshes automatically
  │
  └─→ END
      Admin sees current platform statistics
```

---

## 5. State Management Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│         ADMIN PROVIDER LIFECYCLE & STATE FLOW                   │
└─────────────────────────────────────────────────────────────────┘

Application Startup
  │
  ├─→ main.dart initializes
  │      │
  │      └─→ MultiProvider includes:
  │           ├─→ AuthProvider
  │           ├─→ CartProvider
  │           └─→ AdminProvider() ← Created here
  │
  ├─→ Admin Dashboard Screen Loaded
  │      │
  │      ├─→ context.watch<AdminProvider>() 
  │      │   (Listens to AdminProvider changes)
  │      │
  │      ├─→ initState()
  │      │   │
  │      │   ├─→ AdminProvider.loadDashboardStats()
  │      │   │   ├─→ isLoadingStats = true
  │      │   │   ├─→ Fetch stats from Firebase
  │      │   │   └─→ notifyListeners() → UI rebuilds
  │      │   │
  │      │   └─→ AdminProvider.listenToPendingProducts()
  │      │       ├─→ Start stream listener
  │      │       ├─→ Wait for real-time updates
  │      │       └─→ Update UI when data changes
  │      │
  │      ├─→ Consumer<AdminProvider>
  │      │   (Rebuilds when AdminProvider notifies)
  │      │
  │      └─→ UI displays current state:
  │          ├─→ pendingProducts
  │          ├─→ totalUsers, totalSellers, etc.
  │          └─→ isLoading*, *Error flags
  │
  ├─→ User Interaction
  │      │
  │      ├─→ Admin clicks "Approve Product"
  │      │      │
  │      │      └─→ AdminProvider.approveProduct(id)
  │      │          ├─→ AdminService updates Firestore
  │      │          ├─→ Stream listener receives update
  │      │          ├─→ notifyListeners()
  │      │          └─→ UI rebuilds with new data
  │      │
  │      ├─→ Admin clicks "Reject Product"
  │      │      │
  │      │      └─→ AdminProvider.rejectProduct(id, reason)
  │      │          ├─→ AdminService updates Firestore
  │      │          ├─→ Stream listener receives update
  │      │          ├─→ notifyListeners()
  │      │          └─→ UI rebuilds with new data
  │      │
  │      └─→ Admin toggles user enable/disable
  │             │
  │             └─→ AdminProvider.toggleUserStatus(id, enabled)
  │                 ├─→ AdminService updates Firestore
  │                 ├─→ Local state updated
  │                 ├─→ notifyListeners()
  │                 └─→ UI rebuilds instantly
  │
  ├─→ Real-time Updates from Other Admins
  │      │
  │      └─→ Firestore stream notifies of changes
  │          (Another admin approves a product)
  │          │
  │          ├─→ Stream emits new data
  │          ├─→ AdminProvider receives update
  │          ├─→ notifyListeners()
  │          └─→ UI automatically refreshes
  │
  └─→ Screen Disposed
       │
       └─→ dispose() called
           ├─→ Stream listeners closed
           ├─→ Memory cleaned up
           └─→ State reset
```

---

## 6. Firestore Query Patterns

```
┌─────────────────────────────────────────────────────────────────┐
│         FIRESTORE QUERY PATTERNS USED                           │
└─────────────────────────────────────────────────────────────────┘

1. GET PENDING PRODUCTS (Stream)
   ┌─────────────────────────────────────────┐
   │ db.collection('products')               │
   │   .where('certStatus', '==', 'pending') │
   │   .orderBy('createdAt', 'desc')         │
   │   .snapshots()                          │
   │   .map(...)                             │
   └─────────────────────────────────────────┘
   Result: Stream<List<ProductModel>>
   Real-time updates whenever products change

2. APPROVE PRODUCT (Update)
   ┌─────────────────────────────────────────┐
   │ db.collection('products')               │
   │   .doc(productId)                       │
   │   .update({                             │
   │     'certStatus': 'approved',           │
   │     'rejectionReason': null,            │
   │     'updatedAt': timestamp              │
   │   })                                    │
   └─────────────────────────────────────────┘
   Result: Future<void>
   Atomically updates one document

3. REJECT PRODUCT (Update)
   ┌─────────────────────────────────────────┐
   │ db.collection('products')               │
   │   .doc(productId)                       │
   │   .update({                             │
   │     'certStatus': 'rejected',           │
   │     'rejectionReason': reason,          │
   │     'updatedAt': timestamp              │
   │   })                                    │
   └─────────────────────────────────────────┘
   Result: Future<void>
   Stores rejection feedback for seller

4. GET ALL USERS (Stream)
   ┌─────────────────────────────────────────┐
   │ db.collection('users')                  │
   │   .orderBy('createdAt', 'desc')         │
   │   .snapshots()                          │
   │   .map(...)                             │
   └─────────────────────────────────────────┘
   Result: Stream<List<UserModel>>
   Real-time updates as users are added

5. GET USERS BY ROLE (Stream)
   ┌─────────────────────────────────────────┐
   │ db.collection('users')                  │
   │   .where('role', '==', 'seller')        │
   │   .orderBy('createdAt', 'desc')         │
   │   .snapshots()                          │
   │   .map(...)                             │
   └─────────────────────────────────────────┘
   Result: Stream<List<UserModel>>
   Filters users by role in real-time

6. TOGGLE USER STATUS (Update)
   ┌─────────────────────────────────────────┐
   │ db.collection('users')                  │
   │   .doc(userId)                          │
   │   .update({                             │
   │     'isEnabled': bool                   │
   │   })                                    │
   └─────────────────────────────────────────┘
   Result: Future<void>
   Enable/disable user account

7. SEARCH USERS (Query + Client-side)
   ┌─────────────────────────────────────────┐
   │ 1. db.collection('users').get()         │
   │                                         │
   │ 2. Filter in memory:                    │
   │    name.toLowerCase().contains(query)   │
   │    email.toLowerCase().contains(query)  │
   │                                         │
   │ 3. Return filtered list                 │
   └─────────────────────────────────────────┘
   Result: Future<List<UserModel>>
   Client-side search (Firestore limitation)
```

---

## 7. Error Handling Flow

```
┌─────────────────────────────────────────────────────────────────┐
│            ERROR HANDLING ARCHITECTURE                          │
└─────────────────────────────────────────────────────────────────┘

User Action (e.g., Approve Product)
  │
  ↓
try {
  │
  ├─→ AdminService.approveProduct()
  │      │
  │      ├─→ try {
  │      │      Firebase update()
  │      │   } catch (e) {
  │      │      throw Exception('Failed to approve product: $e')
  │      │   }
  │      │
  │      └─→ Returns Future<void> or throws
  │
  └─→ AdminProvider catches exception
       │
       ├─→ _productsError = e.toString()
       ├─→ notifyListeners()
       │
       └─→ UI displays error:
           ├─→ Error icon + message
           ├─→ Retry button
           └─→ Snackbar with error details

} catch (e) {
  │
  └─→ View catches exception
       │
       ├─→ Show SnackBar(error)
       │   "Error: Failed to approve product"
       │
       └─→ Log error for debugging

}

Finally:
  │
  └─→ UI state reset
      └─→ Loading spinner hidden
          Processing disabled

```

---

## 8. Real-time Sync Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│        REAL-TIME SYNCHRONIZATION BETWEEN ADMINS                │
└─────────────────────────────────────────────────────────────────┘

Admin 1 (Browser/Device A)        Admin 2 (Browser/Device B)
         │                                  │
         │                                  │
    [Dashboard]                        [Dashboard]
         │                                  │
         ├─→ Stream listener                ├─→ Stream listener
         │   (pendingProducts)              │   (pendingProducts)
         │                                  │
         └─→ Firestore ←─────────────────────┘
              products
              collection

Timeline:
─────────────────────────────────────────────────────────────────

T1: Admin 1 clicks "Approve Product A"
    Admin 1 → Firebase update
    Firebase: Product A certStatus = 'approved'

T2: Firestore emits change event
    └─→ Stream listener on Admin 1 device: receives update
    └─→ Stream listener on Admin 2 device: receives update

T3: Both admins' UIs refresh automatically
    Admin 1: Product A disappears from pending list ✓
    Admin 2: Product A disappears from pending list ✓

Result: Both admins see consistent data in real-time!

```

---

## 9. Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│         PRODUCTION DEPLOYMENT SETUP                             │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  Flutter App     │ (iOS/Android/Web)
│  (AdminProvider) │
└────────┬─────────┘
         │ Requests
         ↓
┌──────────────────────────────────────────┐
│  Firebase Auth                           │
│  - Authenticates admin users             │
│  - Manages custom claims (role: admin)   │
└────────┬─────────────────────────────────┘
         │
         ↓
┌──────────────────────────────────────────┐
│  Firestore Database                      │
│  ┌──────────────┐   ┌────────────────┐  │
│  │ products     │   │ users          │  │
│  │ collection   │   │ collection     │  │
│  │              │   │                │  │
│  │ (Streams &   │   │ (Streams &     │  │
│  │  Updates)    │   │  Updates)      │  │
│  └──────────────┘   └────────────────┘  │
│                                         │
│  Security Rules:                        │
│  ├─ Admin read/write access verified    │
│  ├─ Seller access denied                │
│  └─ User access denied                  │
└────────┬────────────────────────────────┘
         │
         ↓
┌──────────────────────────────────────────┐
│  Firebase Storage (Optional)             │
│  - Store product images                  │
│  - Store cert documents                  │
└──────────────────────────────────────────┘

All communication encrypted (HTTPS)
All operations logged in Firebase
```

---

**Diagrams Created:** April 28, 2026
**Format:** Text-based ASCII diagrams
**Status:** Ready for documentation
