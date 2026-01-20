import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/trip_model.dart';

class TripProvider with ChangeNotifier {
  // Название коробки (таблицы) в базе данных
  static const String _boxName = 'trips';

  List<TripModel> _trips = [];

  List<TripModel> get trips => _trips;

  // Загрузка данных при запуске
  Future<void> loadTrips() async {
    final box = await Hive.openBox<TripModel>(_boxName);
    _trips = box.values.toList();
    // Сортируем по дате (новые сверху)
    _trips.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners(); // Сообщаем UI, что данные обновились
  }

  // Добавление новой записи
  Future<void> addTrip(TripModel trip) async {
    final box = await Hive.openBox<TripModel>(_boxName);
    await box.add(trip);
    _trips.add(trip);
    _trips.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  // Удаление записи
  Future<void> deleteTrip(TripModel trip) async {
    await trip.delete();
    _trips.remove(trip);
    notifyListeners();
  }
}
