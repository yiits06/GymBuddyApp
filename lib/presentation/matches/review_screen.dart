import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gym_buddy_button.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _ratingScore = 0;
  String _selectedPunctuality = 'Zamanında geldi';
  bool _isMotivated = false;
  bool _wantToWorkAgain = false;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Antrenman Değerlendirmesi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.neonLime,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. ÜST PARTNER KARTI (Can Y. Profile)
                  _buildPartnerHeader(),
                  const SizedBox(height: 28),

                  const Text(
                    'Antrenman nasıldı?',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // 2. GÜVEN SKORU (Yıldız Puanlama)
                  _buildSectionTitle('GÜVEN SKORU', Icons.security),
                  const SizedBox(height: 12),
                  _buildStarRatingBar(),
                  const SizedBox(height: 28),

                  // 3. DAKİKLİK SEÇENEKLERİ (Tasarımdaki Seçmeli Satırlar)
                  _buildSectionTitle('DAKİKLİK', Icons.access_time),
                  const SizedBox(height: 12),
                  _buildPunctualitySelection(),
                  const SizedBox(height: 28),

                  // 4. MOTİVASYON VE TEKRAR ÇALIŞMA SWITCH KARTLARI
                  _buildToggleCard(
                    'MOTİVASYON',
                    'Partner seni motive etti mi?',
                    Icons.bolt,
                    _isMotivated,
                    (val) => setState(() => _isMotivated = val),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    'TEKRAR ÇALIŞMAK İSTERİM',
                    'Bu partnerle tekrar eşleşmek ister misin?',
                    Icons.person_add_alt,
                    _wantToWorkAgain,
                    (val) => setState(() => _wantToWorkAgain = val),
                  ),
                  const SizedBox(height: 28),

                  // 5. NOT EKLEME ALANI (Opsiyonel)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'NOT EKLE (OPSİYONEL)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Antrenman hakkında eklemek istediğin bir şey var mı?',
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 6. PARTNERİ BİLDİR VEYA ENGELLE
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 16,
                    ),
                    label: const Text(
                      'Partneri Bildir veya Engelle',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // DEĞERLENDİRMEYİ GÖNDER BUTONU
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GymBuddyButton(
              text: 'Değerlendirmeyi Gönder ▷',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Değerlendirme başarıyla gönderildi!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Partner Profil Bilgisi Üst Tasarım
  Widget _buildPartnerHeader() {
    return Column(
      children: [
        Stack(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200',
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppTheme.neonLime,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.black, size: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Can Y.',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        const Text(
          'Functional Strength & Crossfit',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  // Yıldız Puanlama Bloğu
  Widget _buildStarRatingBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          final isSelected = index < _ratingScore;
          return IconButton(
            icon: Icon(
              isSelected ? Icons.star : Icons.star_border,
              color: isSelected ? AppTheme.neonLime : Colors.grey.shade700,
              size: 32,
            ),
            onPressed: () => setState(() => _ratingScore = index + 1),
          );
        }),
      ),
    );
  }

  // Dakiklik Satır Seçimleri
  Widget _buildPunctualitySelection() {
    final options = ['Zamanında geldi', 'Biraz gecikti', 'Gelmedi'];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: options.map((opt) {
          final isSelected = _selectedPunctuality == opt;
          return GestureDetector(
            onTap: () => setState(() => _selectedPunctuality = opt),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF2A2A2A)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    opt,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: AppTheme.neonLime,
                      size: 20,
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Switch Açılır Kart Tasarımı
  Widget _buildToggleCard(
    String title,
    String subtitle,
    IconData icon,
    bool currentValue,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.neonLime, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: currentValue,
            onChanged: onChanged,
            activeThumbColor: AppTheme.neonLime,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade500,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}
