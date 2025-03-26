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
        "KA": "sdk/1.0 app/MediBot os/ios-15 lang=ko-KR device=iPhone",
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
                    onMapCreated: (controller) async {
                      mapController = controller;

                      await Future.delayed(const Duration(milliseconds: 300));
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
