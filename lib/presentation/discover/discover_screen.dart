import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';
import '../providers/like_provider.dart';
import '../matches/match_success_screen.dart';
import '../../data/models/user_model.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.invalidate(profilesProvider));
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUid = Supabase.instance.client.auth.currentUser?.id ?? '';
    final profilesAsync = ref.watch(profilesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'GymBuddy',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: profilesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.neonLime),
        ),
        error: (err, _) => Center(
          child: Text('Hata: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (profiles) {
          final myRawProfile = profiles.firstWhere(
            (p) =>
                (p['auth_id'] ?? '').toString() == authUid ||
                (p['id'] ?? '').toString() == authUid,
            orElse: () => <String, dynamic>{},
          );

          if (myRawProfile.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.neonLime),
            );
          }

          final String myProfileId = myRawProfile['id'].toString();

          // KESİN FİLTRELEME: Kendini ve halihazırda like attığın kişileri listeden temizle
          final discoverList = profiles
              .where((p) => p['id'].toString() != myProfileId)
              .map((p) => UserModel.fromJson(p))
              .toList();

          if (discoverList.isEmpty || _isFinished) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: AppTheme.neonLime, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'discover.all_discovered'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonLime,
                    ),
                    onPressed: () {
                      ref.invalidate(profilesProvider);
                      setState(() => _isFinished = false);
                    },
                    child: Text(
                      'discover.refresh_list'.tr(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: CardSwiper(
                    controller: _swiperController,
                    cardsCount: discoverList.length,
                    isLoop: false,
                    numberOfCardsDisplayed: discoverList.length > 1 ? 2 : 1,
                    onEnd: () => setState(() => _isFinished = true),
                    onSwipe: (previousIndex, currentIndex, direction) async {
                      final currentSportBuddy = discoverList[previousIndex];
                      if (direction == CardSwiperDirection.right) {
                        // ÇÖZÜM: Asenkron işlemden önce ScaffoldMessenger ve Navigator'ı kaydediyoruz.
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        
                        try {
                          final isMatch = await ref
                              .read(likeRepositoryProvider)
                              .likeUser(
                                myProfileId: myProfileId,
                                likedProfileId: currentSportBuddy.id,
                              );
                          
                          // KESİN ÇÖZÜM: Yeni eşleşmelerin mesajlar sekmesine anında düşmesi için hafızayı temizle
                          ref.invalidate(myMatchesProvider);
                          
                          if (mounted) {
                            if (isMatch) {
                              navigator.push(
                                MaterialPageRoute(
                                  builder: (context) => MatchSuccessScreen(
                                    matchedUserId: currentSportBuddy.id,
                                    matchedUserName: currentSportBuddy.fullName,
                                    matchedUserImage: currentSportBuddy.avatarUrl ?? '',
                                    currentUserImage: myRawProfile['avatar_url'] ?? '',
                                  ),
                                ),
                              );
                            } else {
                              scaffoldMessenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'discover.liked'.tr(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  backgroundColor: AppTheme.neonLime,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          debugPrint('Beğeni hatası: $e'); // Hata olsa bile takılmayı önler
                        }
                      }
                      return true;
                    },
                    cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
                      final currentSportBuddy = discoverList[index];
                      final gymName = currentSportBuddy.gymId?.trim();
                      final ageLabel = currentSportBuddy.age != null
                          ? '${currentSportBuddy.age} ${'discover.years_old'.tr()}'
                          : null;

                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFF121212), // KESİN ÇÖZÜM: Kartın arkasını göstermesini engeller
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: const Color(0xFF2A2A2A), width: 1.5),
                          image: currentSportBuddy.avatarUrl != null && currentSportBuddy.avatarUrl!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(currentSportBuddy.avatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        clipBehavior: Clip.antiAlias, // İçeriğin köşelerden taşmasını önler
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.2),
                                Colors.black.withValues(alpha: 0.95),
                              ],
                              stops: const [0.5, 0.75, 1.0],
                            ),
                          ),
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      currentSportBuddy.fullName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (ageLabel != null)
                                    _buildInfoPill(Icons.cake_outlined, ageLabel),
                                  _buildInfoPill(
                                    Icons.fitness_center,
                                    currentSportBuddy.experienceLevel ??
                                        'discover.level_not_specified'.tr(),
                                  ),
                                  _buildInfoPill(
                                    Icons.location_on_outlined,
                                    gymName != null && gymName.isNotEmpty
                                        ? gymName
                                        : 'discover.gym_not_specified'.tr(),
                                    isHighlighted: gymName != null &&
                                        gymName.isNotEmpty,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: currentSportBuddy.goals
                                    .map(
                                      (goal) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.6,
                                          ),
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(
                                            color: Colors.grey.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          goal,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                    onPressed: () => _swiperController.swipe(CardSwiperDirection.left),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1E1E),
                        padding: const EdgeInsets.all(16),
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 1,
                        ),
                      ),
                    ),
                    IconButton(
                    onPressed: () => _swiperController.swipe(CardSwiperDirection.right),
                      icon: const Icon(
                        Icons.favorite,
                        color: AppTheme.neonLime,
                        size: 40,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF1E1E1E),
                        padding: const EdgeInsets.all(16),
                        side: const BorderSide(
                          color: AppTheme.neonLime,
                          width: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoPill(
    IconData icon,
    String label, {
    bool isHighlighted = false,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.neonLime.withValues(alpha: 0.16)
            : Colors.black.withValues(alpha: 0.46),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted
              ? AppTheme.neonLime.withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: isHighlighted ? AppTheme.neonLime : Colors.white70,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isHighlighted ? AppTheme.neonLime : Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
