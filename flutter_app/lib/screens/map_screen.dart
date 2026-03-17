// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme/app_theme.dart';
import '../models/district.dart';
import '../widgets/district_detail_sheet.dart';

class MapScreen extends StatefulWidget {
  final List<District> districts;
  const MapScreen({super.key, required this.districts});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  District? _selectedDistrict;

  Color _statusColor(FloodStatus s) {
    switch (s) {
      case FloodStatus.flood: return AppColors.flood;
      case FloodStatus.risk:  return AppColors.risk;
      case FloodStatus.safe:  return AppColors.safe;
    }
  }

  void _onMarkerTap(District d) {
    setState(() => _selectedDistrict = d);
    // บิน map ไปที่อำเภอที่กด
    _mapController.move(LatLng(d.lat, d.lng), 11.5);
    // เปิด bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DistrictDetailSheet(district: d),
    ).then((_) => setState(() => _selectedDistrict = null));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── แผนที่หลัก ───────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(13.15, 101.0),
            initialZoom: 9.5,
            minZoom: 7,
            maxZoom: 16,
          ),
          children: [
            // Tile layer (OpenStreetMap)
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flood_alert_chonburi',
            ),

            // ── Circle แต่ละอำเภอ (แสดงสีความเสี่ยง) ────────
            CircleLayer(
              circles: widget.districts.map((d) {
                final color = _statusColor(d.status);
                final isSelected = _selectedDistrict?.id == d.id;
                return CircleMarker(
                  point: LatLng(d.lat, d.lng),
                  radius: isSelected ? 28 : 22,
                  color: color.withOpacity(0.35),
                  borderColor: color,
                  borderStrokeWidth: isSelected ? 3 : 2,
                  useRadiusInMeter: false,
                );
              }).toList(),
            ),

            // ── Marker (กดได้) ────────────────────────────────
            MarkerLayer(
              markers: widget.districts.map((d) {
                final color = _statusColor(d.status);
                final isSelected = _selectedDistrict?.id == d.id;
                return Marker(
                  point: LatLng(d.lat, d.lng),
                  width: 120,
                  height: 64,
                  child: GestureDetector(
                    onTap: () => _onMarkerTap(d),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pin icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 36 : 28,
                          height: isSelected ? 36 : 28,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.6),
                                blurRadius: isSelected ? 16 : 8,
                                spreadRadius: isSelected ? 3 : 1,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              d.statusEmoji,
                              style: TextStyle(fontSize: isSelected ? 16 : 12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        // ชื่ออำเภอ
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: color.withOpacity(0.5), width: 1),
                          ),
                          child: Text(
                            d.name,
                            style: TextStyle(
                              color: isSelected ? color : Colors.white,
                              fontSize: 9,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),

        // ── Legend (มุมล่างซ้าย) ──────────────────────────────
        Positioned(
          bottom: 16,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.panel.withOpacity(0.92),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _legendRow(AppColors.safe,  '🟢 ปกติ'),
                const SizedBox(height: 5),
                _legendRow(AppColors.risk,  '🟠 เฝ้าระวัง'),
                const SizedBox(height: 5),
                _legendRow(AppColors.flood, '🔴 น้ำท่วม'),
              ],
            ),
          ),
        ),

        // ── ปุ่ม Reset zoom ───────────────────────────────────
        Positioned(
          bottom: 16,
          right: 12,
          child: Column(
            children: [
              _mapBtn(Icons.add_rounded, () =>
                  _mapController.move(_mapController.camera.center,
                      _mapController.camera.zoom + 1)),
              const SizedBox(height: 6),
              _mapBtn(Icons.remove_rounded, () =>
                  _mapController.move(_mapController.camera.center,
                      _mapController.camera.zoom - 1)),
              const SizedBox(height: 6),
              _mapBtn(Icons.my_location_rounded, () =>
                  _mapController.move(const LatLng(13.15, 101.0), 9.5)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendRow(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(
          color: AppColors.textSecondary, fontSize: 11,
        )),
      ],
    );
  }

  Widget _mapBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
    );
  }
}
