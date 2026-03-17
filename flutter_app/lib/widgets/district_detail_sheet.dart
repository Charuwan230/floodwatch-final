// lib/widgets/district_detail_sheet.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/district.dart';

class DistrictDetailSheet extends StatelessWidget {
  final District district;
  const DistrictDetailSheet({super.key, required this.district});

  Color get _color {
    switch (district.status) {
      case FloodStatus.flood: return AppColors.flood;
      case FloodStatus.risk:  return AppColors.risk;
      case FloodStatus.safe:  return AppColors.safe;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: _color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _color.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(district.statusEmoji,
                    style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(district.name, style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 18, fontWeight: FontWeight.w700,
                    )),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: _color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        district.status == FloodStatus.flood
                            ? '🚨 น้ำท่วมวิกฤต'
                            : district.status == FloodStatus.risk
                                ? '⚠️ เฝ้าระวัง — มีความเสี่ยง'
                                : '✅ ปกติ — ไม่มีความเสี่ยง',
                        style: TextStyle(
                          color: _color, fontSize: 12, fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Water Level Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('ระดับน้ำ', style: TextStyle(
                    color: AppColors.textMuted, fontSize: 12,
                  )),
                  Text('${district.waterLevel.toStringAsFixed(0)}%',
                    style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: district.waterLevel / 100,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation(_color),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Data Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.4,
            children: [
              _dataBox('💧 ระดับน้ำ', '${district.waterLevel.toStringAsFixed(1)} ซม.'),
              _dataBox('🌧 ปริมาณฝน', '${district.rainfall.toStringAsFixed(1)} มม.'),
              _dataBox('💨 ความชื้น', '${district.humidity.toStringAsFixed(0)}%'),
              _dataBox('🌡 อุณหภูมิ', '${district.temperature.toStringAsFixed(1)}°C'),
            ],
          ),

          const SizedBox(height: 16),

          // Updated at
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time_rounded,
                color: AppColors.textMuted, size: 13),
              const SizedBox(width: 4),
              Text('อัปเดตล่าสุด: ${district.updatedAt}',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dataBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1020),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(
            color: AppColors.textMuted, fontSize: 11,
          )),
          const SizedBox(height: 3),
          Text(value, style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14, fontWeight: FontWeight.w700,
          )),
        ],
      ),
    );
  }
}
