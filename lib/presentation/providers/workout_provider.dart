import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';

// 1. ESKİDEN KALAN (Profile ekranın için gerekli)
final recentWorkoutsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((
  ref,
) async {
  ref.watch(authProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];

  return await Supabase.instance.client
      .from('workouts')
      .select('*')
      .eq('user_id', userId)
      .order('created_at', ascending: false)
      .limit(3);
});

// 2. YENİ (Anlık liste için)
final workoutListProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) {
  ref.watch(authProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  return Supabase.instance.client
      .from('workouts')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId!)
      .order('created_at', ascending: false);
});

// 3. REPOSITORY (Ekleme ve detay işlemleri için)
final workoutRepositoryProvider = Provider((ref) => WorkoutRepository());

class WorkoutRepository {
  final _supabase = Supabase.instance.client;

  Future<void> addWorkout({
    required String title,
    required String day,
    required int duration,
    required int weight,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    await _supabase.from('workouts').insert({
      'user_id': userId,
      'title': title,
      'day_of_week': day,
      'duration': duration,
      'weight': weight,
    });
  }

  Future<List<Map<String, dynamic>>> getExercises(String workoutId) async {
    return await _supabase
        .from('workout_exercises')
        .select('*')
        .eq('workout_id', workoutId);
  }

  Future<void> addExercise({
    required String workoutId,
    required String name,
    required int sets,
    required int reps,
  }) async {
    await _supabase.from('workout_exercises').insert({
      'workout_id': workoutId,
      'exercise_name': name,
      'sets': sets,
      'reps': reps,
    });
  }
}
