import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart'; // ← 1. Import Firebase Core

// Import cấu hình Firebase tự động từ bước trước
import 'firebase_options.dart'; // ← 2. Import file bạn vừa tạo thành công

// Import các Providers của bạn
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/product_provider.dart';
import 'providers/order_provider.dart';
import 'providers/wishlist_provider.dart';
import 'package:shoe_store_app/providers/chat_provider.dart';

// Import màn hình
import 'screens/login_screen.dart';

void main() async {
  // 3. Phải có dòng này để đảm bảo Flutter đã sẵn sàng trước khi gọi Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 4. Khởi tạo Firebase với cấu hình dành riêng cho project của bạn
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // 5. Thêm dấu ..fetchProducts() để app tự động lấy dữ liệu ngay khi mở
        ChangeNotifierProvider(create: (_) => ProductProvider()..fetchProducts()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'SportShoe Store',
        theme: ThemeData(
          primarySwatch: Colors.red,
          useMaterial3: true,
          fontFamily: GoogleFonts.poppins().fontFamily,
          // Đảm bảo các nút bấm và AppBar có màu đỏ chủ đạo theo yêu cầu của bạn
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        ),
        // === CẤU HÌNH TIẾNG VIỆT ===
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('vi', 'VN'),
          Locale('en', 'US'),
        ],
        locale: const Locale('vi', 'VN'),
        // =============================
        home: const LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}