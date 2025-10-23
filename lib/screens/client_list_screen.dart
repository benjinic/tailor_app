// lib/screens/client_list_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 引入我們專案中的其他頁面和模型
import 'package:tailor_app/screens/add_client_screen.dart';
import 'package:tailor_app/screens/client_detail_screen.dart';
import 'package:tailor_app/screens/fabric_selection_screen.dart';
import 'package:tailor_app/models/customer.dart';

class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  // 新增一個狀態來控制是否處於搜尋模式
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getClientStream() {
    Query query = FirebaseFirestore.instance.collection('client');

    if (_searchQuery.isNotEmpty) {
      // 為了支援中文和英文的模糊搜尋，這裡可以簡化查詢
      return query
          .where('name', isGreaterThanOrEqualTo: _searchQuery)
          .where('name', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
          .snapshots();
    } else {
      return query.orderBy('creationDate', descending: true).snapshots();
    }
  }

  // 建立一個正常的 AppBar
  AppBar _buildNormalAppBar() {
    return AppBar(
      title: const Text('客戶列表'),
      actions: [
        // 使用 PopupMenuButton 來整合多個操作
        PopupMenuButton<String>(
          tooltip: '更多選項',
          onSelected: (value) {
            // 根據選擇的值執行對應操作
            if (value == 'search') {
              setState(() {
                _isSearching = true;
              });
            } else if (value == 'fabric') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FabricSelectionScreen()),
              );
            }
          },
          // 建立選單項目
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'search',
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.black87),
                  SizedBox(width: 12),
                  Text('搜尋客戶'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'fabric',
              child: Row(
                children: [
                  Icon(Icons.style_outlined, color: Colors.black87),
                  SizedBox(width: 12),
                  Text('布料管理'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 建立一個搜尋模式的 AppBar (已修正版面佈局)
  AppBar _buildSearchAppBar() {
    return AppBar(
      // 將返回按鈕放在 leading
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          setState(() {
            _isSearching = false;
            _searchController.clear();
          });
        },
      ),
      // 將 title 設為一個 Row，來精確控制佈局
      title: Row(
        children: [
          // 使用 Expanded 讓 TextField 填滿所有剩餘空間
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true, // 進入搜尋模式時自動彈出鍵盤
              decoration: InputDecoration(
                hintText: '搜尋客戶姓名...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          // 清除按鈕現在是 Row 的一部分，有了明確的空間
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 根據 _isSearching 狀態來決定顯示哪一個 AppBar
      appBar: _isSearching ? _buildSearchAppBar() : _buildNormalAppBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getClientStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('無法載入資料，請稍後再試'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(_searchQuery.isEmpty ? '目前沒有客戶資料' : '找不到符合條件的客戶'),
            );
          }

          final clients = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final customer = Customer.fromFirestore(
                clients[index] as DocumentSnapshot<Map<String, dynamic>>,
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(customer.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(customer.phone ?? '無電話'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClientDetailScreen(customer: customer),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddClientScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

