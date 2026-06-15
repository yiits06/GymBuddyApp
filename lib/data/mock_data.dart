class MockData {
  // 1. Canlı Yeni Eşleşmeler Listesi
  static final List<Map<String, String>> newMatches = [
    {
      'name': 'Selin',
      'img':
          'https://images.unsplash.com/photo-1548690312-e3b507d8c110?q=80&w=100',
    },
    {
      'name': 'Mert',
      'img':
          'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?q=80&w=100',
    },
    {
      'name': 'Elif',
      'img':
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=100',
    },
    {
      'name': 'Can',
      'img':
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=100',
    },
  ];

  // 2. Canlı Aktif Eşleşmeler Listesi
  static final List<Map<String, dynamic>> activeMatches = [
    {
      'name': 'Ali Rıza',
      'distance': '1.2 km',
      'goal': 'Ortak Hedef: Kas Kütles...',
      'tags': ['Ağırlık Antrenmanı', 'Bacak Günü'],
      'img':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=100',
      'isOnline': true,
    },
    {
      'name': 'Murat Demir',
      'distance': '2.5 km',
      'goal': 'Ortak Hedef: Yağ Yakım...',
      'tags': ['Crossfit'],
      'img':
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=100',
      'isOnline': false,
    },
    {
      'name': 'Zeynep Güçlü',
      'distance': '0.8 km',
      'goal': 'Ortak Hedef: Esneklik &...',
      'tags': ['Yoga', 'HIIT'],
      'img':
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=100',
      'isOnline': false,
    },
  ];

  // 3. Mesajlar Sekmesi Canlı Listesi
  static final List<Map<String, dynamic>> chats = [
    {
      'name': 'Kaan Yılmaz',
      'lastMsg': 'Yarın sabah bacak günü, ...',
      'time': '5dk önce',
      'unread': 2,
      'img':
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=100',
      'isOnline': true,
    },
    {
      'name': 'Burak Özdemir',
      'lastMsg': 'Harika bir antrenmandı, t...',
      'time': '3sa önce',
      'unread': 0,
      'img':
          'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?q=80&w=100',
      'isOnline': false,
    },
  ];

  static void addOrUpdateChat(String name, String img, String lastMsg) {
    // İŞTE BURADA: Eğer kişi hala "Yeni Eşleşme" listesindeyse ordan sil ve "Eşleşmelerim"e taşı!
    final newMatchIndex = newMatches.indexWhere((m) => m['name'] == name);
    if (newMatchIndex != -1) {
      newMatches.removeAt(newMatchIndex);

      // Eşleşmelerim dikey listesine yeni bir kart olarak ekliyoruz
      activeMatches.insert(0, {
        'name': name,
        'distance': '0.4 km',
        'goal': 'Ortak Hedef: Kas Gelişimi',
        'tags': ['Ağırlık Antrenmanı', 'Yeni'],
        'img': img,
        'isOnline': true,
      });
    }

    // Mesaj geçmişi kartını güncelleme veya oluşturma bloğu
    final chatIndex = chats.indexWhere((c) => c['name'] == name);
    if (chatIndex != -1) {
      chats[chatIndex]['lastMsg'] = lastMsg;
      chats[chatIndex]['time'] = 'Şimdi';
      final item = chats.removeAt(chatIndex);
      chats.insert(0, item);
    } else {
      chats.insert(0, {
        'name': name,
        'lastMsg': lastMsg,
        'time': 'Şimdi',
        'unread': 0,
        'img': img,
        'isOnline': true,
      });
    }
  }
}
