import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/screens/car_details_screen.dart';

void main() {
  test('Maps URL resolves to the exact Italian dealership addresses provided by the user', () {
    expect(
      CarDetailsScreen.buildMapsUriForRegion('Europa').toString(),
      'https://www.google.com/maps/search/?api=1&query=Corso+Eusebio+Giambone%2C+33%2C+10134+Torino',
    );

    expect(
      CarDetailsScreen.buildMapsUriForRegion('Milano').toString(),
      'https://www.google.com/maps/search/?api=1&query=Corso+Grosseto%2C+318%2C+10151+Torino+TO',
    );

    expect(
      CarDetailsScreen.buildMapsUriForRegion('Sesto San Giovanni').toString(),
      'https://www.google.com/maps/search/?api=1&query=Vendita+e+Service+Volkswagen+e+Service+Skoda%2C+Viale+Italia%2C+226%2C+20099+Sesto+San+Giovanni+MI',
    );
  });
}
