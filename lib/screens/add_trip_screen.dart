import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Для камеры
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart'; // Для генерации ID
import '../models/trip_model.dart';
import '../providers/trip_provider.dart';
import 'package:geolocator/geolocator.dart'; // Импорт GPS

class AddTripScreen extends StatefulWidget {
  const AddTripScreen({super.key});

  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  File? _selectedImage; // Тут будет храниться фото

  // Переменные для хранения координат
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false; // Чтобы показывать индикатор загрузки

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);

    bool serviceEnabled;
    LocationPermission permission;

    // Проверяем, включен ли GPS на телефоне
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GPS is disabled. Please turn it on.')),
      );
      setState(() => _isGettingLocation = false);
      return;
    }

    // Проверяем разрешения
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        setState(() => _isGettingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permissions are permanently denied'),
        ),
      );
      setState(() => _isGettingLocation = false);
      return;
    }

    // Получаем координаты
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _isGettingLocation = false;
    });
  }

  // Функция выбора фото
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    // Источник: Camera. Можно поменять на gallery
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600, // Оптимизация размера
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Функция сохранения
  void _saveTrip() {
    if (_titleController.text.isEmpty || _selectedImage == null) {
      // Простая валидация
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a title and a photo!')),
      );
      return;
    }

    // Сохраняем через Provider
    Provider.of<TripProvider>(context, listen: false).addTrip(
      TripModel(
        id: DateTime.now().toString(), // Простой ID
        title: _titleController.text,
        description: _descController.text,
        imagePath: _selectedImage!.path,
        date: DateTime.now(),
        latitude: _latitude, //сохранение полученных координат
        longitude: _longitude,
      ),
    );

    // Возвращаемся назад
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Adventure')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Where did you go?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // Фото
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: _selectedImage != null
                  ? Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Take a Photo'),
                    ),
            ),
            const SizedBox(height: 20),

            // --- Кнопка GPS ---
            if (_latitude != null)
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.green[50],
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    const SizedBox(width: 10),
                    Text(
                      "Lat: ${_latitude!.toStringAsFixed(4)}, Lng: ${_longitude!.toStringAsFixed(4)}",
                    ),
                  ],
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: _isGettingLocation ? null : _getCurrentLocation,
                icon: _isGettingLocation
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.location_on),
                label: Text(
                  _isGettingLocation
                      ? 'Getting location...'
                      : 'Add Current Location',
                ),
              ),

            // ------------------
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _saveTrip,
              icon: const Icon(Icons.save),
              label: const Text('Save Memory'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
