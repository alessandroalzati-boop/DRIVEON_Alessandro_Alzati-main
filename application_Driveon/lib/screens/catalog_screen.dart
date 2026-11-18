import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import '../services/car_pricing_service.dart';
import '../services/car_service.dart';
import '../widgets/car_card.dart';
import 'car_details_screen.dart';

class CatalogScreen extends StatefulWidget {
  final VoidCallback? onFavoritesChanged;
  final VoidCallback? onRentalChanged;

  const CatalogScreen({
    super.key,
    this.onFavoritesChanged,
    this.onRentalChanged,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final CarService _carService = CarService();
  late Future<List<CarCard>> _carsFuture;

  @override
  void initState() {
    super.initState();
    _carsFuture = _loadCars();
  }

  // --- CARICA LE AUTO ---
  Future<List<CarCard>> _loadCars() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final vehicles = await _carService.getCarsFromCatalog();
    final List<CarCard> cars = [];

    for (final car in vehicles) {
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
      final safeRegion = car.maps.isNotEmpty ? car.maps : 'Europa';
      final safeFuel = car.alimentazione.isNotEmpty ? car.alimentazione : 'Benzina';
      final safeTransmission = car.cambio.isNotEmpty ? car.cambio : 'Automatico';

      cars.add(
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
          location: safeRegion,
          isFavorite: userProvider.favoriteVins.contains(car.vin),
          onFavoriteToggle: () {
            userProvider.toggleFavorite(car.vin);
            widget.onFavoritesChanged?.call();
            setState(() {
              _carsFuture = _loadCars();
            });
          },
          onPurchaseConfirmed: (purchasedVin, quantity) async {
            await userProvider.addRental(purchasedVin);
            widget.onRentalChanged?.call();
            if (mounted) {
              setState(() {
                _carsFuture = _loadCars();
              });
            }
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
                  region: safeRegion,
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

    return cars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E12),
        elevation: 0,
        automaticallyImplyLeading: false, // <-- Nasconde la freccia di default
        title: const Text(
          'Car catalog',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<CarCard>>(
        future: _carsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load cars',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final cars = snapshot.data ?? [];

          if (cars.isEmpty) {
            return const Center(
              child: Text(
                'No cars available',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            children: [
              GridView.builder(
                itemCount: cars.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 500,
                ),
                itemBuilder: (context, index) => cars[index],
              ),
            ],
          );
        },
      ),
    );
  }
}