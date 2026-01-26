import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/messages_provider.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng MultiProvider để có thể thêm nhiều providers sau này
    return MultiProvider(
      providers: [
        // Đăng ký CounterProvider
        ChangeNotifierProvider(create: (_) => MessagesProvider()),
        // Có thể thêm các providers khác ở đây
      ],
      child: MaterialApp(
        title: 'Flutter Provider Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
