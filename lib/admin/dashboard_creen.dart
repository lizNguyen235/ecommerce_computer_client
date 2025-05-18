import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/service/DashboardService.dart';
import '../widgets/best_selling_chart.dart';
import '../widgets/timer_filter_widget.dart'; // Đảm bảo import đúng

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  static final NumberFormat _currencyFormatter = NumberFormat.currency(locale: 'en_US', symbol: '\$');
  static final NumberFormat _numberFormatter = NumberFormat.decimalPattern('en_US');

  int _totalUsers = 0;
  int _totalOverallOrders = 0;
  double _totalOverallRevenue = 0.0;
  // Timestamp? _globalLastUpdated; // Bạn có thể thêm nếu muốn hiển thị

  int _newUsersInPeriod = 0;
  int _ordersInPeriod = 0;
  double _revenueInPeriod = 0.0;
  List<Map<String, dynamic>> _bestSellingProductsInPeriod = [];

  bool _isLoadingInitialData = true;
  bool _isLoadingPeriodData = false;
  String? _errorMessage;
  bool _isMountedScreen = false;

  late TimeFilterResult _currentFilterResult;

  @override
  void initState() {
    super.initState();
    _isMountedScreen = true;
    print("DEBUG_SCREEN: DashboardScreen initState - START");

    _currentFilterResult = TimeFilterLogic.calculateTimeFilterResult(
      period: TimePeriod.monthly,
    );
    print("DEBUG_SCREEN: DashboardScreen initState - Initial filter calculated: ${_currentFilterResult.toString()}");

    _loadDashboardData(_currentFilterResult, isFullRefresh: true);
    print("DEBUG_SCREEN: DashboardScreen initState - END. _loadDashboardData called.");
  }

  @override
  void dispose() {
    _isMountedScreen = false;
    print("DEBUG_SCREEN: DashboardScreen dispose");
    super.dispose();
  }

  Future<void> _refreshData() async {
    print("DEBUG_SCREEN: DashboardScreen _refreshData triggered. Current filter: ${_currentFilterResult.toString()}");
    await _loadDashboardData(_currentFilterResult, isFullRefresh: true);
  }

  Future<void> _handleFilterChanged(TimeFilterResult filterResult) async {
    print("DEBUG_SCREEN: DashboardScreen _handleFilterChanged CALLED with: ${filterResult.toString()}");
    if (filterResult == _currentFilterResult) {
      print("DEBUG_SCREEN: DashboardScreen _handleFilterChanged - Filter result is IDENTICAL. No reload.");
      return;
    }
    await _loadDashboardData(filterResult, isFullRefresh: false);
  }

  Future<void> _loadDashboardData(
      TimeFilterResult newFilterResult, {
        required bool isFullRefresh,
      }) async {
    print("DEBUG_SCREEN: _loadDashboardData START - isFullRefresh: $isFullRefresh, New Filter: ${newFilterResult.toString()}");
    if (!_isMountedScreen) {
      print("DEBUG_SCREEN: _loadDashboardData: Widget unmounted. Aborting.");
      return;
    }

    setState(() {
      _currentFilterResult = newFilterResult;
      if (isFullRefresh) {
        _isLoadingInitialData = true;
      } else {
        _isLoadingPeriodData = true;
      }
      _errorMessage = null;
    });

    final DateTime startDate = _currentFilterResult.startDate;
    final DateTime endDate = _currentFilterResult.endDate;

    try {
      Map<String, dynamic> globalMetricsData = {}; // Khởi tạo để tránh lỗi null
      if (isFullRefresh || _totalUsers == 0) { // Hoặc một điều kiện khác để fetch lại global metrics
        print("DEBUG_SCREEN: _loadDashboardData - Fetching global metrics...");
        globalMetricsData = await _dashboardService.getGlobalMetrics();
        print("DEBUG_SCREEN: _loadDashboardData - Global metrics received from service: $globalMetricsData");
        if (!_isMountedScreen) return;
      }

      print("DEBUG_SCREEN: _loadDashboardData - Fetching period-specific data...");
      final newUsers = await _dashboardService.getNewUsersInRange(startDate, endDate);
      if (!_isMountedScreen) return;
      final ordersAndRevenueData = await _dashboardService.getOrdersAndRevenueInRange(startDate, endDate);
      if (!_isMountedScreen) return;
      final bestSelling = await _dashboardService.getBestSellingProductsFromSummary(limit: 5);
      if (!_isMountedScreen) return;

      setState(() {
        if (isFullRefresh || _totalUsers == 0) { // Chỉ cập nhật global metrics nếu đã fetch
          _totalUsers = (globalMetricsData['totalUsers'] as int?) ?? 0;
          _totalOverallOrders = (globalMetricsData['totalOrders'] as int?) ?? 0;
          _totalOverallRevenue = (globalMetricsData['totalRevenue'] as double?) ?? 0.0;
          // _globalLastUpdated = globalMetricsData['lastUpdated'] as Timestamp?;
          print("DEBUG_SCREEN: _loadDashboardData - ASSIGNED to state: Users: $_totalUsers, Orders: $_totalOverallOrders, Revenue: $_totalOverallRevenue");
        }

        _newUsersInPeriod = newUsers; // đã được đảm bảo là int từ service
        _ordersInPeriod = ordersAndRevenueData['ordersCount'] as int? ?? 0; // service trả về num, ép kiểu ở đây
        _revenueInPeriod = ordersAndRevenueData['revenue'] as double? ?? 0.0; // service trả về num
        _bestSellingProductsInPeriod = bestSelling; // đã được đảm bảo là List<Map> từ service

        if (isFullRefresh) _isLoadingInitialData = false;
        _isLoadingPeriodData = false;
      });
      print("DEBUG_SCREEN: _loadDashboardData END - UI should update. isLoadingInitial: $_isLoadingInitialData, isLoadingPeriod: $_isLoadingPeriodData");
    } on FirebaseException catch (e, s) {
      print("DEBUG_SCREEN: _loadDashboardData FIREBASE ERROR: ${e.code} - ${e.message}\n$s");
      if (!_isMountedScreen) return;
      setState(() {
        _isLoadingInitialData = false;
        _isLoadingPeriodData = false;
        _errorMessage = "Firestore Error: ${e.message ?? e.code}.";
      });
    } catch (e, s) {
      print("DEBUG_SCREEN: _loadDashboardData GENERIC ERROR: $e\n$s");
      if (!_isMountedScreen) return;
      setState(() {
        _isLoadingInitialData = false;
        _isLoadingPeriodData = false;
        _errorMessage = "Failed to load dashboard data: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(
      "DEBUG_SCREEN: DashboardScreen build - isLoadingInitial: $_isLoadingInitialData, isLoadingPeriod: $_isLoadingPeriodData, totalUsers: $_totalUsers, errorMessage: $_errorMessage",
    );
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: (_isLoadingInitialData && _totalUsers == 0 && _errorMessage == null)
            ? const Center(child: CircularProgressIndicator())
            : _buildDashboardContent(),
      ),
    );
  }

  Widget _buildDashboardContent() {
    print("DEBUG_SCREEN: _buildDashboardContent - Current Filter Label: ${_currentFilterResult.displayLabel}");
    if (_errorMessage != null && !_isLoadingInitialData && !_isLoadingPeriodData) {
      return _buildLoadingOrErrorWidget();
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle("Overall Store Performance"),
        // Hiển thị loading cho Overall Stats nếu đang tải initial và chưa có lỗi
        // và _totalUsers là 0 (nghĩa là chưa có dữ liệu global)
        if (_isLoadingInitialData && _totalUsers == 0 && _errorMessage == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text("Loading overall stats...")),
          )
        else
          _buildOverallStatsGrid(),

        const SizedBox(height: 24.0),
        _buildSectionTitle("${_currentFilterResult.displayLabel} Activity"),
        TimeFilterWidget(
          key: ValueKey(
            "TimeFilter_${_currentFilterResult.period}_${_currentFilterResult.startDate.millisecondsSinceEpoch}_${_currentFilterResult.endDate.millisecondsSinceEpoch}",
          ),
          initialPeriod: _currentFilterResult.period,
          initialCustomStartDate: _currentFilterResult.period == TimePeriod.custom ? _currentFilterResult.startDate : null,
          initialCustomEndDate: _currentFilterResult.period == TimePeriod.custom ? _currentFilterResult.endDate : null,
          onFilterChanged: _handleFilterChanged,
        ),
        if (_isLoadingPeriodData)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          )
        else
          Column(
            children: [
              const SizedBox(height: 8.0),
              _buildActivityMetrics(),
              const SizedBox(height: 24.0),
              _buildBestSellingProductsSection(
                context,
                _bestSellingProductsInPeriod,
                "Top Selling Products", // Tiêu đề có thể chung chung hơn
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildLoadingOrErrorWidget() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text("Retry"),
                onPressed: _refreshData,
              ),
            ],
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOverallStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
      childAspectRatio: MediaQuery.of(context).size.width > 900 ? 1.9 : (MediaQuery.of(context).size.width > 600 ? 1.7 : 1.6),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: [
        _buildMetricCard("Total Users", _numberFormatter.format(_totalUsers), Icons.group_add_rounded, Colors.teal.shade700),
        _buildMetricCard("Total Orders", _numberFormatter.format(_totalOverallOrders), Icons.inventory_2_outlined, Colors.blue.shade700),
        _buildMetricCard("Total Revenue", _currencyFormatter.format(_totalOverallRevenue), Icons.paid_outlined, Colors.deepPurple.shade700),
        _buildMetricCard(
          "Avg. Rev/Order",
          _totalOverallOrders > 0 ? _currencyFormatter.format(_totalOverallRevenue / _totalOverallOrders) : _currencyFormatter.format(0),
          Icons.price_check_outlined,
          Colors.pink.shade700,
        ),
      ],
    );
  }

  Widget _buildActivityMetrics() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
      childAspectRatio: MediaQuery.of(context).size.width > 900 ? 2.2 : (MediaQuery.of(context).size.width > 600 ? 1.9 : 1.8),
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      children: [
        _buildMetricCard("New Users", _numberFormatter.format(_newUsersInPeriod), Icons.person_add_alt_1_rounded, Colors.green.shade700),
        _buildMetricCard("Orders in Period", _numberFormatter.format(_ordersInPeriod), Icons.shopping_cart_rounded, Colors.orange.shade800),
        _buildMetricCard("Revenue in Period", _currencyFormatter.format(_revenueInPeriod), Icons.monetization_on_rounded, Colors.purple.shade700),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              radius: 20,
              child: Icon(icon, size: 22, color: color),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBestSellingProductsSection(BuildContext context, List<Map<String, dynamic>> productsData, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
            child: SizedBox(
              height: 280,
              child: productsData.isEmpty && !_isLoadingInitialData && !_isLoadingPeriodData
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text("No product sales data available for this selection.", textAlign: TextAlign.center),
                ),
              )
                  : BestSellingChart(data: productsData, maxItemsToShow: 5),
            ),
          ),
        ),
      ],
    );
  }
}