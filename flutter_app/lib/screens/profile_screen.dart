// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../models/district.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _selectedDistrictId;
  String? _testDistrictId;
  bool    _notifyRisk  = true;
  bool    _notifyFlood = true;
  bool    _notifySafe  = false;
  bool    _saving  = false;
  bool    _testing = false;

  final _subdistrictCtrl = TextEditingController();
  final _villageCtrl     = TextEditingController();
  final _houseDetailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  @override
  void dispose() {
    _subdistrictCtrl.dispose();
    _villageCtrl.dispose();
    _houseDetailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDistrictId   = prefs.getString('districtId');
      _subdistrictCtrl.text = prefs.getString('subdistrict') ?? '';
      _villageCtrl.text     = prefs.getString('village')     ?? '';
      _houseDetailCtrl.text = prefs.getString('houseDetail') ?? '';
      _notifyFlood = prefs.getBool('notifyFlood') ?? true;
      _notifyRisk  = prefs.getBool('notifyRisk')  ?? true;
      _notifySafe  = prefs.getBool('notifySafe')  ?? false;
    });
  }

  Future<void> _save() async {
    if (_selectedDistrictId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกอำเภอก่อนครับ')),
      );
      return;
    }
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('districtId',  _selectedDistrictId!);
    await prefs.setString('subdistrict', _subdistrictCtrl.text);
    await prefs.setString('village',     _villageCtrl.text);
    await prefs.setString('houseDetail', _houseDetailCtrl.text);
    await prefs.setBool('notifyFlood',   _notifyFlood);
    await prefs.setBool('notifyRisk',    _notifyRisk);
    await prefs.setBool('notifySafe',    _notifySafe);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('✅  บันทึกสำเร็จ!'),
        backgroundColor: AppColors.safe,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.panel,
        elevation: 0,
        title: const Text('⚙️  ตั้งค่า', style: TextStyle(
          color: AppColors.accent, fontWeight: FontWeight.w700, fontSize: 16,
        )),
        iconTheme: const IconThemeData(color: AppColors.textSecondary),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(color: AppColors.border, height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildUserCard(),
          const SizedBox(height: 16),
          _buildAddressCard(),
          const SizedBox(height: 16),
          _buildNotificationCard(),
          const SizedBox(height: 24),
          _buildSaveButton(),
          const SizedBox(height: 16),
          _buildTestCard(),
          const SizedBox(height: 16),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildUserCard() {
    return _card(
      title: '👤  ข้อมูลผู้ใช้',
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accentDark, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Center(child: Text('👤', style: TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ผู้ใช้งาน', style: TextStyle(
                  color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700,
                )),
                SizedBox(height: 3),
                Text('user@gmail.com', style: TextStyle(
                  color: AppColors.textMuted, fontSize: 13,
                )),
                SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.check_circle, color: AppColors.safe, size: 13),
                  SizedBox(width: 4),
                  Text('เชื่อมต่อผ่าน Google', style: TextStyle(
                    color: AppColors.safe, fontSize: 11,
                  )),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return _card(
      title: '🏠  ที่อยู่อาศัย',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _selectedDistrictId,
            decoration: _inputDeco('เลือกอำเภอที่คุณอาศัยอยู่ *'),
            dropdownColor: const Color(0xFF0A1020),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            items: mockDistricts.map((d) => DropdownMenuItem(
              value: d.id,
              child: Row(children: [
                Text(d.statusEmoji),
                const SizedBox(width: 8),
                Text(d.name),
              ]),
            )).toList(),
            onChanged: (v) => setState(() => _selectedDistrictId = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _subdistrictCtrl,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: _inputDeco('ตำบล / แขวง *'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _villageCtrl,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: _inputDeco('หมู่บ้าน / ซอย / ถนน'),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _houseDetailCtrl,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            decoration: _inputDeco('บ้านเลขที่ / อาคาร'),
          ),
          if (_selectedDistrictId != null) ...[
            const SizedBox(height: 12),
            _selectedDistrictStatus(),
          ],
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accentDark.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accent.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.accent, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'ข้อมูลที่อยู่ช่วยให้ระบบแจ้งเตือนได้แม่นยำขึ้น',
                    style: TextStyle(color: AppColors.accent, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectedDistrictStatus() {
    final d = mockDistricts.firstWhere((x) => x.id == _selectedDistrictId);
    final color = d.status == FloodStatus.flood
        ? AppColors.flood
        : d.status == FloodStatus.risk ? AppColors.risk : AppColors.safe;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(d.statusEmoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('สถานะปัจจุบัน: ${d.statusLabel}',
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('ระดับน้ำ ${d.waterLevel.toStringAsFixed(0)} ซม. · ฝน ${d.rainfall.toStringAsFixed(1)} มม.',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return _card(
      title: '🔔  การแจ้งเตือน',
      child: Column(
        children: [
          _toggle('🔴  น้ำท่วมวิกฤต', 'แจ้งด่วนเมื่อน้ำท่วมรุนแรง',
              _notifyFlood, (v) => setState(() => _notifyFlood = v)),
          const Divider(color: AppColors.border, height: 1),
          _toggle('🟠  เฝ้าระวัง', 'แจ้งเมื่อมีความเสี่ยงน้ำท่วม',
              _notifyRisk, (v) => setState(() => _notifyRisk = v)),
          const Divider(color: AppColors.border, height: 1),
          _toggle('🟢  สถานะปกติ', 'แจ้งเมื่อพื้นที่กลับมาปกติ',
              _notifySafe, (v) => setState(() => _notifySafe = v)),
        ],
      ),
    );
  }

  Widget _toggle(String title, String desc, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600,
              )),
              const SizedBox(height: 2),
              Text(desc, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          )),
          Switch(
            value: value, onChanged: onChanged,
            activeColor: AppColors.accent,
            inactiveTrackColor: AppColors.border,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.bg,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _saving
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.bg))
            : const Text('💾  บันทึกการตั้งค่า',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildTestCard() {
    return _card(
      title: '🧪  ทดสอบระบบแจ้งเตือน',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'จำลองสถานการณ์น้ำท่วมเพื่อทดสอบว่าได้รับแจ้งเตือนหรือไม่',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _testDistrictId,
            decoration: _inputDeco('เลือกอำเภอที่จะจำลอง'),
            dropdownColor: const Color(0xFF0A1020),
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
            items: mockDistricts.map((d) => DropdownMenuItem(
              value: d.id,
              child: Text(d.name),
            )).toList(),
            onChanged: (v) => setState(() => _testDistrictId = v),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _testButton('🟠 เฝ้าระวัง', AppColors.risk,  'risk')),
              const SizedBox(width: 8),
              Expanded(child: _testButton('🔴 น้ำท่วม',   AppColors.flood, 'flood')),
              const SizedBox(width: 8),
              Expanded(child: _testButton('🟢 ปกติ',       AppColors.safe,  'safe')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _testButton(String label, Color color, String status) {
    return ElevatedButton(
      onPressed: _testing || _testDistrictId == null ? null : () async {
        setState(() => _testing = true);
        final ok = await ApiService().simulateFlood(_testDistrictId!, status);
        if (mounted) {
          setState(() => _testing = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(ok ? '✅ จำลองสำเร็จ รอรับแจ้งเตือน!' : '❌ ไม่สำเร็จ ตรวจสอบ Backend'),
            backgroundColor: ok ? AppColors.safe : AppColors.flood,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: _testing
          ? SizedBox(width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: color))
          : Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textMuted,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text('ออกจากระบบ', style: TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(
            color: AppColors.accent, fontSize: 13,
            fontWeight: FontWeight.w700, letterSpacing: 0.5,
          )),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF0A1020),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}