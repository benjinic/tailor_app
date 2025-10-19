// lib/add_client_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddClientScreen extends StatefulWidget {
  const AddClientScreen({super.key});

  @override
  State<AddClientScreen> createState() => _AddClientScreenState();
}

class _AddClientScreenState extends State<AddClientScreen> {
  // 建立控制器來獲取輸入框中的文字
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // 用於控制儲存按鈕的狀態，防止重複點擊
  bool _isLoading = false;

  // 異步函式：儲存客戶資料到 Firebase
  Future<void> _saveClient() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    // 簡單的驗證：確保姓名不是空的
    if (name.isEmpty) {
      // 顯示一個短暫的提示訊息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('請輸入客戶姓名'),
          backgroundColor: Colors.red,
        ),
      );
      return; // 中斷函式
    }

    // 開始儲存，設定為載入中狀態
    setState(() {
      _isLoading = true;
    });

    try {
      // 在 'clients' 集合中新增一筆文件
      await FirebaseFirestore.instance.collection('clients').add({
        'name': name,
        'phone': phone,
        'creationDate': Timestamp.now(), // 記錄建立時間
      });

      // 如果儲存成功，自動關閉此頁面，返回列表頁
      if (mounted) {
        Navigator.of(context).pop();
      }

    } catch (e) {
      // 如果儲存過程中出錯，顯示錯誤訊息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('儲存失敗: $e')),
        );
      }
    } finally {
      // 無論成功或失敗，最後都結束載入中狀態
       if (mounted) {
         setState(() {
            _isLoading = false;
         });
       }
    }
  }

  @override
  void dispose() {
    // 頁面銷毀時，釋放控制器資源，避免內存洩漏
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新增客戶'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '客戶姓名 *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: '電話號碼',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            // 根據 _isLoading 狀態顯示不同的按鈕內容
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveClient, // 載入中則禁用按鈕
              icon: _isLoading 
                  ? Container( // 顯示一個小小的進度圈
                      width: 24, 
                      height: 24, 
                      padding: const EdgeInsets.all(2.0),
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                    )
                  : const Icon(Icons.save),
              label: Text(_isLoading ? '儲存中...' : '儲存客戶'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16)
              ),
            ),
          ],
        ),
      ),
    );
  }
}