import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/trip_model.dart';
import 'providers/trip_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  // Обязательно для инициализации асинхронных функций до запуска UI
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация локальной базы данных (Local Persistent Storage)
  await Hive.initFlutter();

  // Регистрация адаптера, который сгенерировали
  Hive.registerAdapter(TripModelAdapter());

  // Открытие "коробки" (таблицы) с данными
  await Hive.openBox<TripModel>('trips');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Подключаем Provider, чтобы данные были доступны во всем приложении
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TripProvider()..loadTrips()),
      ],
      child: MaterialApp(
        title: 'Travel Diary',
        theme: ThemeData(
          // Используем Material Design 3 (современно и красиво)
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2196F3), // Синий цвет темы
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        // Главный экран приложения
        home: const HomeScreen(),
      ),
    );
  }
}
