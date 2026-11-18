
class CarModel {
  final String vin;
  final String brand;
  final String model;
  final String year;
  final String mileage;
  final String region;
  final String displacement;
  final String power;
  final String fuelType;
  final String cylinderCount;
  final String transmission;

  const CarModel({
    required this.vin,
    required this.brand,
    required this.model,
    required this.year,
    this.mileage = 'N/A',
    this.region = 'Europa',
    required this.displacement,
    required this.power,
    required this.fuelType,
    required this.cylinderCount,
    required this.transmission,
  });

  String get marca => brand;
  String get modello => model;
  String get anno => year;
  String get chilometraggio => mileage;
  String get maps => region;
  String get cilindrata => displacement;
  String get potenza => power;
  String get alimentazione => fuelType;
  String get cilindri => cylinderCount;
  String get cambio => transmission;

  factory CarModel.fromJson(List results, String vin) {
    String getValue(String fieldName) {
      final result = results.firstWhere(
        (element) => element['Variable'] == fieldName,
        orElse: () => {'Value': ''},
      );

      return result['Value']?.toString() ?? '';
    }

    return CarModel(
      vin: vin,
      brand: getValue('Make'),
      model: getValue('Model'),
      year: getValue('Model Year'),
      mileage: 'N/A',
      region: 'Europa',
      displacement: getValue('Displacement (L)'),
      power: getValue('Engine Brake (hp) From'),
      fuelType: getValue('Fuel Type - Primary'),
      cylinderCount: getValue('Engine Number of Cylinders'),
      transmission: getValue('Transmission Style'),
    );
  }
}
