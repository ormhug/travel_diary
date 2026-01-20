import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/trip_provider.dart';
import 'add_trip_screen.dart';
import '../models/trip_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _confirmDelete(BuildContext context, TripModel trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Закрыть окно
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Удаляем через Provider
              Provider.of<TripProvider>(
                context,
                listen: false,
              ).deleteTrip(trip);
              Navigator.of(ctx).pop(); // Закрыть окно

              // Показываем сообщение снизу
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Trip deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Travel Diary')),
      // Consumer следит за изменениями в TripProvider
      body: Consumer<TripProvider>(
        builder: (context, tripProvider, child) {
          final trips = tripProvider.trips;

          // Если записей нет, показываем сообщение
          if (trips.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.travel_explore,
                    size: 100,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No trips yet!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const Text(
                    'Tap the + button to add your first adventure.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Если записи есть, показываем список
          return ListView.builder(
            itemCount: trips.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final trip = trips[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        if (trip.imagePath.isNotEmpty)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.file(
                              File(trip.imagePath),
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        // Кнопка удаления (справа сверху)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.8),
                            child: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDelete(context, trip),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Фотография места
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trip.title,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),

                          // Дата и Локация в одну строку
                          Row(
                            children: [
                              Text(
                                "${trip.date.day}/${trip.date.month}/${trip.date.year}",
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const Spacer(),
                              // Если есть координаты - показываем иконку
                              if (trip.latitude != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.blue[300],
                                    ),
                                    Text(
                                      " ${trip.latitude!.toStringAsFixed(2)}, ${trip.longitude!.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: Colors.blue[300],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),
                          Text(
                            trip.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      // Кнопка добавления новой записи
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Навигация на экран добавления
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddTripScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Trip'),
      ),
    );
  }
}
