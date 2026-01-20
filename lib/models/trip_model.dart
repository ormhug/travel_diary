import 'package:hive/hive.dart';

// Это имя файла, который будет сгенерирован автоматически
part 'trip_model.g.dart';

@HiveType(typeId: 0)
class TripModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String imagePath; // Путь к фото на телефоне

  @HiveField(4)
  final DateTime date;

  @HiveField(5)
  final double? latitude; // Координаты могут быть null, если GPS выключен

  @HiveField(6)
  final double? longitude;

  TripModel({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.date,
    this.latitude,
    this.longitude,
  });
}
