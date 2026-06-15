import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';

class GymDetailScreen extends StatefulWidget {
  final Map<String, dynamic> gymData;

  const GymDetailScreen({super.key, required this.gymData});

  @override
  State<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends State<GymDetailScreen> {
  bool _isSpotterAvailable = false;

  // Telefonun harita uygulamasında yol tarifi başlatan sihirli fonksiyon
  Future<void> _launchDirections() async {
    final lat = widget.gymData['lat'];
    final lng = widget.gymData['lng'];
    
    if (lat == null || lng == null) return;

    // Bu link telefonda yüklüyse doğrudan Google Maps veya Apple Maps'i açar
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    
    if (await canLaunchUrl(url)) {
      // Uygulamanın dışına çıkıp haritayı harici olarak açmasını sağlarız
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Harita uygulaması açılamadı.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGymHeaderCard(),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BUGÜNKÜ ODAK',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildFocusItem(
                    Icons.fitness_center,
                    'Bacak & Alt Vücut',
                    '12 kişi çalışıyor',
                  ),
                  const SizedBox(height: 8),
                  _buildFocusItem(
                    Icons.blur_on,
                    'Göğüs & Triceps',
                    '8 kişi çalışıyor',
                  ),
                  const SizedBox(height: 24),
                  _buildSpotterToggleCard(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Şu an kimler antrenmanda?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Text(
                              '• 24 Üye Aktif',
                              style: TextStyle(
                                color: AppTheme.neonLime,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showAllActiveUsersBottomSheet(context),
                        child: const Text(
                          'Tümünü Gör (42)',
                          style: TextStyle(
                            color: AppTheme.neonLime,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildActiveUserRow(),
                  const SizedBox(height: 24),
                  _buildHelpBanner(),
                  const SizedBox(height: 16),
                  _buildLiveStatusList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGymHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.gymData['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.gymData['isPremium'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.neonLime,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PREMIUM',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const Icon(Icons.star, color: AppTheme.neonLime, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.gymData['rating'],
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.gymData['name'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.gymData['distance'],
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CANLI KAPASİTE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Colors.green, size: 8),
                        SizedBox(width: 6),
                        Text(
                          'CANLI',
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      widget.gymData['capacity'],
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.gymData['status'],
                      style: const TextStyle(
                        color: AppTheme.neonLime,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: double.parse(widget.gymData['capacity'].replaceAll('%', '')) / 100,
                  backgroundColor: Colors.grey.shade900,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.neonLime,
                  ),
                  minHeight: 6,
                ),
                const SizedBox(height: 24),
                // YOL TARİFİ BUTONU
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _launchDirections,
                    icon: const Icon(Icons.directions, color: Colors.black),
                    label: const Text(
                      'Yol Tarifi Al',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonLime,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusItem(IconData icon, String title, String count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.neonLime),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(count, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSpotterToggleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yardıma Hazırım (Spotter)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Başkalarına yardım edebileceğini bildir',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: _isSpotterAvailable,
            onChanged: (val) {
              setState(() => _isSpotterAvailable = val);
            },
            activeThumbColor: AppTheme.neonLime,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUserRow() {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildActiveUserAvatar(
            'Sarah M.',
            'https://images.unsplash.com/photo-1548690312-e3b507d8c110?q=80&w=100',
          ),
          _buildActiveUserAvatar(
            'James T.',
            'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?q=80&w=100',
          ),
          _buildActiveUserAvatar(
            'Elena R.',
            'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=100',
          ),
        ],
      ),
    );
  }

  Widget _buildActiveUserAvatar(String name, String img) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Column(
        children: [
          CircleAvatar(radius: 28, backgroundImage: NetworkImage(img)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildHelpBanner() {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.neonLime,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(Icons.gavel, color: Colors.black),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                'Bench için Yardıma İhtiyacım Var',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.black),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveStatusList() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=100',
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Can Şahin',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'BENCH PRESS • Spotter bekliyor',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2A2A15),
            ),
            onPressed: () {},
            child: const Text(
              'YARDIM ET',
              style: TextStyle(
                color: AppTheme.neonLime,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAllActiveUsersBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Salondaki Tüm Aktif Sporcular',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Şu an salonda toplam 42 doğrulanmış kullanıcı antrenman yapıyor.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.neonLime,
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Kapat',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}