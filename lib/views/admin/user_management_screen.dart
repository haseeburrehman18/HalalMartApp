// lib/views/admin/user_management_screen.dart
// Screen 20 of 20

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/status_chip.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _appliedInitialRouteFilter = false;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    // Initialize user management on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().initializeUserManagement();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_appliedInitialRouteFilter) return;
    _appliedInitialRouteFilter = true;

    final role = ModalRoute.of(context)?.settings.arguments as String?;
    if (role == AppConstants.roleUser) {
      _tab.index = 1;
    } else if (role == AppConstants.roleSeller) {
      _tab.index = 2;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || role == null) return;
      context.read<AdminProvider>().setUserRoleFilter(role);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'All'), Tab(text: 'Customers'), Tab(text: 'Sellers')],
          onTap: (index) {
            final adminProvider = context.read<AdminProvider>();
            if (index == 0) {
              adminProvider.setUserRoleFilter('all');
            } else if (index == 1) {
              adminProvider.setUserRoleFilter(AppConstants.roleUser);
            } else {
              adminProvider.setUserRoleFilter(AppConstants.roleSeller);
            }
          },
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  onChanged: (query) => adminProvider.searchUsers(query),
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _UserList(users: adminProvider.filteredUsers),
                    _UserList(users: adminProvider.filteredUsers),
                    _UserList(users: adminProvider.filteredUsers),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserList extends StatefulWidget {
  final List<UserModel> users;
  const _UserList({required this.users});

  @override
  State<_UserList> createState() => _UserListState();
}

class _UserListState extends State<_UserList> {
  String? _processingUserId;

  @override
  Widget build(BuildContext context) {
    if (widget.users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 48, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('No users found', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: widget.users.length,
      itemBuilder: (_, index) {
        final user = widget.users[index];
        final isProcessing = _processingUserId == user.uid;
        final initial = user.name.trim().isNotEmpty
            ? user.name.trim()[0].toUpperCase()
            : '?';

        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: user.role == AppConstants.roleSeller ? AppColors.accentLight : AppColors.primaryLight,
              child: Text(
                initial,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: user.role == AppConstants.roleSeller ? AppColors.accent : AppColors.primary,
                ),
              ),
            ),
            title: Text(
              user.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    StatusChip(status: user.role),
                    Text(
                      'Joined: ${user.createdAt.toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                    ),
                    if (!user.isEnabled)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DISABLED',
                          style: TextStyle(fontSize: 9, color: AppColors.error, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            isThreeLine: true,
            trailing: isProcessing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: user.isEnabled,
                    onChanged: (newValue) async {
                      setState(() => _processingUserId = user.uid);
                      try {
                        await context.read<AdminProvider>().toggleUserStatus(user.uid, newValue);
                        if (!mounted) return;
                        final message = newValue ? 'User enabled' : 'User disabled';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(message), backgroundColor: AppColors.primary),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
                        );
                      } finally {
                        if (mounted) setState(() => _processingUserId = null);
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
          ),
        );
      },
    );
  }
}
