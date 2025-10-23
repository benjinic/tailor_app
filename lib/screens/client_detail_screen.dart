// lib/screens/client_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 使用 package 相對路徑
import 'package:tailor_app/models/customer.dart';
import 'package:tailor_app/screens/edit_client_screen.dart';


class ClientDetailScreen extends StatelessWidget {
  final Customer customer;

  const ClientDetailScreen({super.key, required this.customer});

  Future<void> _deleteClient(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認刪除'),
          content: Text('您確定要刪除客戶 "${customer.name}" 嗎？\n此操作無法復原。'),
          actions: <Widget>[
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('刪除'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance.collection('client').doc(customer.id).delete();
        
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('客戶 "${customer.name}" 已成功刪除'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('刪除失敗: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: '編輯客戶',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditClientScreen(customer: customer),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever_outlined),
            tooltip: '刪除客戶',
            onPressed: () => _deleteClient(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildDetailCard(
            '基本資訊',
            [
              _buildDetailRow(Icons.person, '姓名', customer.name),
              _buildDetailRow(Icons.phone, '電話', customer.phone),
              _buildDetailRow(Icons.email, 'Email', customer.email),
            ],
          ),
          const SizedBox(height: 16),
          _buildDetailCard(
            '其他資訊',
            [
              _buildDetailRow(Icons.location_on, '地址', customer.address),
              _buildDetailRow(Icons.note, '備註', customer.notes),
              _buildDetailRow(Icons.calendar_today, '建立日期', 
                '${customer.createdAt.year}/${customer.createdAt.month}/${customer.createdAt.day}'
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String title, List<Widget> details) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24, thickness: 1),
            ...details,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[700], size: 22),
          const SizedBox(width: 16),
          SizedBox(
            width: 80,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
