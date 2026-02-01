import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  // Cache key
  static const _cacheKey = 'fx_rates_eur';
  static const _cacheTimeKey = 'fx_rates_eur_time';

  // Fetch rates from exchangerate.host (no API key), cache for 24h
  static Future<Map<String, double>> _getRates() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    final cachedTime = prefs.getInt(_cacheTimeKey) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (cached != null && now - cachedTime < 24 * 60 * 60 * 1000) {
      final map = Map<String, dynamic>.from(json.decode(cached));
      return map.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }
    final url = Uri.parse('https://api.exchangerate.host/latest?base=EUR&symbols=EUR,USD,GBP');
    final resp = await http.get(url);
    if (resp.statusCode == 200) {
      final data = json.decode(resp.body);
      final rates = Map<String, dynamic>.from(data['rates']);
      await prefs.setString(_cacheKey, json.encode(rates));
      await prefs.setInt(_cacheTimeKey, now);
      return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }
    // fallback default rates
    return {'EUR':1.0,'USD':1.08,'GBP':0.86};
  }

  static Future<double> convert(double amount, {String from = 'EUR', String to = 'EUR'}) async {
    final rates = await _getRates();
    if (!rates.containsKey(from) || !rates.containsKey(to)) return amount;
    final amountInEur = amount / rates[from]!;
    return amountInEur * rates[to]!;
  }

  static String format(double amount, String currency) {
    final symbol = switch (currency) {
      'EUR' => '€',
      'USD' => '\$',
      'GBP' => '£',
      _ => currency
    };
    return '$symbol ${amount.toStringAsFixed(2)}';
  }
}


