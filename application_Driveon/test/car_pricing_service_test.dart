import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/services/car_pricing_service.dart';

void main() {
  test('Market value is converted to a daily euro rate', () {
    final result = CarPricingService.calculateDailyRateFromMarketValue(30000);
    expect(result, 920.0);
  });

  test('Fallback estimate returns a sensible positive daily rate', () async {
    final result = await CarPricingService.fetchPriceForCar('BMW', 'X5', year: 2021);
    expect(int.parse(result.price), greaterThan(0));
  });

  test('Different models should not share the same fallback daily price', () async {
    final x5 = await CarPricingService.fetchPriceForCar('BMW', 'X5', year: 2021);
    final series3 = await CarPricingService.fetchPriceForCar('BMW', '3 Series', year: 2021);

    expect(int.parse(x5.price), isNot(equals(int.parse(series3.price))));
    expect(int.parse(x5.price), greaterThan(int.parse(series3.price)));
  });

  test('Image lookup falls back to a valid car URL when VIN is missing', () async {
    final result = await CarPricingService.fetchImageForCar(
      brand: 'BMW',
      model: 'X5',
      vin: '',
      year: 2021,
    );
    expect(result, startsWith('http'));
  });
}
