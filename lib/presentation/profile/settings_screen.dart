import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'terms_of_service_screen.dart';
import 'privacy_policy_screen.dart';
import 'help_center_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifyMessages = true;
  bool _notifyMatches = true;
  bool _privateProfile = false;
  String _selectedLanguage = 'Türkçe';
  bool _isLoading = true; // Veriler yüklenirken ekranı bekleteceğiz

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Sayfa açıldığında veritabanından mevcut ayarları çekiyoruz
  Future<void> _loadSettings() async {
    try {
      // Önce cihazın hafızasındaki yerel ayarları çekiyoruz
      final prefs = await SharedPreferences.getInstance();
      final selectedLanguage = prefs.getString('selected_language') ?? 'Türkçe';

      bool notifyMessages = true;
      bool notifyMatches = true;
      bool privateProfile = false;

      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final data = await Supabase.instance.client
            .from('profiles')
            .select('is_private, notify_messages, notify_matches')
            .eq('auth_id', userId)
            .maybeSingle();

        if (data != null) {
          privateProfile = data['is_private'] as bool? ?? false;
          notifyMessages = data['notify_messages'] as bool? ?? true;
          notifyMatches = data['notify_matches'] as bool? ?? true;
        }
      }

      if (mounted) {
        setState(() {
          _notifyMessages = notifyMessages;
          _notifyMatches = notifyMatches;
          _selectedLanguage = selectedLanguage;
          _privateProfile = privateProfile;
        });
      }
    } catch (e) {
      debugPrint('Ayarlar yüklenirken hata oluştu: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _toggleNotifyMessages(bool value) async {
    setState(() => _notifyMessages = value); // Arayüzü anında güncelle
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('profiles').update({'notify_messages': value}).eq('auth_id', userId);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _notifyMessages = !value); // Hata olursa eski haline geri al
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ayar kaydedilemedi.')));
      }
    }
  }

  Future<void> _toggleNotifyMatches(bool value) async {
    setState(() => _notifyMatches = value); // Arayüzü anında güncelle
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client.from('profiles').update({'notify_matches': value}).eq('auth_id', userId);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _notifyMatches = !value); // Hata olursa eski haline geri al
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ayar kaydedilemedi.')));
      }
    }
  }

  Future<void> _changeLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', lang);
    if (mounted) {
      setState(() => _selectedLanguage = lang);
      if (lang == 'Türkçe') {
        context.setLocale(const Locale('tr'));
      } else if (lang == 'English') {
        context.setLocale(const Locale('en'));
      }
      Navigator.pop(context);
    }
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => _buildLanguageDialog(),
    );
  }

  // Gizlilik ayarını değiştirip veritabanına yazar
  Future<void> _togglePrivacy(bool value) async {
    setState(() => _privateProfile = value); // Arayüzü anında güncelle
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({'is_private': value})
            .eq('auth_id', userId);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _privateProfile = !value); // Hata olursa eski haline geri al
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ayar kaydedilemedi.')));
      }
    }
  }

  Future<void> _sendPasswordResetEmail() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null && user.email != null && user.email!.isNotEmpty) {
        await Supabase.instance.client.auth.resetPasswordForEmail(user.email!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('settings.reset_email_sent'.tr(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.neonLime,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('settings.no_email_found'.tr()), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'settings.reset_email_error'.tr()} $e', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleSignOut() async {
    await ref.read(authProvider.notifier).signOut();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'settings.title'.tr(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.neonLime))
        : ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildSectionHeader('settings.account_management'.tr()),
          _buildListTile(
            'settings.edit_profile'.tr(),
            Icons.manage_accounts_outlined,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())),
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 32),

          _buildSectionHeader('settings.notifications_detailed'.tr()),
          _buildSwitchTile(
            'settings.msg_notifications'.tr(),
            'settings.msg_notifications_desc'.tr(),
            _notifyMessages,
            _toggleNotifyMessages,
          ),
          _buildSwitchTile(
            'settings.match_notifications'.tr(),
            'settings.match_notifications_desc'.tr(),
            _notifyMatches,
            _toggleNotifyMatches,
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 32),

          _buildSectionHeader('settings.app_preferences'.tr()),
          _buildListTile(
            'settings.language'.tr(),
            Icons.language,
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text(_selectedLanguage, style: const TextStyle(color: AppTheme.neonLime, fontWeight: FontWeight.bold)), const SizedBox(width: 8), const Icon(Icons.chevron_right, color: Colors.grey)]),
            onTap: _showLanguageDialog,
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 32),

          _buildSectionHeader('settings.privacy_security'.tr()),
          _buildSwitchTile(
            'settings.private_profile'.tr(),
            'settings.private_profile_desc'.tr(),
            _privateProfile,
            _togglePrivacy,
          ),
          _buildListTile(
            'settings.change_password'.tr(),
            Icons.lock_outline,
            onTap: _sendPasswordResetEmail,
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 32),

          _buildSectionHeader('settings.support_info'.tr()),
          _buildListTile(
            'settings.help_center'.tr(),
            Icons.help_outline,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpCenterScreen())),
          ),
          _buildListTile(
            'settings.terms_of_service'.tr(),
            Icons.description_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TermsOfServiceScreen(),
                ),
              );
            },
          ),
          _buildListTile(
            'settings.privacy_policy'.tr(),
            Icons.privacy_tip_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),
          const Divider(color: Color(0xFF2A2A2A), height: 32),

          _buildSectionHeader('settings.secure_logout'.tr()),
          _buildListTile(
            'settings.logout'.tr(),
            Icons.logout,
            iconColor: Colors.white,
            textColor: Colors.white,
            onTap: _handleSignOut,
          ),
          _buildListTile(
            'settings.delete_account'.tr(),
            Icons.delete_forever,
            iconColor: Colors.redAccent,
            textColor: Colors.redAccent,
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.neonLime,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.neonLime,
        activeTrackColor: AppTheme.neonLime.withOpacity(0.3),
      ),
    );
  }

  Widget _buildListTile(String title, IconData icon, {Color? iconColor, Color? textColor, VoidCallback? onTap, Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: iconColor ?? Colors.white70),
      title: Text(
        title,
        style: TextStyle(color: textColor ?? Colors.white, fontWeight: FontWeight.bold),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildLanguageDialog() {
    final languages = ['Türkçe', 'English', 'Deutsch', 'Español'];
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Dil Seçeneği', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: languages.map((lang) {
          final isSelected = _selectedLanguage == lang;
          return ListTile(
            title: Text(lang, style: TextStyle(color: isSelected ? AppTheme.neonLime : Colors.white, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.neonLime) : null,
            onTap: () => _changeLanguage(lang),
          );
        }).toList(),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Hesabı Sil', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Hesabını kalıcı olarak silmek istediğine emin misin? Bu işlem geri alınamaz ve tüm mesajların, eşleşmelerin kaybolur.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              try {
                final supabase = Supabase.instance.client;
                final user = supabase.auth.currentUser;
                
                if (user != null) {
                  final userId = user.id;
                  
                  // 1. Profil tablosundan kullanıcının ID'sini bul
                  final profile = await supabase.from('profiles').select('id').eq('auth_id', userId).limit(1);
                  if (profile.isNotEmpty) {
                    final profileId = profile.first['id'];
                    // 2. Beğenileri ve mesajları sil
                    await supabase.from('likes').delete().or('liker_id.eq.$profileId,liked_id.eq.$profileId');
                    await supabase.from('messages').delete().or('sender_id.eq.$profileId,receiver_id.eq.$profileId');
                  }
                  
                  // 3. Antrenmanları ve profili sil
                  await supabase.from('workouts').delete().eq('user_id', userId);
                  await supabase.from('profiles').delete().eq('auth_id', userId);
                  
                  // 4. Supabase Auth tablosundan kullanıcıyı tamamen silmek için RPC çağrısı
                  await supabase.rpc('delete_user');
                }

                Navigator.pop(context); // Dialogu kapat
                await ref.read(authProvider.notifier).signOut(); // Çıkış yap ve hafızayı temizle
                
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context); // Dialogu kapat
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hesap silinirken hata oluştu: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: const Text('Evet, Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}