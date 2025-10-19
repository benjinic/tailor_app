// main.dart

// 導入 Flutter 的核心 UI 元件庫
import 'add_client_screen.dart';
import 'package:flutter/material.dart';

// 導入 Firebase 核心和 Firestore 資料庫的套件
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 導入由 flutterfire configure 自動產生的 Firebase 設定檔
import 'firebase_options.dart';

// 程式的進入點 (main function)
void main() async {
  // 確保在 App 運行前，所有 Flutter 的底層服務都已準備就緒
  WidgetsFlutterBinding.ensureInitialized();
  
  // 根據當前平台（iOS/Android/Web）初始化 Firebase 連接
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 運行我們的 App
  runApp(const AlexisBespokeApp());
}

// 這是 App 的根 Widget
class AlexisBespokeApp extends StatelessWidget {
  const AlexisBespokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 定義您的品牌紫色
    const MaterialColor alexisPurple = MaterialColor(
      0xFF4A244A, // 主要顏色值
      <int, Color>{
          50: Color(0xFFE9E4E9), 100: Color(0xFFC9BFC8),
          200: Color(0xFFA596A4), 300: Color(0xFF816D80),
          400: Color(0xFF664F65), 500: Color(0xFF4A244A), // 必須對應 500
          600: Color(0xFF432043), 700: Color(0xFF3B1C3B),
          800: Color(0xFF331833), 900: Color(0xFF241024),
      },
    );

    return MaterialApp(
      // App 在手機任務管理器中顯示的名稱
      title: 'ALEXIS BESPOKE',
      // 設定 App 的主題
      theme: ThemeData(
        primarySwatch: alexisPurple, // 將 AppBar 等元件的顏色設定為品牌紫
        scaffoldBackgroundColor: Colors.grey[100], // 設定頁面背景為柔和的淺灰色
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // App 的首頁
      home: const ClientListScreen(),
      // 移除右上角的 "Debug" 標籤
      debugShowCheckedModeBanner: false, 
    );
  }
}

// 客戶列表頁面 Widget
class ClientListScreen extends StatefulWidget {
  const ClientListScreen({super.key});

  @override
  State<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends State<ClientListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('客戶列表'),
      ),
      // StreamBuilder 是 Flutter 與 Firebase 搭配的神器
      // 它會持續 "監聽" 資料庫的變化，一旦有新資料或資料被修改，畫面會自動更新
      body: StreamBuilder<QuerySnapshot>(
        // 指定我們要監聽的數據流：'clients' 集合的所有文件
        stream: FirebaseFirestore.instance.collection('clients').snapshots(),
        
        // builder 負責根據數據流的狀態來建立 UI
        builder: (context, snapshot) {
          // 情況一：如果數據還在加載中，顯示一個轉圈的進度條
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 情況二：如果加載過程中發生錯誤，顯示錯誤訊息
          if (snapshot.hasError) {
            return const Center(child: Text('無法載入資料，請稍後再試'));
          }

          // 情況三：如果沒有資料或客戶列表是空的
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('目前沒有客戶資料'));
          }

          // 情況四：成功獲取資料，建立列表
          final clients = snapshot.data!.docs;

          return ListView.builder(
            itemCount: clients.length,
            itemBuilder: (context, index) {
              // 從文件中獲取資料
              final clientData = clients[index].data() as Map<String, dynamic>;
              final clientName = clientData['name'] ?? '姓名未提供'; // 安全地獲取姓名
              final clientPhone = clientData['phone'] ?? '電話未提供'; // 安全地獲取電話

              // Card 讓每個列表項看起來更立體
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(clientPhone),
                  onTap: () {
                    // TODO: 點擊後跳轉到客戶詳情頁
                  },
                ),
              );
            },
          );
        },
      ),
      // 在 main.dart 的 ClientListScreen 中
floatingActionButton: FloatingActionButton(
  onPressed: () {
    // 當按鈕被點擊時，導航到 AddClientScreen 頁面
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