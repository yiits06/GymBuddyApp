import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/gym_buddy_button.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  String _selectedLevel = 'Başlangıç';
  final List<String> _myGoals = [];
  bool _isLoading = false;

  // Fotoğraf yükleme durumunu ve URL'i tutacağımız değişkenler
  bool _isUploadingImage = false;
  String? _avatarUrl;
  String? _profileId;
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    final profilesAsync = ref.read(profilesProvider);
    profilesAsync.whenData((profiles) {
      final supabase = Supabase.instance.client;
      final authUid = supabase.auth.currentUser?.id ?? '';

      final myProfile = profiles.firstWhere(
        (p) =>
            (p['id'] ?? '').toString() == authUid ||
            (p['auth_id'] ?? '').toString() == authUid,
        orElse: () => <String, dynamic>{},
      );

      if (myProfile.isNotEmpty && mounted) {
        setState(() {
          _profileId = myProfile['id'].toString();
          _nameController.text = myProfile['full_name'] ?? '';
          _selectedLevel = myProfile['experience_level'] ?? 'Başlangıç';
          _selectedGender = myProfile['gender'];
          _myGoals.clear();
          _myGoals.addAll(List<String>.from(myProfile['goals'] ?? []));
          _avatarUrl =
              myProfile['avatar_url']; // Veritabanından gelen fotoğrafı al
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _getLocalizedLevel(String lvl) {
    if (lvl == 'Başlangıç') return 'edit_profile.beginner'.tr();
    if (lvl == 'Orta') return 'edit_profile.intermediate'.tr();
    if (lvl == 'İleri Seviye') return 'edit_profile.advanced'.tr();
    return lvl;
  }

  String _getLocalizedGender(String gen) {
    if (gen == 'Erkek') return 'edit_profile.male'.tr();
    if (gen == 'Kadın') return 'edit_profile.female'.tr();
    if (gen == 'Belirtmek İstemiyorum') return 'edit_profile.prefer_not_to_say'.tr();
    return gen;
  }

  // --- FOTOĞRAF SEÇME VE YÜKLEME FONKSİYONU ---
  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('edit_profile.user_not_found'.tr());

      final fileExt = image.name.split('.').last;
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.$fileExt';
      final filePath = '$userId/$fileName';

      // 1. DÜZELTME: Resmi File yolundan değil, Bayt (Byte) olarak okuyoruz (Web için şart)
      final imageBytes = await image.readAsBytes();

      // 2. DÜZELTME: upload yerine uploadBinary kullanıyoruz
      await supabase.storage
          .from('avatars')
          .uploadBinary(
            filePath,
            imageBytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType:
                  'image/$fileExt', // Resmin formatını tarayıcıya bildiriyoruz
            ),
          );

      final imageUrl = supabase.storage.from('avatars').getPublicUrl(filePath);

      await supabase
          .from('profiles')
          .update({'avatar_url': imageUrl})
          .eq('auth_id', userId);

      setState(() {
        _avatarUrl = imageUrl;
        _isUploadingImage = false;
      });
      ref.invalidate(profilesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('edit_profile.photo_updated'.tr()),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'edit_profile.photo_upload_failed'.tr()}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      if (_profileId == null) throw Exception('edit_profile.user_not_found'.tr());

      await Supabase.instance.client
          .from('profiles')
          .update({
            'full_name': _nameController.text,
            'experience_level': _selectedLevel,
            'goals': _myGoals,
            'gender': _selectedGender,
          })
          .eq('id', _profileId!); // auth_id değil direk primary key id ile güncellenir

      ref.invalidate(profilesProvider);

      if (mounted) {
        Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F10),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'settings.edit_profile'.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _isUploadingImage ? null : _pickAndUploadImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: Colors.grey[800],
                            // Kullanıcının resmi varsa onu, yoksa varsayılanı göster
                            backgroundImage: _avatarUrl != null
                                ? NetworkImage(_avatarUrl!)
                                : const NetworkImage(
                                    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=200',
                                  ),
                          ),
                          if (_isUploadingImage)
                            const Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.neonLime,
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.neonLime,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'edit_profile.full_name'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppTheme.neonLime),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'profile.experience_level'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: ['Başlangıç', 'Orta', 'İleri Seviye'].map((lvl) {
                      final isSelected = _selectedLevel == lvl;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedLevel = lvl),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 46,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF2A2A15)
                                  : const Color(0xFF161616),
                              borderRadius: BorderRadius.circular(10),
                              border: isSelected
                                  ? Border.all(
                                      color: AppTheme.neonLime,
                                      width: 1,
                                    )
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _getLocalizedLevel(lvl),
                              style: TextStyle(
                                color: isSelected
                                    ? AppTheme.neonLime
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
          Text(
            'edit_profile.gender'.tr(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: ['Erkek', 'Kadın', 'Belirtmek İstemiyorum'].map((gen) {
              final isSelected = _selectedGender == gen;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = gen),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 46,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2A2A15) : const Color(0xFF161616),
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected ? Border.all(color: AppTheme.neonLime, width: 1) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _getLocalizedGender(gen),
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
          const SizedBox(height: 24),
                  Text(
                    'profile.focus_goals'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                          '#Güç',
                          '#Powerlifting',
                          '#Hipertrofi',
                          '#Kondisyon',
                          '#KiloVerme',
                          'Kas Kazanımı',
                          'Esneklik',
                        ].map((tag) {
                          final isSelected = _myGoals.contains(tag);
                          return FilterChip(
                            label: Text(tag),
                            selected: isSelected,
                            selectedColor: const Color(0xFF2A2A15),
                            checkmarkColor: AppTheme.neonLime,
                            backgroundColor: const Color(0xFF161616),
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? AppTheme.neonLime
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(
                                color: isSelected
                                    ? AppTheme.neonLime.withValues(alpha: 0.5)
                                    : Colors.transparent,
                              ),
                            ),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _myGoals.add(tag);
                                } else {
                                  _myGoals.remove(tag);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: GymBuddyButton(
              text: _isLoading ? 'edit_profile.updating'.tr() : 'edit_profile.save_changes'.tr(),
              onPressed: _isLoading ? () {} : () => _saveProfile(),
            ),
          ),
        ],
      ),
    );
  }
}
