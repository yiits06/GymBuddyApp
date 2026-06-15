import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/theme/app_theme.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'nearby.location_off'.tr();
          _isLoading = false;
        });
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'nearby.permission_denied'.tr();
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'nearby.permission_denied_forever'.tr();
          _isLoading = false;
        });
        return;
      }

      // Konumu al (Kullanıcının koordinatları)
      Position position = await Geolocator.getCurrentPosition();
      
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '${'nearby.error'.tr()}$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'nearby.title'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.neonLime))
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : FlutterMap(
                  options: MapOptions(
                    initialCenter: _currentPosition!,
                    initialZoom: 14.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                      userAgentPackageName: 'com.gymbuddy.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition!,
                          width: 60,
                          height: 60,
                          child: const Icon(
                            Icons.my_location,
                            color: AppTheme.neonLime,
                            size: 40,
                          ),
                        ),
                        // Sadece görsel amaçlı sahte yakındaki kullanıcılar (Temsili Markers)
                        Marker(
                          point: LatLng(_currentPosition!.latitude + 0.005, _currentPosition!.longitude + 0.005),
                          width: 40,
                          height: 40,
                          child: const CircleAvatar(
                            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=100'),
                          ),
                        ),
                        Marker(
                          point: LatLng(_currentPosition!.latitude - 0.008, _currentPosition!.longitude - 0.002),
                          width: 40,
                          height: 40,
                          child: const CircleAvatar(
                            backgroundImage: NetworkImage('https://images.unsplash.com/photo-1580489944761-15a19d654956?w=100'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}