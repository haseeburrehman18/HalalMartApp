// lib/views/admin/user_management_screen.dart
// Screen 20 of 20

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/status_chip.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  String _search = '';

  final List<Map<String, dynamic>> _users = [
    {'name': 'Ahmed Ali', 'email': 'ahmed@email.com', 'role': AppConstants.roleUser, 'joined': '2023-12-01', 'active': true},
    {'name': 'Fatima Hassan', 'email': 'fatima@email.com', 'role': AppConstants.roleUser, 'joined': '2023-11-22', 'active': true},
    {'name': 'Omar Sheikh', 'email': 'omar@email.com', 'role': AppConstants.roleUser, 'joined': '2024-01-05', 'active': false},
    {'name': 'Al-Barakah Store', 'email': 'seller@albarakah.com', 'role': AppConstants.roleSeller, 'joined': '2023-10-15', 'active': true},
    {'name': 'Salam Foods', 'email': 'info@salamfoods.com', 'role': AppConstants.roleSeller, 'joined': '2023-09-30', 'active': true},
    {'name': 'Desert Delights', 'email': 'contact@desertd.com', 'role': AppConstants.roleSeller, 'joined': '2024-01-02', 'active': false},
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  List<Map<String, dynamic>> _filtered(String role) {
    var list = role == 'all' ? _users : _users.where((u) => u['role'] == role).toList();
    if (_search.isNotEmpty) {
      list = list.where((u) =>
        (u['name'] as String).toLowerCase().contains(_search.toLowerCase()) ||
        (u['email'] as String).toLowerCase().contains(_search.toLowerCase())).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        bottom: TabBar(
          controller: _tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [Tab(text: 'All'), Tab(text: 'Customers'), Tab(text: 'Sellers')],
        ),
      ),
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _UserList(users: _filtered('all'), onToggle: (i, v) => setState(() => _users[i]['active'] = v)),
                _UserList(users: _filtered(AppConstants.roleUser), onToggle: (i, v) => setState(() => _users[i]['active'] = v)),
                _UserList(users: _filtered(AppConstants.roleSeller), onToggle: (i, v) => setState(() => _users[i]['active'] = v)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  final List<Map<String, dynamic>> users;
  final Function(int, bool) onToggle;
  const _UserList({required this.users, required this.onToggle});

  @override
  Widget build(BuildContext context) => users.isEmpty
      ? const Center(child: Text('No users found', style: TextStyle(color: AppColors.textSecondary)))
      : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: users.length,
          itemBuilder: (_, i) {
            final u = users[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: u['role'] == AppConstants.roleSeller ? AppColors.accentLight : AppColors.primaryLight,
                  child: Text((u['name'] as String)[0].toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold,
                          color: u['role'] == AppConstants.roleSeller ? AppColors.accent : AppColors.primary)),
                ),
                title: Text(u['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(u['email'] as String, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 3),
                  Row(children: [
                    StatusChip(status: u['role'] as String),
                    const SizedBox(width: 6),
                    Text('Since ${u['joined']}', style: const TextStyle(fontSize: 10, color: AppColors.textLight)),
                  ]),
                ]),
                isThreeLine: true,
                trailing: Switch(
                  value: u['active'] as bool,
                  onChanged: (v) => onToggle(i, v),
                  activeColor: AppColors.primary,
                ),
              ),
            );
          },
        );
}
