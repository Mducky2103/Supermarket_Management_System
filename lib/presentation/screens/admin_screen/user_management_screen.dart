import 'package:flutter/material.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../widgets/user_form.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserRepository _userRepo = UserRepository();

  void _refreshUsers() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Quản lý nhân viên")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(context),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _userRepo.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(child: Text(user['full_name'][0])),
                title: Text(user['full_name']),
                subtitle: Text("Role: ${user['role']} | User: ${user['username']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showUserForm(context, user: user)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(user['user_id'])),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
  void _showUserForm(BuildContext context, {Map<String, dynamic>? user}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => UserForm(
        user: user,
        onSave: (data) async {
          if (user == null) {
            await _userRepo.createUser(data);
          } else {
            await _userRepo.updateUser(user['user_id'], data);
          }
          Navigator.pop(ctx); // Đóng form
          _refreshUsers();    // Load lại danh sách
        },
      ),
    );
  }
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: const Text("Bạn có chắc muốn xóa nhân viên này?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(onPressed: () async {
            await _userRepo.deleteUser(id);
            Navigator.pop(ctx);
            _refreshUsers();
          }, child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}