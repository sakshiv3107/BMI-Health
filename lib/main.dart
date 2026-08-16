import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assignment/firebase_options.dart';
import 'package:assignment/app_router.dart';
import 'package:assignment/core/theme/app_colors.dart';
import 'package:assignment/core/theme/app_theme.dart';
import 'package:assignment/core/theme/theme_provider.dart';
import 'package:assignment/features/profile/models/user_profile.dart';
import 'package:assignment/features/history/models/weight_entry.dart';
import 'package:assignment/core/widgets/initialization_skeleton.dart';

final appInitializationProvider = FutureProvider<void>((ref) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Hive.initFlutter();
  
  // Register generated Hive adapters
  try {
    Hive.registerAdapter(UserProfileAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(WeightEntryAdapter());
  } catch (_) {}

  // Open Hive boxes
  await Hive.openBox<UserProfile>('profiles');
  await Hive.openBox<WeightEntry>('weight_entries');
  await Hive.openBox('settings');
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final init = ref.watch(appInitializationProvider);

    return init.when(
      data: (_) {
        final goRouter = ref.watch(goRouterProvider);
        final themeMode = ref.watch(themeModeProvider);

        // Synchronize dynamic theme state back to AppColors
        AppColors.isDarkMode = themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);

        return MaterialApp.router(
          title: 'BMI Health Tracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          routerConfig: goRouter,
        );
      },
      loading: () => const MaterialApp(
        title: 'BMI Health Tracker',
        debugShowCheckedModeBanner: false,
        home: InitializationSkeletonScreen(),
      ),
      error: (err, stack) => MaterialApp(
        title: 'BMI Health Tracker',
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Text('Initialization Error: $err'),
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

