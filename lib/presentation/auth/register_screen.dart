import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'register_controller.dart';
import '../home/main_layout.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _gymController = TextEditingController();
  String? _selectedGender;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _gymController.dispose();
    super.dispose();
  }

  // Son adımda Supabase'e kayıt isteği atacak fonksiyon
  Future<void> _handleRegister() async {
    final regState = ref.read(registerProvider);

    final success = await ref
        .read(authProvider.notifier)
        .signUp(
          email: regState.email,
          password: regState.password,
          fullName: regState.fullName,
          birthDate: regState.birthDate!,
          goals: regState.selectedGoals,
          experienceLevel: regState.selectedExperience ?? 'Belirtilmedi',
          gymId:
              regState.selectedGym != null && regState.selectedGym!.isNotEmpty
              ? regState.selectedGym
              : 'Salon Belirtilmedi',
        );

    if (mounted) {
      if (success) {
        // Cinsiyet bilgisini de kayıttan sonra profillere güncelle
        if (_selectedGender != null) {
          final user = Supabase.instance.client.auth.currentUser;
          if (user != null) {
            await Supabase.instance.client.from('profiles').update({'gender': _selectedGender}).eq('auth_id', user.id);
          }
        }

        // ÇÖZÜM 2: Kayıt başarıyla tamamlandıktan sonra da arkada kalan form hafızasını temizle
        ref.read(registerProvider.notifier).reset();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayout()),
          (route) => false,
        );
      } else {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? 'Kayıt başarısız oldu.',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hem Kayıt adımlarını hem de Supabase yüklenme durumunu canlı izliyoruz
    final regState = ref.watch(registerProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (regState.currentStep > 1) {
              // Eğer 2, 3 veya 4. adımdaysa sadece bir önceki adıma dön
              ref.read(registerProvider.notifier).previousStep();
            } else {
              // İŞTE ÇÖZÜM BURADA: İlk adımdaysa ve geriye basıyorsa önce tüm verileri SIFIRLA
              ref.read(registerProvider.notifier).reset();

              // Sonra Giriş ekranına yönlendir
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Adım Göstergesi (Progress)
              Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index < regState.currentStep
                            ? AppTheme.neonLime
                            : Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Dinamik İçerik Alanı
              Expanded(
                child: _buildStepContent(regState.currentStep, regState),
              ),

              const SizedBox(height: 24),

              // İleri / Kayıt Ol Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.neonLime,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          if (regState.currentStep == 1) {
                            if (_nameController.text.isEmpty ||
                                _emailController.text.isEmpty ||
                                _passwordController.text.isEmpty ||
                                regState.birthDate == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Lütfen tüm alanları doldurun.',
                                  ),
                                ),
                              );
                              return;
                            }
                    if (_selectedGender == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lütfen cinsiyetinizi seçin.')),
                      );
                      return;
                    }
                            ref
                                .read(registerProvider.notifier)
                                .updateAccountInfo(
                                  _nameController.text.trim(),
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                            ref.read(registerProvider.notifier).nextStep();
                          } else if (regState.currentStep == 2) {
                            if (regState.selectedGoals.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Lütfen en az bir hedef seçin.',
                                  ),
                                ),
                              );
                              return;
                            }
                            ref.read(registerProvider.notifier).nextStep();
                          } else if (regState.currentStep == 3) {
                            if (regState.selectedExperience == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Lütfen deneyim seviyenizi seçin.',
                                  ),
                                ),
                              );
                              return;
                            }
                            ref.read(registerProvider.notifier).nextStep();
                          } else {
                            // 4. Adım tamamlandı, veritabanına kaydet!
                            _handleRegister();
                          }
                        },
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 3,
                          ),
                        )
                      : Text(
                          regState.currentStep == 4
                              ? 'Profili Tamamla ve Katıl'
                              : 'İleri',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(int step, RegisterState state) {
    switch (step) {
      case 1:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hesabını\nOluştur',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                _nameController,
                'Ad Soyad',
                Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _emailController,
                'E-posta Adresi',
                Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                _passwordController,
                'Şifre',
                Icons.lock_outline,
                obscureText: true,
              ),
              const SizedBox(height: 16),
            const Text(
              'Cinsiyet',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: ['Erkek', 'Kadın', 'Belirtmek İstemiyorum'].map((gen) {
                final isSelected = _selectedGender == gen;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedGender = gen),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.neonLime.withOpacity(0.1) : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: AppTheme.neonLime) : Border.all(color: Colors.transparent),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        gen,
                        style: TextStyle(
                          color: isSelected ? AppTheme.neonLime : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
              _buildBirthDateField(state.birthDate),
            ],
          ),
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ana Hedeflerin Neler?',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sana en uygun partnerleri bulmamız için önemli.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  [
                    'Kas Kazanımı',
                    'Kilo Verme',
                    'Kondisyon',
                    'Güç Artışı',
                    'Esneklik',
                    'Powerlifting',
                  ].map((goal) {
                    final isSelected = state.selectedGoals.contains(goal);
                    return ChoiceChip(
                      label: Text(
                        goal,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.neonLime,
                      backgroundColor: const Color(0xFF1E1E1E),
                      onSelected: (_) =>
                          ref.read(registerProvider.notifier).toggleGoal(goal),
                    );
                  }).toList(),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deneyim Seviyen',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 32),
            ...['Başlangıç', 'Orta Seviye', 'İleri Seviye'].map((level) {
              final isSelected = state.selectedExperience == level;
              return GestureDetector(
                onTap: () =>
                    ref.read(registerProvider.notifier).setExperience(level),
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.neonLime.withValues(alpha: 0.1)
                        : const Color(0xFF1E1E1E),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.neonLime
                          : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.neonLime : Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      case 4:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Ana Spor Salonun',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Antrenman yaptığın ana salonu seç veya adını yaz.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children:
                  [
                    'MACFit',
                    'Mars Athletic',
                    'Hillside City Club',
                    'Fit Station',
                    'Kendi Salonum',
                  ].map((gym) {
                    final isSelected = state.selectedGym == gym;
                    return ChoiceChip(
                      label: Text(gym),
                      selected: isSelected,
                      selectedColor: AppTheme.neonLime,
                      backgroundColor: const Color(0xFF1E1E1E),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (_) {
                        _gymController.text = gym;
                        ref.read(registerProvider.notifier).setGym(gym);
                      },
                    );
                  }).toList(),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _gymController,
              onChanged: (val) =>
                  ref.read(registerProvider.notifier).setGym(val.trim()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Salon adı yaz (örn: MACFit Beşiktaş)',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBirthDateField(DateTime? birthDate) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _pickBirthDate,
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: 'Doğum Tarihi',
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.cake_outlined, color: Colors.grey),
        ),
        child: Text(
          birthDate == null ? 'Doğum Tarihi' : _formatBirthDate(birthDate),
          style: TextStyle(
            color: birthDate == null ? Colors.grey : Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final latestBirthDate = DateTime(now.year - 13, now.month, now.day);
    final selected = await showDatePicker(
      context: context,
      initialDate:
          ref.read(registerProvider).birthDate ?? DateTime(now.year - 25),
      firstDate: DateTime(now.year - 90),
      lastDate: latestBirthDate,
      helpText: 'Doğum tarihini seç',
      cancelText: 'İptal',
      confirmText: 'Seç',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.neonLime,
              onPrimary: Colors.black,
              surface: Color(0xFF1E1E1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (selected != null) {
      ref.read(registerProvider.notifier).setBirthDate(selected);
    }
  }

  String _formatBirthDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.grey),
      ),
    );
  }
}
