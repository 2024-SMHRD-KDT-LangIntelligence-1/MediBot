import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kakao_map_plugin/kakao_map_plugin.dart';
import 'package:geolocator/geolocator.dart';

class KakaoMapPharmacyScreen extends StatefulWidget {
  const KakaoMapPharmacyScreen({super.key});

  @override
  State<KakaoMapPharmacyScreen> createState() => _KakaoMapPharmacyScreenState();
}

class _KakaoMapPharmacyScreenState extends State<KakaoMapPharmacyScreen> {
  KakaoMapController? mapController;
  List<Marker> markers = [];
  LatLng? center;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    debugPrint("📍 위치 권한 확인 중...");
    final position = await _determinePosition();
    setState(() {
      center = LatLng(position.latitude, position.longitude);
    });
    await _searchNearby("약국");
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('❗ 위치 서비스 꺼져 있음');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('❗ 위치 권한 영구 거부됨');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _searchNearby(String keyword) async {
    if (center == null) return;

    const String restApiKey = "4e3fad26fbcec489f06457486e212255";
    const String restApiKey2 = "015412fbc48c3a4e31b1926b6adb667e";
    final url = Uri.parse(
      'https://dapi.kakao.com/v2/local/search/keyword.json'
      '?query=$keyword&x=${center!.longitude}&y=${center!.latitude}&radius=2000',
    );

    final response = await http.get(
      url,
      headers: {
        "Authorization": "KakaoAK $restApiKey2",
        "KA": "sdk/1.0 app/medibot os/ios-15 lang/ko device/iPhone13,3",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final documents = data['documents'];

      print("📍 검색된 장소 수: ${documents.length}");

      setState(() {
        markers =
            documents.map<Marker>((doc) {
              return Marker(
                markerId: UniqueKey().toString(),
                latLng: LatLng(double.parse(doc['y']), double.parse(doc['x'])),
                infoWindowContent: doc['place_name'],
                markerImageSrc:
                    "data:image/jpeg;base64,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",
                width: 40,
                height: 40,
              );
            }).toList();
      });
    } else {
      debugPrint("❌ 카카오 API 실패: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("주변 약국", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          center == null
              ? const Center(child: CupertinoActivityIndicator())
              : Stack(
                children: [
                  KakaoMap(
                    center: center!,
                    onMapCreated: (controller) {
                      mapController = controller;
                      controller.setLevel(3);
                    },
                    markers: markers,
                  ),
                  Positioned(
                    top: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        "현재 위치를 기준으로 주변 약국을 표시합니다.",
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _searchNearby("병원"),
        label: const Text("병원 검색", style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.local_hospital, color: Colors.white),
        backgroundColor: Colors.indigoAccent,
      ),
    );
  }
}
