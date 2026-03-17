// lib/models/district.dart

enum FloodStatus { safe, risk, flood }

class District {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final FloodStatus status;
  final double waterLevel;
  final double rainfall;
  final double humidity;
  final double temperature;
  final String updatedAt;

  const District({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.status,
    required this.waterLevel,
    required this.rainfall,
    required this.humidity,
    required this.temperature,
    required this.updatedAt,
  });

  // สร้างจาก JSON (จาก API)
  factory District.fromJson(Map<String, dynamic> json) {
    FloodStatus parseStatus(String s) {
      switch (s) {
        case 'flood': return FloodStatus.flood;
        case 'risk':  return FloodStatus.risk;
        default:      return FloodStatus.safe;
      }
    }
    return District(
      id:          json['districtId'] ?? '',
      name:        json['districtName'] ?? '',
      lat:         (json['lat'] ?? 0).toDouble(),
      lng:         (json['lng'] ?? 0).toDouble(),
      status:      parseStatus(json['status'] ?? 'safe'),
      waterLevel:  (json['waterLevel'] ?? 0).toDouble(),
      rainfall:    (json['rainfall'] ?? 0).toDouble(),
      humidity:    (json['humidity'] ?? 0).toDouble(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      updatedAt:   json['fetchedAt'] ?? '',
    );
  }

  String get statusLabel {
    switch (status) {
      case FloodStatus.flood: return 'น้ำท่วม';
      case FloodStatus.risk:  return 'เฝ้าระวัง';
      case FloodStatus.safe:  return 'ปกติ';
    }
  }

  String get statusEmoji {
    switch (status) {
      case FloodStatus.flood: return '🔴';
      case FloodStatus.risk:  return '🟠';
      case FloodStatus.safe:  return '🟢';
    }
  }
}

// ── ข้อมูลจำลอง (ใช้ระหว่างยังไม่มี API จริง) ──────────────
final List<District> mockDistricts = [
  const District(id: 'mueang',       name: 'เมืองชลบุรี',  lat: 13.3611, lng: 100.9847, status: FloodStatus.safe,  waterLevel: 12, rainfall: 2.1,  humidity: 68, temperature: 31, updatedAt: '10:00'),
  const District(id: 'banbueng',     name: 'บ้านบึง',       lat: 13.2456, lng: 101.1057, status: FloodStatus.safe,  waterLevel: 18, rainfall: 5.4,  humidity: 72, temperature: 30, updatedAt: '10:00'),
  const District(id: 'nongya',       name: 'หนองใหญ่',      lat: 13.1556, lng: 101.2031, status: FloodStatus.risk,  waterLevel: 65, rainfall: 18.2, humidity: 85, temperature: 28, updatedAt: '10:00'),
  const District(id: 'banglamung',   name: 'บางละมุง',      lat: 12.9236, lng: 100.8775, status: FloodStatus.safe,  waterLevel: 8,  rainfall: 1.5,  humidity: 65, temperature: 33, updatedAt: '10:00'),
  const District(id: 'phantong',     name: 'พานทอง',        lat: 13.4501, lng: 101.1155, status: FloodStatus.risk,  waterLevel: 71, rainfall: 22.0, humidity: 88, temperature: 27, updatedAt: '10:00'),
  const District(id: 'phanasnikom',  name: 'พนัสนิคม',      lat: 13.4498, lng: 101.1842, status: FloodStatus.flood, waterLevel: 95, rainfall: 38.5, humidity: 95, temperature: 26, updatedAt: '10:00'),
  const District(id: 'sriracha',     name: 'ศรีราชา',       lat: 13.1282, lng: 100.9280, status: FloodStatus.safe,  waterLevel: 15, rainfall: 3.2,  humidity: 70, temperature: 32, updatedAt: '10:00'),
  const District(id: 'kosichang',    name: 'เกาะสีชัง',     lat: 13.1518, lng: 100.8044, status: FloodStatus.safe,  waterLevel: 5,  rainfall: 0.8,  humidity: 62, temperature: 34, updatedAt: '10:00'),
  const District(id: 'sattahip',     name: 'สัตหีบ',        lat: 12.6617, lng: 100.9015, status: FloodStatus.safe,  waterLevel: 22, rainfall: 6.1,  humidity: 74, temperature: 30, updatedAt: '10:00'),
  const District(id: 'borthong',     name: 'บ่อทอง',        lat: 13.3045, lng: 101.2888, status: FloodStatus.flood, waterLevel: 88, rainfall: 42.1, humidity: 93, temperature: 25, updatedAt: '10:00'),
  const District(id: 'kochan',       name: 'เกาะจันทร์',    lat: 13.5201, lng: 101.2102, status: FloodStatus.risk,  waterLevel: 58, rainfall: 16.7, humidity: 82, temperature: 28, updatedAt: '10:00'),
];
