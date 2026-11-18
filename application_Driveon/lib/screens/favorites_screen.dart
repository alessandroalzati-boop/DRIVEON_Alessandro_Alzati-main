import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import '../services/car_pricing_service.dart';
import '../services/car_service.dart';
import '../widgets/car_card.dart';
import 'car_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final CarService _carService = CarService();

  Future<List<CarCard>> _loadFavoriteCars() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vehicles = await _carService.getCarsFromCatalog();
    final favoriteCars = <CarCard>[];

    for (final car in vehicles) {
      if (!userProvider.favoriteVins.contains(car.vin)) continue;

      final year = int.tryParse(car.anno) ?? DateTime.now().year;
      final priceResult = await CarPricingService.fetchPriceForCar(
        car.marca,
        car.modello,
        year: year,
        vin: car.vin,
      );
      final image = await CarPricingService.fetchImageForCar(
        brand: car.marca,
        model: car.modello,
        vin: car.vin,
        year: year,
      );

      final description =
          '${car.marca} ${car.modello} del ${car.anno}, alimentazione ${car.alimentazione}, cambio ${car.cambio}. Potenza ${car.potenza} CV, cilindrata ${car.cilindrata}L.';

      final safeMileage = car.chilometraggio.isNotEmpty ? car.chilometraggio : 'N/A';
      final safeFuel = car.alimentazione.isNotEmpty ? car.alimentazione : 'Benzina';
      final safeTransmission = car.cambio.isNotEmpty ? car.cambio : 'Automatico';

      favoriteCars.add(
        CarCard(
          vin: car.vin,
          brand: car.marca,
          model: car.modello,
          price: priceResult.price,
          image: image,
          year: year,
          mileage: safeMileage,
          fuel: safeFuel,
          transmission: safeTransmission,
          description: description,
          isFavorite: true,
          onFavoriteToggle: () => userProvider.toggleFavorite(car.vin),
          onPurchaseConfirmed: (vin, quantity) async {
            await userProvider.addRental(vin);
          },
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CarDetailsScreen(
                  brand: car.marca,
                  model: car.modello,
                  price: priceResult.price,
                  image: image,
                  year: year,
                  mileage: safeMileage,
                  region: 'Europa',
                  fuel: safeFuel,
                  transmission: safeTransmission,
                  description: description,
                ),
              ),
            );
          },
        ),
      );
    }

    return favoriteCars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E12),
        elevation: 0,
        title: const Text('Preferiti'),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<CarCard>>(
        future: _loadFavoriteCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Errore nel caricamento preferiti',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }
          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return const Center(
              child: Text(
                'Nessun preferito salvato',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: favorites.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                mainAxisExtent: 500,
              ),
              itemBuilder: (context, index) => favorites[index],
            ),
          );
        },
      ),
    );
  }
}