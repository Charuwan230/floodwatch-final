// lib/widgets/district_card.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/district.dart';

class DistrictCard extends StatelessWidget {
  final District district;
  final VoidCallback onTap;

  const DistrictCard({super.key, required this.district, required this.onTap});

  Color get _statusColor {
    switch (district.status) {
      case FloodStatus.flood: return AppColors.flood;
      case FloodStatus.risk:  return AppColors.risk;
      case FloodStatus.safe:  return AppColors.safe;
    }
  }

  Color get _statusBg {
    switch (district.status) {
      case FloodStatus.flood: return AppColors.floodBg;
      case FloodStatus.risk:  return AppColors.riskBg;
      case FloodStatus.safe:  return AppColors.safeBg;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: district.status == FloodStatus.flood
                ? AppColors.flood.withOpacity(0.5)
                : AppColors.border,
            width: district.status == FloodStatus.flood ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 12, height: 12,
              decoration: BoxDecoration(
                color: _statusColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(
                  color: _statusColor.withOpacity(0.5),
                  blurRadius: 6, spreadRadius: 1,
                )],
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(district.name, style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15, fontWeight: FontWeight.w600,
                  )),
                  const SizedBox(height: 3),
                  Text(
                    'น้ำ ${district.waterLevel.toStringAsFixed(0)} ซม. · ฝน ${district.rainfall.toStringAsFixed(1)} มม./ชม.',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _statusColor.withOpacity(0.4)),
              ),
              child: Text(
                district.statusLabel,
                style: TextStyle(
                  color: _statusColor, fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}
