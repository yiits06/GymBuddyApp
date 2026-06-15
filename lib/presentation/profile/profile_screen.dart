import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/workout_provider.dart';
import 'edit_profile_screen.dart';
import 'add_workout_bottom_sheet.dart';
import '../providers/profile_provider.dart';
import '../auth/login_screen.dart'; // Kendi dosya yoluna göre düzenle
import '../providers/auth_provider.dart';
import 'settings_screen.dart';
import 'help_center_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  final Color neonLime = const Color(0xFFD4FF00);
  final Color darkSurface = const Color(0xFF161616);
  final Color background = const Color(0xFF0F0F10);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(context, ref),
      // ARTIK KEŞFET LİSTESİNE DEĞİL, DOĞRUDAN KENDİ PROFİLİNE BAKIYORUZ
      body: ref.watch(profilesProvider).when(
        loading: () => Center(child: CircularProgressIndicator(color: neonLime)),
        error: (err, stack) => Center(
          child: Text(
            'Hata: $err',
            style: const TextStyle(color: Colors.red),
          ),
        ),
        data: (profiles) {
          final myProfile = profiles.firstWhere(
            (p) => p['id'].toString() == currentUserId || p['auth_id'].toString() == currentUserId,
            orElse: () => <String, dynamic>{},
          );

          if (myProfile.isEmpty) {
            return Center(child: Text('profile.not_found'.tr(), style: const TextStyle(color: Colors.white)));
          }

          final fullName = myProfile['full_name'] ?? 'profile.new_user'.tr();
          final experienceLevel =
              myProfile['experience_level'] ?? 'profile.not_specified'.tr();
          final goals = List<String>.from(myProfile['goals'] ?? []);
          final avatarUrl = myProfile['avatar_url'];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(
                  context,
                  fullName,
                  avatarUrl,
                  currentUserId,
                ),
                const SizedBox(height: 24),
              if (myProfile['gender'] != null) ...[
                _buildGenderTag(myProfile['gender']),
                const SizedBox(height: 16),
              ],
                _buildStatsSection(),
                const SizedBox(height: 24),
                _buildAthleticProfile(experienceLevel, goals),
                const SizedBox(height: 24),
                _buildRecentWorkouts(context, ref),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGenderTag(String gender) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: neonLime.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: neonLime),
        ),
        child: Text(
          gender,
          style: TextStyle(color: neonLime, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: background,
      elevation: 0,
      title: const Text(
        'GymBuddy',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () {
            // DİREKT ÇIKIŞ YERİNE ALTTAN AÇILAN AYARLAR MENÜSÜ
            showModalBottomSheet(
              context: context,
              backgroundColor: darkSurface,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade700,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: Colors.white,
                        ),
                        title: Text(
                          'settings.title'.tr(),
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context); // Menüyü kapat
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(
                          Icons.help_outline,
                          color: Colors.white,
                        ),
                        title: Text(
                          'profile.help_support'.tr(),
                          style: TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HelpCenterScreen(),
                            ),
                          );
                        },
                      ),
                      const Divider(color: Colors.grey, height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.logout,
                          color: Colors.redAccent,
                        ),
                        title: Text(
                          'settings.logout'.tr(),
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () async {
                      await ref.read(authProvider.notifier).signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'profile.notifications_coming_soon'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: neonLime,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String fullName,
    String? avatarUrl,
    String userId,
  ) {
    return Column(
      children: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: neonLime, width: 2),
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : const NetworkImage(
                      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=200',
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              fullName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.check_circle, color: neonLime, size: 20),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'profile.fitness_partner_title'.tr(),
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: neonLime,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'settings.edit_profile'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (userId.isNotEmpty) {
                    Share.share(
                      '${'profile.share_text'.tr()}https://gymbuddy.app/profile/$userId',
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: neonLime),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'profile.share_profile'.tr(),
                  style: TextStyle(
                    color: neonLime,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        _statCard(Icons.star_border, neonLime, 'profile.partner_trust_score'.tr(), '4.9/5'),
        const SizedBox(height: 12),
        _statCard(
          Icons.local_fire_department_outlined,
          neonLime,
          'profile.weekly_streak'.tr(),
          '5 ${'profile.days'.tr()}',
        ),
        const SizedBox(height: 12),
        _statCard(Icons.fitness_center, neonLime, 'profile.total_sessions'.tr(), '142'),
      ],
    );
  }

  Widget _statCard(IconData icon, Color iconColor, String title, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleticProfile(String experienceLevel, List<String> goals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile.athletic_profile'.tr(),
          style: TextStyle(
            color: neonLime,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'profile.experience_level'.tr(),
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            experienceLevel,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'profile.focus_goals'.tr(),
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: goals.isNotEmpty
              ? goals.map((g) => _buildTag(g)).toList()
              : [_buildTag('profile.no_goal_specified'.tr())],
        ),
        const SizedBox(height: 16),
        Text(
          'profile.home_gym'.tr(),
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: neonLime, size: 18),
            const SizedBox(width: 4),
            const Text(
              'Mars Athletic Club',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }

  Widget _buildRecentWorkouts(BuildContext context, WidgetRef ref) {
    final workoutsAsync = ref.watch(recentWorkoutsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'profile.recent_workouts'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddWorkoutBottomSheet(),
                );
              },
              icon: Icon(Icons.add_circle, color: neonLime, size: 28),
            ),
          ],
        ),
        const SizedBox(height: 16),

        workoutsAsync.when(
          loading: () =>
              Center(child: CircularProgressIndicator(color: neonLime)),
          error: (err, stack) => Text(
            '${'profile.workouts_error'.tr()}$err',
            style: const TextStyle(color: Colors.red),
          ),
          data: (workouts) {
            if (workouts.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: darkSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Text(
                  'profile.no_workouts_yet'.tr(),
                  style: const TextStyle(color: Colors.grey, height: 1.5),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              children: workouts.map((w) {
                final workoutId = w['id'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Dismissible(
                    key: Key(workoutId.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    onDismissed: (direction) async {
                      try {
                        await Supabase.instance.client
                            .from('workouts')
                            .delete()
                            .eq('id', workoutId);
                        ref.invalidate(recentWorkoutsProvider);

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'profile.workout_deleted'.tr(),
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Hata: $e',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: _workoutCard(
                      w['title'] ?? 'profile.unnamed_workout'.tr(),
                      "${w['duration'] ?? 0} dk • ${w['weight'] ?? 0} kg",
                      "",
                      'profile.completed'.tr(),
                      w['image_url'] ??
                          'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=600',
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _workoutCard(
    String title,
    String subtitle,
    String details,
    String time,
    String imageUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    time,
                    style: TextStyle(
                      color: neonLime,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  details,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
