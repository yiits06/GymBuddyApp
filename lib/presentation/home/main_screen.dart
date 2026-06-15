import 'package:flutter/material.dart';
import '../discover/discover_screen.dart';
import '../../core/theme/app_theme.dart';
import '../nearby/nearby_screen.dart';
import '../matches/matches_screen.dart';
import '../chat/messages_screen.dart';
import '../profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Alt menüdeki sekmelerin listesi
  final List<Widget> _screens = [
    const DiscoverScreen(), //
    const NearbyScreen(), //  Canlı salon ekranı bağlandı
    const MatchesScreen(), //  Eşleşmeler ekranı bağlandı
    const MessagesScreen(), //  Mesajlar ekranı bağlandı
    const ProfileScreen(), //
    const Center(child: Text('Profil')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: AppTheme.neonLime,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Keşfet'),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Yakın',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Eşleşmeler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'Mesajlar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
