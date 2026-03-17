// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/district.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:4000/api';

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final _client = http.Client();
  String _token = '';
  void setToken(String token) => _token = token;

  // ── ดึงข้อมูลทุกอำเภอ ─────────────────────────────────────
  Future<List<District>> getAllDistricts() async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/flood'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final List data = json['data'] as List;
        return data.map((item) {
          final meta = _districtMeta[item['districtId']];
          return District(
            id:          item['districtId'] ?? '',
            name:        item['districtName'] ?? '',
            lat:         meta?['lat'] ?? 13.36,
            lng:         meta?['lng'] ?? 100.98,
            status:      _parseStatus(item['status']),
            waterLevel:  (item['waterLevel'] ?? 0).toDouble(),
            rainfall:    (item['rainfall'] ?? 0).toDouble(),
            humidity:    (item['humidity'] ?? 0).toDouble(),
            temperature: (item['temperature'] ?? 0).toDouble(),
            updatedAt:   item['fetchedAt'] ?? '',
          );
        }).toList();
      } else {
        throw Exception('API Error: ${res.statusCode}');
      }
    } catch (e) {
      print('[API] Fallback to mock data: $e');
      return mockDistricts;
    }
  }

  // ── ดึงข้อมูลอำเภอเดียว ───────────────────────────────────
  Future<District?> getDistrict(String districtId) async {
    try {
      final res = await _client
          .get(Uri.parse('$baseUrl/flood/$districtId'))
          .timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        final item = json['data'];
        final meta = _districtMeta[districtId];
        return District(
          id:          item['districtId'],
          name:        item['districtName'],
          lat:         meta?['lat'] ?? 13.36,
          lng:         meta?['lng'] ?? 100.98,
          status:      _parseStatus(item['status']),
          waterLevel:  (item['waterLevel'] ?? 0).toDouble(),
          rainfall:    (item['rainfall'] ?? 0).toDouble(),
          humidity:    (item['humidity'] ?? 0).toDouble(),
          temperature: (item['temperature'] ?? 0).toDouble(),
          updatedAt:   item['fetchedAt'] ?? '',
        );
      }
    } catch (e) {
      print('[API] getDistrict error: $e');
    }
    return null;
  }

  // ── บันทึก FCM Token ───────────────────────────────────────
  Future<void> saveNotifications(Map<String, dynamic> data) async {
    try {
      await _client
          .put(
            Uri.parse('$baseUrl/user/notifications'),
            headers: {
              'Content-Type': 'application/json',
              if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      print('[API] saveNotifications error: $e');
    }
  }

  // ── Sign In ────────────────────────────────────────────────
  Future<void> signIn() async {
    try {
      await _client
          .post(
            Uri.parse('$baseUrl/auth/signin'),
            headers: {
              'Content-Type': 'application/json',
              if (_token.isNotEmpty) 'Authorization': 'Bearer $_token',
            },
          )
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      print('[API] signIn error: $e');
    }
  }

  // ── ทดสอบแจ้งเตือน ────────────────────────────────────────
  Future<bool> testNotification() async {
    try {
      final res = await _client
          .post(Uri.parse('$baseUrl/alerts/test'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      print('[API] testNotification error: $e');
      return false;
    }
  }

  // ── จำลองน้ำท่วม ───────────────────────────────────────────
  Future<bool> simulateFlood(String districtId, String status) async {
    try {
      final res = await _client
          .post(Uri.parse('$baseUrl/alerts/simulate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'districtId': districtId, 'status': status}),
          )
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      print('[API] simulateFlood error: $e');
      return false;
    }
  }

  FloodStatus _parseStatus(String? s) {
    switch (s) {
      case 'flood': return FloodStatus.flood;
      case 'risk':  return FloodStatus.risk;
      default:      return FloodStatus.safe;
    }
  }

  static const Map<String, Map<String, double>> _districtMeta = {
    'mueang':       {'lat': 13.3611, 'lng': 100.9847},
    'banbueng':     {'lat': 13.2456, 'lng': 101.1057},
    'nongya':       {'lat': 13.1556, 'lng': 101.2031},
    'banglamung':   {'lat': 12.9236, 'lng': 100.8775},
    'phantong':     {'lat': 13.4501, 'lng': 101.1155},
    'phanasnikom':  {'lat': 13.4498, 'lng': 101.1842},
    'sriracha':     {'lat': 13.1282, 'lng': 100.9280},
    'kosichang':    {'lat': 13.1518, 'lng': 100.8044},
    'sattahip':     {'lat': 12.6617, 'lng': 100.9015},
    'borthong':     {'lat': 13.3045, 'lng': 101.2888},
    'kochan':       {'lat': 13.5201, 'lng': 101.2102},
  };
}