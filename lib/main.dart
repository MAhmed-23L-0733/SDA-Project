import 'package:flutter/material.dart';
import 'package:flutter_template/views/widget_tree.dart';
import 'package:flutter_template/data/notifiers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const suapbaseURL = 'https://mprnfqhpcbvatuvkgttq.supabase.co';
const supabaseAnonKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1wcm5mcWhwY2J2YXR1dmtndHRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMyMzEyMTUsImV4cCI6MjA3ODgwNzIxNX0.eF_uVn0rEtOgvuTkrHG0PLv9AaWged3lf8kT0T-K09g";

//my name
void main() async {
  // Must be called before any calls to native code or platform channels (like Supabase)
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: suapbaseURL, anonKey: supabaseAnonKey);

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDarkMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF7C4DFF),
              secondary: const Color(0xFF9575CD),
              surface: Colors.white,
              background: const Color(0xFFF5F5F5),
              error: Colors.red,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5F5F5),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              elevation: 0,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
              primary: const Color(0xFF9575CD),
              secondary: const Color(0xFFB39DDB),
              surface: const Color(0xFF1E1E1E),
              background: const Color(0xFF121212),
              error: Colors.redAccent,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            cardTheme: CardThemeData(
              color: const Color(0xFF1E1E1E),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: const Color(0xFF1E1E1E),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return WidgetTree();
  }
}
