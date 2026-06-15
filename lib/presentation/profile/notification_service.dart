import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../chat/chat_detail_screen.dart';

// Uygulama genelinde bağlamsız (context olmadan) navigasyon yapabilmek için GlobalKey tanımlıyoruz
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Arka planda bildirim geldiğinde çalışacak olan bu fonksiyonun bir class içinde olmaması (top-level) zorunludur.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Arka Plan Bildirimi Geldi: ${message.messageId}");
}

class NotificationService {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _supabase = Supabase.instance.client;
  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Kullanıcıdan bildirim izni iste (iOS & Android 13+)
    await _firebaseMessaging.requestPermission();

    // Yerel bildirimleri başlat (Uygulama açıkken göstermek için)
    await _initLocalNotifications();

    // 2. Cihaza özel FCM anahtarını al
    final fcmToken = await _firebaseMessaging.getToken();
    debugPrint('================ FCM Token ================');
    debugPrint(fcmToken);
    debugPrint('===========================================');

    // 3. Alınan anahtarı veritabanına kaydet
    if (fcmToken != null && _supabase.auth.currentUser != null) {
      await saveTokenToDatabase(fcmToken);
    }

    // 4. Anahtar değişirse (örn: uygulama silinip yüklendiğinde) veritabanını güncelle
    _firebaseMessaging.onTokenRefresh.listen(saveTokenToDatabase);

    // 5. Uygulama içi bildirim dinleyicilerini başlat
    _initPushNotifications();
  }

  Future<void> _initLocalNotifications() async {
    const androidInitSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInitSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings,
    );

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Uygulama açıkken ekrandan kayan yerel bildirime tıklandığında...
        if (response.payload != null) {
          final decoded = jsonDecode(response.payload!);
          final data = decoded is Map ? Map<String, dynamic>.from(decoded) : <String, dynamic>{};
          _handleNotificationTap(data);
        }
      },
    );
  }

  Future<void> saveTokenToDatabase(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase
          .from('profiles')
          .update({'fcm_token': token})
          .eq('auth_id', userId);

      debugPrint('FCM anahtarı başarıyla veritabanına kaydedildi.');
    } catch (e) {
      debugPrint('FCM anahtarı kaydedilirken hata oluştu: $e');
    }
  }

  void _initPushNotifications() {
    // Uygulama kapalıyken (terminated) bildirime tıklanıp açıldığında...
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint("Uygulama kapalıyken bildirime tıklandı.");
        _handleNotificationTap(message.data);
      }
    });

    // Uygulama arka plandayken bildirime tıklandığında...
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("Uygulama arka plandayken bildirime tıklandı.");
      _handleNotificationTap(message.data);
    });

    // Uygulama açıkken (foreground) bildirim geldiğinde...
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("Uygulama açıkken bildirim geldi.");
      if (message.notification != null) {
        debugPrint('Bildirim başlığı: ${message.notification!.title}');
        _showLocalNotification(message);
      }
    });

    // Uygulama arka plandayken bildirim geldiğinde çalışacak fonksiyonu ayarla
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  // Bildirime tıklandığında navigasyonu tetikleyen ortak fonksiyon
  void _handleNotificationTap(Map<String, dynamic> data) {
    // Edge Function üzerinden gönderilen gizli data payload'unu yakalıyoruz
    final partnerId = data['sender_id']?.toString();
    if (partnerId != null) {
      final partnerName = data['sender_name']?.toString() ?? 'GymBuddy Kullanıcısı';
      final partnerImage = data['sender_image']?.toString() ?? 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=100';

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            userId: partnerId,
            userName: partnerName,
            userImage: partnerImage,
          ),
        ),
      );
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'gymbuddy_high_importance', // Kanal ID
      'Önemli Bildirimler', // Kanal Adı
      channelDescription: 'Yeni mesaj ve eşleşme bildirimleri bu kanaldan gelir.',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFD4FF00), // AppTheme.neonLime rengi
    );

    const iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true);
    const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotificationsPlugin.show(
      message.notification?.hashCode ?? 0,
      message.notification?.title,
      message.notification?.body,
      notificationDetails,
      payload: jsonEncode(message.data), // Tıklandığında okunabilmesi için gizli veriyi yerel bildirime ekliyoruz
    );
  }
}