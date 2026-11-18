import 'dart:convert';

import 'package:http/http.dart' as http;

class CarPriceResult {
  final String price;
  final bool isFromApi;

  const CarPriceResult({
    required this.price,
    required this.isFromApi,
  });
}

class CarPricingService {
  static const String _vehiclesApiKey = String.fromEnvironment(
    'VEHICLES_API_KEY',
    defaultValue: 'YOUR_VEHICLES_API_KEY',
  );
  static const String _vehiclesBaseUrl =
      'https://api.vehicles.dev/v1/vehicles/market-value';
  static const String _vehiclesPhotosBaseUrl =
      'https://api.vehicles.dev/v1/vehicles/photos';

  static Uri buildPhotoUriForVin(String vin) {
    final cleanVin = vin.trim().toUpperCase();
    return Uri.parse('$_vehiclesPhotosBaseUrl/$cleanVin');
  }

  static double calculateDailyRateFromMarketValue(num estimateUsd) {
    final eurValue = estimateUsd * 0.92;
    return (eurValue / 30).roundToDouble();
  }

  static Future<String> fetchImageForCar({
    required String brand,
    required String model,
    String? vin,
    int? year,
  }) async {
    final safeVin = (vin ?? '').trim();
    final safeBrand = brand.trim();
    final safeModel = model.trim();

    if (_vehiclesApiKey == 'YOUR_VEHICLES_API_KEY' ||
        _vehiclesApiKey.trim().isEmpty ||
        safeVin.isEmpty) {
      return _fallbackCarImageUrl(safeBrand, safeModel, year ?? DateTime.now().year);
    }

    final url = buildPhotoUriForVin(safeVin);

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_vehiclesApiKey',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final extractedImage = _extractImageFromResponse(decoded);
        if (extractedImage != null && extractedImage.trim().isNotEmpty) {
          return extractedImage;
        }
      }
    } catch (_) {
      // fallback below
    }

    return _fallbackCarImageUrl(safeBrand, safeModel, year ?? DateTime.now().year);
  }

  static String? _extractImageFromResponse(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final primaryKeys = [
        'primaryImage',
        'image',
        'imageUrl',
        'url',
        'src',
        'photo',
        'photoUrl',
      ];

      for (final key in primaryKeys) {
        final value = decoded[key];
        final extracted = _normalizeImageValue(value);
        if (extracted != null) {
          return extracted;
        }
      }

      final photos = decoded['photos'];
      if (photos is List) {
        for (final photo in photos) {
          final extracted = _normalizeImageValue(photo);
          if (extracted != null) {
            return extracted;
          }
        }
      }
    }

    return null;
  }

  static String? _normalizeImageValue(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    if (value is Map) {
      for (final key in ['url', 'image', 'src', 'large', 'medium', 'thumbnail']) {
        final nested = value[key];
        if (nested is String && nested.trim().isNotEmpty) {
          return nested.trim();
        }
      }
    }

    return null;
  }

  static String _fallbackCarImageUrl(String brand, String model, int year) {
    final brandName = brand.toLowerCase();
    final modelName = model.toLowerCase();

    final brandFallbacks = {
      'bmw': 'https://images.unsplash.com/photo-1555215695-3004980ad54e?auto=format&fit=crop&w=1200&q=80',
      'mercedes': 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?auto=format&fit=crop&w=1200&q=80',
      'audi': 'https://images.unsplash.com/photo-1494905998402-395d579af36f?auto=format&fit=crop&w=1200&q=80',
      'porsche': 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=80',
      'tesla': 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?auto=format&fit=crop&w=1200&q=80',
      'ford': 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=80',
      'ferrari': 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1200&q=80',
      'lamborghini': 'https://images.unsplash.com/photo-1525609004556-c46c7d6cf023?auto=format&fit=crop&w=1200&q=80',
      'toyota': 'https://images.unsplash.com/photo-1553440569-bcc63803a83d?auto=format&fit=crop&w=1200&q=80',
      'honda': 'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=1200&q=80',
      'volkswagen': 'https://images.unsplash.com/photo-1493238792000-8113da705763?auto=format&fit=crop&w=1200&q=80',
      'nissan': 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=80',
      'fiat': 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=80',
      'jeep': 'https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?auto=format&fit=crop&w=1200&q=80',
      'kia': 'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?auto=format&fit=crop&w=1200&q=80',
      'hyundai': 'https://images.unsplash.com/photo-1542281286-9e0a16bb7366?auto=format&fit=crop&w=1200&q=80',
      'volvo': 'https://images.unsplash.com/photo-1503736334956-4c8f8e92946d?auto=format&fit=crop&w=1200&q=80',
    };

    final genericFallbacks = [
      'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1553440569-bcc63803a83d?auto=format&fit=crop&w=1200&q=80',
    ];

    final matchedBrand = brandFallbacks.entries.firstWhere(
      (entry) => brandName.contains(entry.key) || modelName.contains(entry.key),
      orElse: () => const MapEntry<String, String>('', ''),
    );

    if (matchedBrand.key.isNotEmpty) {
      return matchedBrand.value;
    }

    final index = ((year % genericFallbacks.length) + brandName.length + modelName.length) % genericFallbacks.length;
    return genericFallbacks[index];
  }

  static Future<CarPriceResult> fetchPriceForCar(
    String brand,
    String model, {
    int? year,
    String? vin,
  }) async {
    final safeBrand = brand.trim();
    final safeModel = model.trim();
    final safeVin = (vin ?? '').trim();

    if (safeBrand.isEmpty || safeModel.isEmpty) {
      return const CarPriceResult(price: '90', isFromApi: false);
    }

    if (_vehiclesApiKey == 'YOUR_VEHICLES_API_KEY' ||
        _vehiclesApiKey.trim().isEmpty) {
      return CarPriceResult(
        price: _estimateFallbackDailyPrice(safeBrand, safeModel, year),
        isFromApi: false,
      );
    }

    final uri = Uri.parse(_vehiclesBaseUrl).replace(
      queryParameters: safeVin.isNotEmpty
          ? {'vin': safeVin}
          : {
              'make': safeBrand,
              'model': safeModel,
              if (year != null) 'year': year.toString(),
              'miles': '25000',
              'condition': 'used',
            },
    );

    try {
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $_vehiclesApiKey',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Unable to fetch vehicle market value');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final estimateUsd = decoded['estimateUsd'];
        if (estimateUsd != null) {
          final parsed = double.tryParse(estimateUsd.toString());
          if (parsed != null) {
            final dailyRate = calculateDailyRateFromMarketValue(parsed);
            return CarPriceResult(
              price: dailyRate.round().toString(),
              isFromApi: true,
            );
          }
        }
      }

      return CarPriceResult(
        price: _estimateFallbackDailyPrice(safeBrand, safeModel, year),
        isFromApi: false,
      );
    } catch (_) {
      return CarPriceResult(
        price: _estimateFallbackDailyPrice(safeBrand, safeModel, year),
        isFromApi: false,
      );
    }
  }

  static String _estimateFallbackDailyPrice(
    String brand,
    String model,
    int? year,
  ) {
    final modelName = '$brand $model'.toLowerCase();
    final currentYear = DateTime.now().year;
    final safeYear = year ?? currentYear;
    final age = (currentYear - safeYear).clamp(1, 20);

    double marketValueUsd = 18000;

    if (modelName.contains('panda') ||
        modelName.contains('500') ||
        modelName.contains('fiat')) {
      marketValueUsd = 12000;
    } else if (modelName.contains('yaris') ||
        modelName.contains('civic') ||
        modelName.contains('focus') ||
        modelName.contains('toyota') ||
        modelName.contains('honda') ||
        modelName.contains('ford')) {
      marketValueUsd = 16000;
    } else if (modelName.contains('golf') ||
        modelName.contains('passat') ||
        modelName.contains('volkswagen') ||
        modelName.contains('opel') ||
        modelName.contains('renault') ||
        modelName.contains('peugeot')) {
      marketValueUsd = 19000;
    } else if (modelName.contains('3 series') ||
        modelName.contains('serie 3') ||
        modelName.contains('a4') ||
        modelName.contains('c-class') ||
        modelName.contains('e-class') ||
        modelName.contains('bmw') ||
        modelName.contains('audi') ||
        modelName.contains('mercedes')) {
      marketValueUsd = 25000;
    } else if (modelName.contains('x5') ||
        modelName.contains('x7') ||
        modelName.contains('q7') ||
        modelName.contains('gle') ||
        modelName.contains('range rover') ||
        modelName.contains('suv')) {
      marketValueUsd = 33000;
    } else if (modelName.contains('ferrari') ||
        modelName.contains('lamborghini') ||
        modelName.contains('maserati') ||
        modelName.contains('911') ||
        modelName.contains('mustang')) {
      marketValueUsd = 42000;
    } else if (modelName.contains('tesla') ||
        modelName.contains('porsche') ||
        modelName.contains('volvo')) {
      marketValueUsd = 28000;
    }

    if (modelName.contains('x5') ||
        modelName.contains('q7') ||
        modelName.contains('gle') ||
        modelName.contains('range rover')) {
      marketValueUsd += 7000;
    }

    if (modelName.contains('panda') ||
        modelName.contains('500') ||
        modelName.contains('yaris')) {
      marketValueUsd -= 3000;
    }

    final adjustedValue = marketValueUsd * (1.0 + (age * 0.04));
    final dailyRate = calculateDailyRateFromMarketValue(adjustedValue);
    return dailyRate.round().clamp(90, 1500).toString();
  }
}
