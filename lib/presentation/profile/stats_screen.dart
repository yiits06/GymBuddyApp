import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

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
          'İSTATİSTİKLER VE BAŞARILAR',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.neonLime,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ÜST İKİLİ KART (Güven Skoru & Devamlılık Serisi)
            Row(
              children: [
                Expanded(
                  child: _buildTopSummaryCard(
                    'PARTNER GÜVEN\nSKORU',
                    '4.9 /5',
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          color: AppTheme.neonLime,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTopSummaryCard(
                    'DEVAMLILIK SERİSİ',
                    '12 Hafta',
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.local_fire_department,
                          color: Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Yanıyor!',
                          style: TextStyle(
                            color: Colors.orange.shade400,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. HAFTALIK AKTİVİTE GRAFİĞİ (Tasarımdaki Özel Dikey Sütun Yapısı)
            _buildWeeklyActivityGraph(),

            const SizedBox(height: 28),

            // 3. BAŞARI ROZETLERİ (Kilitli ve Açık Rozetler Grid Yapısı)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Başarı Rozetleri',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Tümünü Gör',
                    style: TextStyle(color: AppTheme.neonLime, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildBadgesGrid(),

            const SizedBox(height: 28),

            // 4. PARTNER ÖZETİ TABLOSU
            const Text(
              'Partner Özeti',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPartnerSummaryCard(),
          ],
        ),
      ),
    );
  }

  // Üst Küçük Özet Kartları
  Widget _buildTopSummaryCard(String title, String value, Widget footer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          footer,
        ],
      ),
    );
  }

  // Tasarımdaki Dikey Bar Grafik Kartı
  Widget _buildWeeklyActivityGraph() {
    final List<Map<String, dynamic>> daysData = [
      {'day': 'Pzt', 'value': 0.8},
      {'day': 'Sal', 'value': 0.3},
      {'day': 'Çar', 'value': 0.0},
      {'day': 'Per', 'value': 0.95},
      {'day': 'Cum', 'value': 0.7},
      {'day': 'Cmt', 'value': 0.0},
      {'day': 'Paz', 'value': 0.2},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Haftalık Aktivite',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                'Bu Hafta',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: daysData.map((d) {
              final val = d['value'] as double;
              return Column(
                children: [
                  Container(
                    height: 120,
                    width: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(
                      heightFactor: val,
                      child: Container(
                        decoration: BoxDecoration(
                          color: val > 0.5
                              ? AppTheme.neonLime
                              : AppTheme.neonLime.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    d['day'] as String,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Başarı Rozetleri Grid Sistemi (3 Açık, 3 Kilitli/Flu Yapı)
  Widget _buildBadgesGrid() {
    final badges = [
      {
        'name': 'Motivasyon\nKaynağı',
        'icon': Icons.favorite_border,
        'unlocked': true,
      },
      {'name': 'Her Zaman\nDakik', 'icon': Icons.access_time, 'unlocked': true},
      {'name': 'Güç Küpü', 'icon': Icons.layers, 'unlocked': true},
      {
        'name': 'Sosyal\nKelebek',
        'icon': Icons.people_outline,
        'unlocked': false,
      },
      {'name': 'Ağır Sıklet', 'icon': Icons.fitness_center, 'unlocked': false},
      {
        'name': 'Gece Kuşu',
        'icon': Icons.dark_mode_outlined,
        'unlocked': false,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.9,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final b = badges[index];
        final isUnlocked = b['unlocked'] as bool;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Opacity(
            opacity: isUnlocked ? 1.0 : 0.25, // Kilitli rozet efekti
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? const Color(0xFF2A2A15)
                        : const Color(0xFF222222),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnlocked
                        ? Icons.workspace_premium
                        : b['icon'] as IconData,
                    color: isUnlocked ? AppTheme.neonLime : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  b['name'] as String,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: isUnlocked ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Alt Kısım Partner Özet Kartı
  Widget _buildPartnerSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildPartnerSummaryRow(
            Icons.people_outline,
            'Toplam Partnerli\nAntrenman',
            'Tüm zamanlar',
            '124',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Divider(color: Color(0xFF2A2A2A)),
          ),
          _buildPartnerSummaryRow(
            Icons.person_add_alt,
            'Bu Ay Yeni Bağlantılar',
            'Son 30 gün',
            '8 ↗',
            isTrend: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerSummaryRow(
    IconData icon,
    String title,
    String subtitle,
    String value, {
    bool isTrend = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.neonLime, size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isTrend ? AppTheme.neonLime : Colors.white,
          ),
        ),
      ],
    );
  }
}
