// lib/edit_client_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart'; // 引入我們的 Customer 模型

class EditClientScreen extends StatefulWidget {
  // 這個頁面需要接收一個 Customer 物件，才能知道要編輯誰
  final Customer customer;

  const EditClientScreen({super.key, required this.customer});

  @override
  State<EditClientScreen> createState() => _EditClientScreenState();
}

class _EditClientScreenState extends State<EditClientScreen> {
  // 同樣，為每個輸入框建立控制器
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  // initState 是 Widget 生命週期的第一步，在這裡我們預先填入資料
  @override
  void initState() {
    super.initState();
    // 將傳入的 customer 物件的資料，設定為輸入框的初始值
    _nameController.text = widget.customer.name;
    _phoneController.text = widget.customer.phone ?? '';
    _emailController.text = widget.customer.email ?? '';
    _addressController.text = widget.customer.address ?? '';
    _notesController.text = widget.customer.notes ?? '';
  }

  // 更新客戶資料到 Firestore 的函式
  Future<void> _updateClient() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isSaving = true; });

      try {
        // 組合要更新的資料
        final updatedData = {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'address': _addressController.text.trim(),
          'notes': _notesController.text.trim(),
          // 我們通常不需要更新 creationDate
        };

        // 使用 .doc(widget.customer.id).update() 來更新指定的客戶文件
        await FirebaseFirestore.instance
            .collection('client')
            .doc(widget.customer.id)
            .update(updatedData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('客戶資料已成功更新！'), backgroundColor: Colors.green),
          );
          // 更新成功後，返回上一頁 (客戶詳情頁)
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('更新失敗: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isSaving = false; });
        }
      }
    }
  }

  // 記得也要 dispose 控制器
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('編輯客戶資料'),
      ),
      // 表單的 UI 結構與新增頁面完全相同
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '姓名 *', border: OutlineInputBorder()),
              validator: (value) {
                if (value == null || value.trim().isEmpty) { return '請輸入客戶姓名'; }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: '電話', border: OutlineInputBorder()),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            // ... 其他輸入框 ...
            ElevatedButton(
              onPressed: _isSaving ? null : _updateClient,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('儲存更新'),
            ),
          ],
        ),
      ),
    );
  }
}
