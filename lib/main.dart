import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme_provider.dart';
import 'theme/app_state_provider.dart';
import 'screens/home_screen.dart';

/// يلتقط أي خطأ يحدث أثناء بدء التشغيل أو أثناء التشغيل ويعرضه على الشاشة
/// بدل ترك المستخدم أمام شاشة فارغة بدون أي تفسير.
String? _fatalError;

void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    FlutterError.onError = (FlutterErrorDetails details) {
      _fatalError = details.exceptionAsString();
      FlutterError.presentError(details);
    };
    runApp(const AliveApp());
  }, (error, stack) {
    _fatalError = error.toString();
    // أعد رسم التطبيق بعرض الخطأ إن كان قد بدأ التشغيل فعلاً
    runApp(_ErrorApp(message: _fatalError!));
  });
}

class _ErrorApp extends StatelessWidget {
  final String message;
  const _ErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حدث خطأ عند بدء التشغيل', style: TextStyle(color: Colors.orange, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AliveApp extends StatefulWidget {
  const AliveApp({super.key});

  @override
  State<AliveApp> createState() => _AliveAppState();
}

class _AliveAppState extends State<AliveApp> {
  final themeProvider = AppThemeProvider();
  final appStateProvider = AppStateProvider();
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      await themeProvider.load();
      await appStateProvider.refresh();
      if (mounted) setState(() => _ready = true);
    } catch (e, st) {
      debugPrint('Bootstrap error: $e\n$st');
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return _ErrorApp(message: _error!);
    }
    if (!_ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Color(0xFFFF6B00))),
        ),
      );
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: appStateProvider),
      ],
      child: Consumer<AppThemeProvider>(
        builder: (context, theme, _) {
          return MaterialApp(
            title: 'Alive',
            debugShowCheckedModeBanner: false,
            themeMode: theme.themeMode,
            theme: theme.lightTheme,
            darkTheme: theme.darkTheme,
            locale: const Locale('ar'),
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.rtl,
                child: child!,
              );
            },
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
