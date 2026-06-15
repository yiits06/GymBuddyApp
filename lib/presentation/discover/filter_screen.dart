import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gym_buddy_button.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Canlı seçim ve slider durumları
  double _distanceValue = 25.0;
  RangeValues _ageRangeValues = const RangeValues(18, 45);
  String _selectedGender = 'Herkes';
  String _selectedTime = 'Sabah';
  final List<String> _selectedGoals = ['Kas Kazanımı', 'Kondisyon'];
  String _selectedLevel = 'Orta';
  String _selectedType = 'Fitness';

  // Canlı silinebilir salon listesi
  List<String> _selectedGyms = ['MACFit Beşiktaş'];

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
          'Filtreler',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _distanceValue = 25.0;
                _ageRangeValues = const RangeValues(18, 45);
                _selectedGender = 'Herkes';
                _selectedTime = 'Sabah';
                _selectedGoals.clear();
                _selectedGoals.addAll(['Kas Kazanımı', 'Kondisyon']);
                _selectedLevel = 'Orta';
                _selectedType = 'Fitness';
                _selectedGyms = ['MACFit Beşiktaş'];
              });
            },
            child: const Text(
              'Sıfırla',
              style: TextStyle(
                color: AppTheme.neonLime,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. MESAFE ARALIĞI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Mesafe Aralığı',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_distanceValue.round()} km',
                        style: const TextStyle(
                          color: AppTheme.neonLime,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _distanceValue,
                    min: 0,
                    max: 50,
                    activeColor: AppTheme.neonLime,
                    inactiveColor: Colors.grey.shade800,
                    onChanged: (val) => setState(() => _distanceValue = val),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '0 km',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        '50 km',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 2. YAŞ ARALIĞI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Yaş Aralığı',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_ageRangeValues.start.round()} - ${_ageRangeValues.end.round()}',
                        style: const TextStyle(
                          color: AppTheme.neonLime,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _ageRangeValues,
                    min: 18,
                    max: 65,
                    activeColor: AppTheme.neonLime,
                    inactiveColor: Colors.grey.shade800,
                    onChanged: (values) =>
                        setState(() => _ageRangeValues = values),
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '18',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      Text(
                        '65+',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. CİNSİYET
                  const Text(
                    'Cinsiyet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['Erkek', 'Kadın', 'Herkes'].map((g) {
                      final isSelected = _selectedGender == g;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedGender = g),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 46,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFF161616),
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(color: Colors.grey.shade700)
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              g,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 4. ANTRENMAN ZAMANI
                  const Text(
                    'Antrenman Zamanı',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTimeGrid(),
                  const SizedBox(height: 24),

                  // 5. HEDEFLER
                  const Text(
                    'Hedefler',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          'Kas Kazanımı',
                          'Kilo Verme',
                          'Güç Artışı',
                          'Kondisyon',
                          'Bodybuilding',
                        ].map((goal) {
                          final isSelected = _selectedGoals.contains(goal);
                          return ChoiceChip(
                            label: Text(goal),
                            selected: isSelected,
                            selectedColor: AppTheme.neonLime,
                            backgroundColor: const Color(0xFF161616),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.black : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedGoals.add(goal);
                                } else {
                                  _selectedGoals.remove(goal);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 6. DENEYİM SEVİYESİ
                  const Text(
                    'Deneyim Seviyesi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['Başlangıç', 'Orta', 'İleri'].map((lvl) {
                      final isSelected = _selectedLevel == lvl;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedLevel = lvl),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 46,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFF161616),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              lvl,
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.neonLime
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 7. SPOR SALONU SEÇİMİ
                  const Text(
                    'Spor Salonu Seçimi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  const TextField(
                    decoration: InputDecoration(
                      hintText: 'Spor salonu ara (örn: MACFit Beşiktaş)',
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: _selectedGyms
                        .map(
                          (gym) => Chip(
                            backgroundColor: const Color(0xFF1E1E1E),
                            avatar: const Icon(
                              Icons.location_on,
                              color: AppTheme.neonLime,
                              size: 16,
                            ),
                            label: Text(
                              gym,
                              style: const TextStyle(color: Colors.white),
                            ),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.grey,
                            ),
                            onDeleted: () {
                              setState(() {
                                _selectedGyms.remove(gym);
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // 8. ANTRENMAN TÜRÜ
                  const Text(
                    'Antrenman Türü',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildTrainingTypeList(),
                ],
              ),
            ),
          ),

          // UYGULA BUTONU
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GymBuddyButton(
              text: 'Filtreleri Uygula ⚡',
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGrid() {
    final times = [
      {'title': 'Sabah', 'hours': '05:00 - 11:00', 'icon': Icons.light_mode},
      {'title': 'Öğle', 'hours': '11:00 - 16:00', 'icon': Icons.wb_sunny},
      {'title': 'Akşam', 'hours': '16:00 - 22:00', 'icon': Icons.nights_stay},
      {'title': 'Gece', 'hours': '22:00 - 05:00', 'icon': Icons.bedtime},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: times.length,
      itemBuilder: (context, index) {
        final t = times[index];
        final isSelected = _selectedTime == t['title'];
        return GestureDetector(
          onTap: () => setState(() => _selectedTime = t['title'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF161616),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppTheme.neonLime : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  t['icon'] as IconData,
                  color: isSelected ? AppTheme.neonLime : Colors.grey,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  t['title'] as String,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppTheme.neonLime : Colors.white,
                  ),
                ),
                Text(
                  t['hours'] as String,
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrainingTypeList() {
    final types = ['Fitness', 'CrossFit', 'Powerlifting', 'Koşu'];
    return Column(
      children: types.map((type) {
        final isSelected = _selectedType == type;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.neonLime : Colors.transparent,
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Icon(
              Icons.fitness_center,
              color: isSelected ? AppTheme.neonLime : Colors.grey,
            ),
            title: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppTheme.neonLime : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? AppTheme.neonLime : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.black)
                  : null,
            ),
            onTap: () => setState(() => _selectedType = type),
          ),
        );
      }).toList(),
    );
  }
}
