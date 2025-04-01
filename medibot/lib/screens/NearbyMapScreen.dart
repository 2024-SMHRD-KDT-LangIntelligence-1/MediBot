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
  bool showingPharmacy = true; // true면 약국, false면 병원

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

                // infoWindowContent: doc['place_name'],
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
        onPressed: () {
          setState(() {
            showingPharmacy = !showingPharmacy; // 상태 토글
          });
          _searchNearby(showingPharmacy ? "약국" : "병원");
        },
        label: Text(
          showingPharmacy ? "병원 검색" : "약국 검색",
          style: const TextStyle(color: Colors.white),
        ),
        icon: Icon(
          showingPharmacy ? Icons.local_hospital : Icons.local_pharmacy,
          color: Colors.white,
        ),
        backgroundColor: Colors.indigoAccent,
      ),
    );
  }
}
