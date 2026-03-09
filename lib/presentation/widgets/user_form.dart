import 'package:flutter/material.dart';

class UserForm extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Function(Map<String, dynamic> data) onSave;

  const UserForm({super.key, this.user, required this.onSave});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _userCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _passCtrl;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user?['full_name'] ?? '');
    _userCtrl = TextEditingController(text: widget.user?['username'] ?? '');
    _emailCtrl = TextEditingController(text: widget.user?['email'] ?? '');
    _passCtrl = TextEditingController();
    _selectedRole = widget.user?['role'] ?? 'warehouse_staff';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20, right: 20, top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.user == null ? "Thêm nhân viên mới" : "Cập nhật nhân viên",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: "Họ tên", prefixIcon: Icon(Icons.badge)),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                validator: (v) => !v!.contains('@') ? "Email không hợp lệ" : null,
              ),
              TextFormField(
                controller: _userCtrl,
                decoration: const InputDecoration(labelText: "Username", prefixIcon: Icon(Icons.person)),
                validator: (v) => v!.isEmpty ? "Không được để trống" : null,
              ),
              // Chỉ hiện ô Password khi tạo mới
              if (widget.user == null)
                TextFormField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? "Tối thiểu 6 ký tự" : null,
                ),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text("Admin")),
                  DropdownMenuItem(value: 'warehouse_staff', child: Text("Warehouse Staff")),
                  DropdownMenuItem(value: 'manager', child: Text("Manager")),
                  DropdownMenuItem(value: 'cashier', child: Text("Cashier"))
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
                decoration: const InputDecoration(labelText: "Vai trò"),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final data = {
                        'full_name': _nameCtrl.text,
                        'username': _userCtrl.text,
                        'email': _emailCtrl.text,
                        'role': _selectedRole,
                        'is_active': 1,
                      };
                      if (widget.user == null) data['password'] = _passCtrl.text;
                      widget.onSave(data);
                    }
                  },
                  child: Text(widget.user == null ? "TẠO MỚI" : "CẬP NHẬT"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}