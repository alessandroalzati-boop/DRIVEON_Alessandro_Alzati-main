
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/car_model.dart';

class CarService {
  static const String baseUrl =
      'https://vpic.nhtsa.dot.gov/api/vehicles';
  static const String _vehiclesApiKey = String.fromEnvironment(
    'VEHICLES_API_KEY',
    defaultValue: 'YOUR_VEHICLES_API_KEY',
  );
  static const String _vehiclesBaseUrl =
      'https://api.vehicles.dev/v1/vehicles/photos';

  static Uri buildPhotoUriForVin(String vin) {
    final cleanVin = vin.trim().toUpperCase();
    return Uri.parse('$_vehiclesBaseUrl/$cleanVin');
  }

  // Retrieves the technical characteristics via VIN.
  Future<CarModel> getCarByVin(
    String vin, {
    int? year,
  }) async {
    final cleanVin = vin.trim().toUpperCase();
    final url = Uri.parse(
      '$baseUrl/DecodeVinExtended/$cleanVin',
    ).replace(
      queryParameters: {
        'format': 'json',
        if (year != null) 'modelyear': year.toString(),
      },
    );

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final List results = data['Results'];

        return CarModel.fromJson(results, cleanVin);
      } else {
        throw Exception(
          'Errore API: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception(
        'Impossibile recuperare i dati dell\'auto: $e',
      );
    }
  }

  Future<List<CarModel>> getCarsFromCatalog() async {
    const fallbackSeeds = [
      {
        'vin': '5TDDZRBHXNS221317',
        'brand': 'Toyota',
        'model': 'Highlander',
        'year': 2022,
        'mileage': '24.500 km',
        'region': 'Europa',
        'fuel': 'Benzina',
        'transmission': 'Automatico',
      },
      {
        'vin': '1FTFW3L57TKD09376',
        'brand': 'Ford',
        'model': 'F-150',
        'year': 2026,
        'mileage': '18.900 km',
        'region': 'America',
        'fuel': 'Diesel',
        'transmission': 'Automatico',
      },
      {
        'vin': '1HGBH41JXMN109186',
        'brand': 'Honda',
        'model': 'Civic',
        'year': 2021,
        'mileage': '31.200 km',
        'region': 'Asia',
        'fuel': 'Ibrida',
        'transmission': 'Automatico',
      },
      {
        'vin': 'JH4KA2650LC012345',
        'brand': 'Acura',
        'model': 'TLX',
        'year': 2020,
        'mileage': '27.800 km',
        'region': 'America',
        'fuel': 'Benzina',
        'transmission': 'Automatico',
      },
      {
        'vin': 'WVWZZZ1JZ3W123456',
        'brand': 'Volkswagen',
        'model': 'Golf',
        'year': 2023,
        'mileage': '15.400 km',
        'region': 'Europa',
        'fuel': 'Benzina',
        'transmission': 'Manuale',
      },
    ];

    final cars = <CarModel>[];

    try {
      for (final seed in fallbackSeeds) {
        final vin = (seed['vin'] as String).trim();
        final year = seed['year'] as int;
        final car = await getCarByVin(vin, year: year);

        cars.add(
          CarModel(
            vin: vin,
            brand: car.brand.isNotEmpty ? car.brand : (seed['brand'] as String),
            model: car.model.isNotEmpty ? car.model : (seed['model'] as String),
            year: car.year.isNotEmpty ? car.year : year.toString(),
            mileage: (seed['mileage'] as String?) ?? 'N/A',
            region: (seed['region'] as String?) ?? 'Europa',
            displacement: car.displacement.isNotEmpty ? car.displacement : '2.0',
            power: car.power.isNotEmpty ? car.power : '190',
            fuelType: car.fuelType.isNotEmpty ? car.fuelType : (seed['fuel'] as String),
            cylinderCount: car.cylinderCount.isNotEmpty ? car.cylinderCount : '4',
            transmission: car.transmission.isNotEmpty ? car.transmission : (seed['transmission'] as String),
          ),
        );
      }
    } catch (_) {
      for (final seed in fallbackSeeds) {
        final vin = (seed['vin'] as String).trim();
        final year = seed['year'] as int;
        cars.add(
          CarModel(
            vin: vin,
            brand: seed['brand'] as String,
            model: seed['model'] as String,
            year: year.toString(),
            mileage: (seed['mileage'] as String?) ?? 'N/A',
            region: (seed['region'] as String?) ?? 'Europa',
            displacement: '2.0',
            power: '190',
            fuelType: seed['fuel'] as String,
            cylinderCount: '4',
            transmission: seed['transmission'] as String,
          ),
        );
      }
    }

    return cars;
  }

  Future<String> getCarImageByVin(String vin) async {
    final cleanVin = vin.trim().toUpperCase();

    if (cleanVin.length != 17) {
      return _fallbackCarImage();
    }

    if (_vehiclesApiKey == 'YOUR_VEHICLES_API_KEY' ||
        _vehiclesApiKey.trim().isEmpty) {
      return _fallbackCarImage();
    }

    final url = buildPhotoUriForVin(cleanVin);

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
        if (decoded is Map<String, dynamic>) {
          final primaryImage = decoded['primaryImage'];
          if (primaryImage is String && primaryImage.trim().isNotEmpty) {
            return primaryImage;
          }

          final photos = decoded['photos'];
          if (photos is List && photos.isNotEmpty) {
            final firstPhoto = photos.first;
            if (firstPhoto is String && firstPhoto.trim().isNotEmpty) {
              return firstPhoto;
            }
          }
        }
      }
    } catch (_) {
      // fallback below
    }

    return _fallbackCarImage();
  }

  String _fallbackCarImage() {
    return 'https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&w=1200&q=80';
  }
}

/*
  API INFORMATION

  Name: NHTSA vPIC API
  Full name: Vehicle Product Information Catalog

  Developer:
  National Highway Traffic Safety Administration (NHTSA),
  a US government agency.

  Cost: free.
  Registration: not required.
  Formats: JSON, XML, and CSV.
  HTTP method: GET.

  Use in the DRIVEON project:
  Retrieval of technical vehicle specifications
  through the VIN identifier.

  Documentation:
  https://vpic.nhtsa.dot.gov/api/
*/