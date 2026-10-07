import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class CurrencyService with ChangeNotifier {
  static final CurrencyService _instance = CurrencyService._internal();
  factory CurrencyService() => _instance;
  CurrencyService._internal() {
    fetchLiveRate();
  }

  // อัตราแลกเปลี่ยนเริ่มต้น (Fallback) หากยังไม่ได้ดึงจาก API
  double _usdToThbRate = 35.0;
  bool _useThb = true; // ค่าเริ่มต้นให้แสดงเป็น THB (฿) ตามที่ต้องการ

  bool get useThb => _useThb;
  double get usdToThbRate => _usdToThbRate;
  String get currencySymbol => _useThb ? '฿' : '\$';
  String get currencyCode => _useThb ? 'THB' : 'USD';

  void setUseThb(bool value) {
    if (_useThb != value) {
      _useThb = value;
      notifyListeners();
    }
  }

  void toggleCurrency() {
    _useThb = !_useThb;
    notifyListeners();
  }

  // ดึงอัตราแลกเปลี่ยนแบบ Real-time จาก Free Currency API
  Future<void> fetchLiveRate() async {
    try {
      final response = await http
          .get(Uri.parse(ApiConfig.currencyExchangeEndpoint))
          .timeout(ApiConfig.currencyFetchTimeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rate = data['rates']?['THB'];
        if (rate is num && rate > 0) {
          _usdToThbRate = rate.toDouble();
          notifyListeners();
        }
      }
    } catch (e) {
      // หากดึงไม่สำเร็จ จะใช้อัตราแลกเปลี่ยน fallback 35.0 อัตโนมัติ
      debugPrint('Currency fetch rate error: $e');
    }
  }

  // Helper ใส่เครื่องหมายจุลภาคคั่นหลักพัน
  String _formatWithCommas(double value, int fractionDigits) {
    final parts = value.toStringAsFixed(fractionDigits).split('.');
    final regex = RegExp(r'\B(?=(\d{3})+(?!\d))');
    final intPart = parts[0].replaceAll(regex, ',');
    if (parts.length > 1 && fractionDigits > 0) {
      return '$intPart.${parts[1]}';
    }
    return intPart;
  }

  // ฟังก์ชันแปลงและจัดรูปแบบราคา
  String formatPrice(dynamic usdPrice, {bool includeDecimals = true}) {
    if (usdPrice == null) return '${currencySymbol}0.00';

    final double? rawUsd = usdPrice is num
        ? usdPrice.toDouble()
        : double.tryParse(usdPrice.toString());

    if (rawUsd == null) return '${currencySymbol}0.00';
    if (rawUsd == 0) return 'FREE';

    if (_useThb) {
      final thbAmount = rawUsd * _usdToThbRate;
      if (!includeDecimals || thbAmount >= 100) {
        // สำหรับราคาบาท สามารถปัดเศษให้สวยงาม เช่น ฿850 หรือ ฿1,250
        return '฿${_formatWithCommas(thbAmount, 0)}';
      }
      return '฿${_formatWithCommas(thbAmount, 2)}';
    } else {
      return '\$${_formatWithCommas(rawUsd, 2)}';
    }
  }
}
