import 'package:flutter/foundation.dart';
import '../services/currency_service.dart';

/// Provider สำหรับจัดการค่าเงิน (THB / USD) และอัตราแลกเปลี่ยน
class CurrencyProvider with ChangeNotifier {
  final CurrencyService _service = CurrencyService();

  CurrencyProvider() {
    _service.addListener(_onServiceChanged);
  }

  void _onServiceChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceChanged);
    super.dispose();
  }

  bool get useThb => _service.useThb;
  double get usdToThbRate => _service.usdToThbRate;
  String get currencySymbol => _service.currencySymbol;
  String get currencyCode => _service.currencyCode;

  void toggleCurrency() {
    _service.toggleCurrency();
  }

  void setUseThb(bool value) {
    _service.setUseThb(value);
  }

  Future<void> fetchLiveRate() => _service.fetchLiveRate();

  String formatPrice(dynamic usdPrice, {bool includeDecimals = true}) =>
      _service.formatPrice(usdPrice, includeDecimals: includeDecimals);
}
