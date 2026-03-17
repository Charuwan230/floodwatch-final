// lib/widgets/status_summary.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/district.dart';

class StatusSummary extends StatelessWidget {
  final List<District> districts;
  const StatusSummary({super.key, required this.districts});

  @override
  Widget build(BuildContext context) {
    final safe  = districts.where((d) => d.status == FloodStatus.safe).length;
    final risk  = districts.where((d) => d.status == FloodStatus.risk).length;
    final flood = districts.where((d) => d.status == FloodStatus.flood).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _statBox(safe.toString(),  'ปกติ',      AppColors.safe),
          _divider(),
          _statBox(risk.toString(),  'เฝ้าระวัง', AppColors.risk),
          _divider(),
          _statBox(flood.toString(), 'น้ำท่วม',   AppColors.flood),
        ],
      ),
    );
  }

  Widget _statBox(String num, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(num, style: TextStyle(
              color: color, fontSize: 22, fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(
              color: AppColors.textMuted, fontSize: 11,
            )),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const SizedBox(width: 8);
}
