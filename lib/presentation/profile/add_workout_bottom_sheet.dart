import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/workout_provider.dart';

class AddWorkoutBottomSheet extends ConsumerStatefulWidget {
  const AddWorkoutBottomSheet({super.key});

  @override
  ConsumerState<AddWorkoutBottomSheet> createState() =>
      _AddWorkoutBottomSheetState();
}

class _AddWorkoutBottomSheetState extends ConsumerState<AddWorkoutBottomSheet> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _detailsController = TextEditingController();
  bool _isLoading = false;

  final Color neonLime = const Color(0xFFD4FF00);
  final Color darkSurface = const Color(0xFF161616);
  final Color background = const Color(0xFF0F0F10);

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    // Başlık boşsa kaydetme
    if (_titleController.text.trim().isEmpty) return;

    FocusScope.of(context).unfocus(); // Klavyeyi kapat
    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('Kullanıcı bulunamadı!');

      final rawDuration = _subtitleController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      final rawWeight = _detailsController.text.replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );

      await Supabase.instance.client.from('workouts').insert({
        'user_id': userId,
        'title': _titleController.text,
        'duration': int.tryParse(rawDuration) ?? 0,
        'weight': int.tryParse(rawWeight) ?? 0,
        'day_of_week': 'Pazartesi',
      });

      // Riverpod'u tetikle ki ana ekran anında yenilensin!
      ref.invalidate(recentWorkoutsProvider);

      if (mounted) {
        Navigator.pop(context); // İşlem bitince pop-up'ı kapat
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Klavye açıldığında pop-up'ın yukarı kayması için viewInsets alıyoruz
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: bottomInset + 20,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Yeni Antrenman',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _titleController,
              hint: 'Antrenman Adı (Örn: İtme Günü)',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _subtitleController,
              hint: 'Yer & Süre (Örn: MacFit • 60 Dk)',
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _detailsController,
              hint: 'Detaylar (Örn: 100kg Bench Press)',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonLime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Antrenmanı Ekle',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neonLime),
        ),
      ),
    );
  }
}
