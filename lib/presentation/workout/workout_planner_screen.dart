import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_provider.dart';
import 'workout_detail_screen.dart';

class WorkoutPlannerScreen extends ConsumerWidget {
  const WorkoutPlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(workoutListProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Antrenman Planlayıcı",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: workoutsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.lime)),
        error: (err, _) => Center(
          child: Text('Hata: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (workouts) {
          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final w = workouts[index];
              return Card(
                color: const Color(0xFF1E1E1E),
                child: ListTile(
                  title: Text(
                    w['title'],
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "${w['day_of_week']} • ${w['duration']}dk • ${w['weight']}kg",
                    style: const TextStyle(color: Colors.lime),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailScreen(
                        workoutId: w['id'],
                        workoutTitle: w['title'],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lime,
        onPressed: () => showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1E1E1E),
          builder: (context) => const AddWorkoutForm(),
        ),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class AddWorkoutForm extends ConsumerStatefulWidget {
  const AddWorkoutForm({super.key});
  @override
  ConsumerState<AddWorkoutForm> createState() => _AddWorkoutFormState();
}

class _AddWorkoutFormState extends ConsumerState<AddWorkoutForm> {
  final _titleController = TextEditingController();
  final _durationController = TextEditingController();
  final _weightController = TextEditingController();
  String _selectedDay = 'Pazartesi';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Antrenman Adı',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Süre (dk)'),
          ),
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(hintText: 'Toplam Ağırlık (kg)'),
          ),
          DropdownButton<String>(
            value: _selectedDay,
            dropdownColor: const Color(0xFF1E1E1E),
            items:
                [
                      'Pazartesi',
                      'Salı',
                      'Çarşamba',
                      'Perşembe',
                      'Cuma',
                      'Cumartesi',
                      'Pazar',
                    ]
                    .map(
                      (d) => DropdownMenuItem(
                        value: d,
                        child: Text(
                          d,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (val) => setState(() => _selectedDay = val!),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lime),
            onPressed: () async {
              await ref
                  .read(workoutRepositoryProvider)
                  .addWorkout(
                    title: _titleController.text,
                    day: _selectedDay,
                    duration: int.tryParse(_durationController.text) ?? 0,
                    weight: int.tryParse(_weightController.text) ?? 0,
                  );
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Kaydet', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
