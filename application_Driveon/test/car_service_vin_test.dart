import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/car_model.dart';
import 'package:flutter_application_1/services/car_pricing_service.dart';
import 'package:flutter_application_1/services/car_service.dart';

void main() {
  test('VIN-based image lookup returns a valid image URL even with the placeholder key', () async {
    final service = CarService();
    final image = await service.getCarImageByVin('1HGBH41JXMN109186');

    expect(image, startsWith('http'));
  });

  test('photo URI stays VIN-based and does not include make/model query params', () {
    final uri = CarPricingService.buildPhotoUriForVin('1HGBH41JXMN109186');

    expect(
      uri.toString(),
      'https://api.vehicles.dev/v1/vehicles/photos/1HGBH41JXMN109186',
    );
    expect(uri.queryParameters.isEmpty, isTrue);
  });

  test('CarModel exposes the compatibility accessors expected by the screen', () {
    const car = CarModel(
      vin: '1HGBH41JXMN109186',
      brand: 'Toyota',
      model: 'Corolla',
      year: '2021',
      displacement: '1.8',
      power: '139',
      fuelType: 'Gasoline',
      cylinderCount: '4',
      transmission: 'Automatic',
    );

    expect(car.marca, 'Toyota');
    expect(car.modello, 'Corolla');
    expect(car.anno, '2021');
    expect(car.cilindrata, '1.8');
    expect(car.potenza, '139');
    expect(car.alimentazione, 'Gasoline');
    expect(car.cilindri, '4');
    expect(car.cambio, 'Automatic');
  });
}
