// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../models/district.dart';
import '../services/api_service.dart';
import '../widgets/district_card.dart';
import '../widgets/district_detail_sheet.dart';
import '../widgets/status_summary.dart';
import 'map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  List<District> _districts = [];
  bool _isLoading = true;
  bool _isApiConnected = false;
  Timer? _refreshTimer;
  late TabController _tabController;
  final _api = ApiService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) => _loadData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final districts = await _api.getAllDistricts();
      // ตรวจว่าได้จาก API จริงหรือ mock
      final fromApi = districts.isNotEmpty &&
          districts.first.updatedAt.contains('T'); // ISO format = API จริง
      if (mounted) {
        setState(() {
          _districts = districts;
          _isLoading = false;
          _isApiConnected = fromApi;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openDetail(District d) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DistrictDetailSheet(district: d),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            if (!_isLoading) ...[
              StatusSummary(districts: _districts),
              _buildFloodAlert(),
              // Tab bar: แผนที่ / รายการ
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: แผนที่
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                        : MapScreen(districts: _districts),
                    // Tab 2: รายการ
                    _buildDistrictList(),
                  ],
                ),
              ),
            ] else
              const Expanded(child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 16),
                    Text('กำลังโหลดข้อมูล...', style: TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              )),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    final now = TimeOfDay.now();
    final timeStr = '${now.hour.toString().padLeft(2,'0')}:${now.minute.toString().padLeft(2,'0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066CC), AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Center(child: Text('🌊', style: TextStyle(fontSize: 16))),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FLOOD WATCH', style: TextStyle(
                  color: AppColors.accent, fontSize: 13,
                  fontWeight: FontWeight.w700, letterSpacing: 1.5,
                )),
                Text('จังหวัดชลบุรี', style: TextStyle(
                  color: AppColors.textMuted, fontSize: 10,
                )),
              ],
            ),
          ),
          // API Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: (_isApiConnected ? AppColors.safe : AppColors.risk).withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (_isApiConnected ? AppColors.safe : AppColors.risk).withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 5, height: 5,
                  decoration: BoxDecoration(
                    color: _isApiConnected ? AppColors.safe : AppColors.risk,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _isApiConnected ? 'API' : 'Demo',
                  style: TextStyle(
                    color: _isApiConnected ? AppColors.safe : AppColors.risk,
                    fontSize: 9, fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Live badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.floodBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.flood.withOpacity(0.4)),
            ),
            child: Row(children: [
              Container(width: 5, height: 5,
                decoration: const BoxDecoration(color: AppColors.flood, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              const Text('LIVE', style: TextStyle(
                color: AppColors.flood, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1,
              )),
            ]),
          ),
          const SizedBox(width: 8),
          Text(timeStr, style: const TextStyle(
            color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600,
          )),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _loadData,
            child: const Icon(Icons.refresh_rounded, color: AppColors.textMuted, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppColors.panel,
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.accent,
        indicatorWeight: 2,
        labelColor: AppColors.accent,
        unselectedLabelColor: AppColors.textMuted,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(icon: Icon(Icons.map_rounded, size: 18), text: 'แผนที่'),
          Tab(icon: Icon(Icons.list_rounded, size: 18), text: 'รายการ'),
        ],
      ),
    );
  }

  Widget _buildFloodAlert() {
    final floods = _districts.where((d) => d.status == FloodStatus.flood).toList();
    final risks  = _districts.where((d) => d.status == FloodStatus.risk).toList();
    if (floods.isEmpty && risks.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      color: AppColors.flood.withOpacity(0.08),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.flood, borderRadius: BorderRadius.circular(4)),
            child: const Text('⚠ แจ้งเตือน', style: TextStyle(
              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700,
            )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              floods.isNotEmpty
                  ? '🚨 น้ำท่วมวิกฤต: ${floods.map((d) => d.name).join(', ')}'
                  : '⚠️ เฝ้าระวัง: ${risks.map((d) => d.name).join(', ')}',
              style: const TextStyle(color: AppColors.flood, fontSize: 11),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistrictList() {
    final sorted = [..._districts]..sort((a, b) {
      final order = {FloodStatus.flood: 0, FloodStatus.risk: 1, FloodStatus.safe: 2};
      return order[a.status]!.compareTo(order[b.status]!);
    });
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: sorted.length,
        itemBuilder: (_, i) => DistrictCard(
          district: sorted[i],
          onTap: () => _openDetail(sorted[i]),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.panel,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'หน้าหลัก', true),
              _navItem(Icons.person_rounded, 'โปรไฟล์', false,
                  onTap: () => Navigator.pushNamed(context, '/profile')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.accent : AppColors.textMuted, size: 20),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(
              color: isActive ? AppColors.accent : AppColors.textMuted,
              fontSize: 10, fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}
