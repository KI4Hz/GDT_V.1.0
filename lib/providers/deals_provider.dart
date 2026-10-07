import 'package:flutter/material.dart';
import '../models/deal_model.dart';
import '../models/store_model.dart';
import '../services/cheapshark_service.dart';

class SortOption {
  final String label;
  final String? sortBy;
  final int? desc;
  final IconData icon;

  const SortOption({
    required this.label,
    this.sortBy,
    this.desc,
    required this.icon,
  });
}

/// Provider สำหรับจัดการดึงข้อมูลดีลเกม, ฟิลเตอร์ร้านค้า, การค้นหา และการเรียงลำดับ
class DealsProvider with ChangeNotifier {
  final CheapSharkService _apiService;

  DealsProvider({CheapSharkService? apiService})
    : _apiService = apiService ?? CheapSharkService() {
    fetchDeals();
    fetchStores();
  }

  // Store Filter Chips options
  static final List<Map<String, dynamic>> storeFilterOptions = [
    {'label': 'All Stores', 'storeID': null},
    {'label': 'Steam', 'storeID': '1'},
    {'label': 'Epic Games', 'storeID': '25'},
    {'label': 'GOG', 'storeID': '7'},
    {'label': 'Fanatical', 'storeID': '15'},
    {'label': 'Humble Store', 'storeID': '11'},
    {'label': 'GreenManGaming', 'storeID': '3'},
    {'label': 'GamersGate', 'storeID': '2'},
  ];

  static const List<SortOption> sortOptions = [
    SortOption(
      label: 'Featured Deals',
      sortBy: 'Deal Rating',
      desc: 0,
      icon: Icons.local_fire_department_rounded,
    ),
    SortOption(
      label: 'Price: High to Low ',
      sortBy: 'Price',
      desc: 1,
      icon: Icons.arrow_downward_rounded,
    ),
    SortOption(
      label: 'Price: Low to High ',
      sortBy: 'Price',
      desc: 0,
      icon: Icons.arrow_upward_rounded,
    ),
    SortOption(
      label: 'Top Discount %',
      sortBy: 'Savings',
      desc: 0,
      icon: Icons.percent_rounded,
    ),
    SortOption(
      label: 'Highest Rated (Metacritic)',
      sortBy: 'Metacritic',
      desc: 0,
      icon: Icons.star_rounded,
    ),
  ];

  List<DealModel> _deals = [];
  List<StoreModel> _stores = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _pageNumber = 0;
  bool _hasMore = true;

  int _selectedStoreFilterIndex = 0;
  int _selectedSortIndex = 0;
  String _searchQuery = '';

  // Getters
  List<DealModel> get deals => _deals;
  List<StoreModel> get stores => _stores;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  int get selectedStoreFilterIndex => _selectedStoreFilterIndex;
  int get selectedSortIndex => _selectedSortIndex;
  String get searchQuery => _searchQuery;

  SortOption get currentSort => sortOptions[_selectedSortIndex];
  String? get selectedStoreId =>
      storeFilterOptions[_selectedStoreFilterIndex]['storeID'];

  // ดึงรายชื่อร้านค้า
  Future<void> fetchStores() async {
    try {
      _stores = await _apiService.getStores();
      notifyListeners();
    } catch (_) {}
  }

  // ดึงรายการดีล (รีเฟรชหรือเปลี่ยนตัวกรอง)
  Future<void> fetchDeals({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    _pageNumber = 0;
    _hasMore = true;

    try {
      final currentStore = selectedStoreId;
      final currentSortOption = currentSort;

      final results = await _apiService.getDeals(
        storeID: currentStore,
        title: _searchQuery.isEmpty ? null : _searchQuery,
        sortBy: currentSortOption.sortBy,
        desc: currentSortOption.desc,
        pageNumber: _pageNumber,
        pageSize: 40,
      );

      _deals = results;
      _errorMessage = null;
      if (results.length < 40) {
        _hasMore = false;
      }
    } catch (e) {
      _errorMessage = 'ไม่สามารถโหลดดีลเกมได้ กรุณาลองใหม่อีกครั้ง';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // โหลดหน้าถัดไป (Pagination)
  Future<void> fetchMoreDeals() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _pageNumber + 1;
      final currentStore = selectedStoreId;
      final currentSortOption = currentSort;

      final moreDeals = await _apiService.getDeals(
        storeID: currentStore,
        title: _searchQuery.isEmpty ? null : _searchQuery,
        sortBy: currentSortOption.sortBy,
        desc: currentSortOption.desc,
        pageNumber: nextPage,
        pageSize: 40,
      );

      if (moreDeals.isEmpty) {
        _hasMore = false;
      } else {
        _pageNumber = nextPage;
        _deals.addAll(moreDeals);
        if (moreDeals.length < 40) {
          _hasMore = false;
        }
      }
    } catch (_) {
      // Handle pagination error gracefully
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // เปลี่ยนร้านค้าที่ต้องการกรอง
  void setStoreFilter(int index) {
    if (_selectedStoreFilterIndex == index) return;
    _selectedStoreFilterIndex = index;
    fetchDeals();
  }

  // เปลี่ยนการเรียงลำดับ (Sort)
  void setSortIndex(int index) {
    if (_selectedSortIndex == index) return;
    _selectedSortIndex = index;
    fetchDeals();
  }

  // ค้นหาตามชื่อเกม
  void setSearchQuery(String query) {
    final trimmed = query.trim();
    if (_searchQuery == trimmed) return;
    _searchQuery = trimmed;
    fetchDeals();
  }

  // รีเฟรชข้อมูล (เช่น Pull to Refresh)
  Future<void> refresh() => fetchDeals(showLoading: false);
}
