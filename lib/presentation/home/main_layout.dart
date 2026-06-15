import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

// Tüm gerçek sayfalarımızı buraya çağırıyoruz
import '../discover/discover_screen.dart';
import '../nearby/nearby_screen.dart';
import '../matches/matches_screen.dart';
import '../chat/messages_screen.dart';
import '../profile/profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // Alt menüdeki butonlara tıklandığında sırasıyla açılacak GÜNCEL ekranlarımız
  final List<Widget> _screens = [
    const DiscoverScreen(),
    const NearbyScreen(),
    const MatchesScreen(),
    const MessagesScreen(),
    const ProfileScreen(), // İŞTE BURASI: Geçici yazı yerine gerçek Profil sayfanı bağladık!
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // IndexedStack kullanarak ekranlar arası geçişte verilerin kaybolmamasını (state'in korunmasını) sağlıyoruz
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade900, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.black,
          selectedItemColor: AppTheme.neonLime,
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.explore_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.explore),
              ),
              label: 'Keşfet',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.location_on_outlined),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.location_on),
              ),
              label: 'Yakın',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.people_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.people),
              ),
              label: 'Eşleşmeler',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat_bubble_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat_bubble),
              ),
              label: 'Mesajlar',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person_outline),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.person),
              ),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
