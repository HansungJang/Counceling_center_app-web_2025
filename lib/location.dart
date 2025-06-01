// location_page.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart'; // Import for geocoding if needed (경도, 위도 표기)

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {

  final String address = ' 경기도 수원시 권선구 경수대로 373 (권선동)';  
  final String phone = '+82 10-1234-5678';
  final String email = 'mindrest@counsel.kr';
  final String mapUrl =
      'https://www.google.com/maps/?entry=ttu&g_ep=EgoyMDI1MDUxNS4wIKXMDSoASAFQAw%3D%3D';

  GoogleMapController? _mapController;
  LatLng? _targetCoordinates;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _geocodeAddress();
  }

  Future<void> _geocodeAddress() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        if (mounted) {
          setState(() {
            _targetCoordinates = LatLng(location.latitude, location.longitude);
            _markers.clear(); // 기존 마커 제거
            _markers.add(
              Marker(
                markerId: MarkerId(address), // 고유한 ID
                position: _targetCoordinates!,
                infoWindow: InfoWindow(title: '상담센터 위치', snippet: address),
              ),
            );
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = '주소를 찾을 수 없습니다: $address';
            _isLoading = false;
            // 주소를 찾지 못했을 때 기본 위치 (예: 서울 중심)
            _targetCoordinates = const LatLng(37.5665, 126.9780); 
             _markers.clear();
            _markers.add(
              Marker(
                markerId: const MarkerId('default_location'),
                position: _targetCoordinates!,
                infoWindow: InfoWindow(title: '오류', snippet: _errorMessage),
              ),
            );
          });
        }
      }
    } catch (e) {
      print('Geocoding Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '주소 변환 중 오류가 발생했습니다. API 키와 네트워크 연결을 확인해주세요.';
          _isLoading = false;
          // 오류 발생 시 기본 위치
          _targetCoordinates = const LatLng(37.5665, 126.9780); 
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId('error_location'),
              position: _targetCoordinates!,
              infoWindow: InfoWindow(title: '오류', snippet: '위치를 불러올 수 없습니다.'),
            ),
          );
        });
      }
    }
  }


  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Address',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(address),
            const SizedBox(height: 16),

            // --- Google Map Widget ---
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                      : _targetCoordinates == null // 혹시 모를 null 상황 방지
                          ? const Center(child: Text('지도 데이터를 가져올 수 없습니다.'))
                          : GoogleMap(
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(
                                target: _targetCoordinates!,
                                zoom: 16.0, // 확대 수준 (15.0 ~ 17.0 사이 추천)
                              ),
                              markers: _markers,
                              onMapCreated: (GoogleMapController controller) {
                                _mapController = controller;
                              },
                              // 필요시 지도 관련 설정 추가
                              // zoomControlsEnabled: false,
                              // myLocationButtonEnabled: false,
                            ),
            ),
            // --- ---
            const SizedBox(height: 16),


            ElevatedButton.icon(
              onPressed: () => _launchUrl(mapUrl),
              icon: const Icon(Icons.map),
              label: const Text('View on Google Maps'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Contact Us',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(phone),
              onTap: () => _launchUrl('tel:$phone'),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(email),
              onTap: () => _launchUrl('mailto:$email'),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chat via KakaoTalk'),
              onTap: () => _launchUrl('https://pf.kakao.com/_kakaochatlink'),
            ),
          ],
        ),
      ),
    );
  }
}
