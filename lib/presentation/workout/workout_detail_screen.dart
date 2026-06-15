import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/workout_provider.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final String workoutId;
  final String workoutTitle;

  const WorkoutDetailScreen({
    super.key,
    required this.workoutId,
    required this.workoutTitle,
  });

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  // Egzersizleri liste olarak tutuyoruz
  List<Map<String, dynamic>> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    final data = await ref
        .read(workoutRepositoryProvider)
        .getExercises(widget.workoutId);
    if (mounted) {
      setState(() {
        _exercises = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          widget.workoutTitle,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.lime))
          : ListView.builder(
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                final ex = _exercises[index];
                return Card(
                  color: const Color(0xFF1E1E1E),
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ListTile(
                    title: Text(
                      ex['exercise_name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      "${ex['sets']} Set x ${ex['reps']} Tekrar",
                      style: const TextStyle(color: Colors.lime),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lime,
        onPressed: () => _showAddExerciseDialog(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    final nameController = TextEditingController();
    final setsController = TextEditingController();
    final repsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          "Yeni Egzersiz",
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Egzersiz Adı",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              controller: setsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Set Sayısı",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintStyle: TextStyle(color: Colors.grey),
                hintText: "Tekrar Sayısı",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.lime),
            onPressed: () async {
              await ref
                  .read(workoutRepositoryProvider)
                  .addExercise(
                    workoutId: widget.workoutId,
                    name: nameController.text,
                    sets: int.tryParse(setsController.text) ?? 0,
                    reps: int.tryParse(repsController.text) ?? 0,
                  );
              if (!context.mounted) return;
              _loadExercises(); // Listeyi güncelle
              Navigator.pop(context);
            },
            child: const Text("Ekle", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
