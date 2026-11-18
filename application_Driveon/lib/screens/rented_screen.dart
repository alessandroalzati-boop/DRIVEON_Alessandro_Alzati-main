import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/car_pricing_service.dart';
import '../services/car_service.dart';
import '../widgets/car_card.dart';
import 'car_details_screen.dart';

class RentedScreen extends StatefulWidget {
  const RentedScreen({super.key});

  @override
  State<RentedScreen> createState() => _RentedScreenState();
}

class _RentedScreenState extends State<RentedScreen> {
  final CarService _carService = CarService();
  Set<String> _rentedVins = <String>{};
  Set<String> _favoriteVins = <String>{};

  static const String _favoriteStorageKey = 'favorite_vins';
  static const String _rentedStorageKey = 'rented_vins';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final rented = prefs.getStringList(_rentedStorageKey) ?? const [];
    final favorite = prefs.getStringList(_favoriteStorageKey) ?? const [];

    if (!mounted) return;

    setState(() {
      _rentedVins = _readRentalVins(rented);
      _favoriteVins = favorite.where((vin) => vin.isNotEmpty).toSet();
    });
  }

  Set<String> _readRentalVins(List<String> storedRecords) {
    final vins = <String>{};

    for (final entry in storedRecords) {
      if (entry.isEmpty) continue;

      try {
        final decoded = jsonDecode(entry);
        if (decoded is Map && decoded['vin'] is String) {
          vins.add(decoded['vin'] as String);
        } else if (decoded is String) {
          vins.add(decoded);
        }
      } catch (_) {
        vins.add(entry);
      }
    }

    return vins;
  }

  Future<void> _removeRental(String vin) async {
    final prefs = await SharedPreferences.getInstance();
    final storedRecords = prefs.getStringList(_rentedStorageKey) ?? const [];
    final filtered = <String>[];

    for (final entry in storedRecords) {
      if (entry.isEmpty) continue;

      try {
        final decoded = jsonDecode(entry);
        final savedVin = decoded is Map ? decoded['vin'] : decoded;
        if (savedVin != vin) {
          filtered.add(entry);
        }
      } catch (_) {
        if (entry != vin) {
          filtered.add(entry);
        }
      }
    }

    await prefs.setStringList(_rentedStorageKey, filtered);

    setState(() {
      _rentedVins.remove(vin);
    });
  }

  Future<List<RentedCardItem>> _loadRentedCars() async {
    final prefs = await SharedPreferences.getInstance();
    final storedRecords = prefs.getStringList(_rentedStorageKey) ?? const [];
    final quantityByVin = <String, int>{};

    for (final entry in storedRecords) {
      if (entry.isEmpty) continue;

      try {
        final decoded = jsonDecode(entry);
        if (decoded is Map && decoded['vin'] is String) {
          final vin = decoded['vin'] as String;
          final quantity = decoded['quantity'] is int ? decoded['quantity'] as int : 1;
          quantityByVin[vin] = quantity;
        } else if (decoded is String) {
          quantityByVin[decoded] = 1;
        }
      } catch (_) {
        quantityByVin[entry] = 1;
      }
    }

    final vehicles = await _carService.getCarsFromCatalog();
    final rentalItems = <RentedCardItem>[];

    for (final car in vehicles) {
      final quantity = quantityByVin[car.vin] ?? 0;
      if (quantity <= 0) {
        continue;
      }

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
      final safeRegion = car.maps.isNotEmpty ? car.maps : 'Europa';
      final totalPrice = _parsePrice(priceResult.price) * quantity;

      rentalItems.add(
        RentedCardItem(
          vin: car.vin,
          quantity: quantity,
          totalPrice: totalPrice,
          carCard: CarCard(
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
            isFavorite: _favoriteVins.contains(car.vin),
            onFavoriteToggle: null,
            showPurchaseButton: false,
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
        ),
      );
    }

    return rentalItems;
  }

  double _parsePrice(String value) {
    final normalized = value.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E12),
        elevation: 0,
        title: const Text('Noleggi'),
      ),
      body: FutureBuilder<List<RentedCardItem>>(
        future: _loadRentedCars(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Errore nel caricamento dei noleggi',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final items = snapshot.data ?? const <RentedCardItem>[];

          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Nessuna auto prenotata',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];

                return Column(
                  children: [
                    item.carCard,
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A2128),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Quantità: ${item.quantity}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Totale: €${item.totalPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFB7F56A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _removeRental(item.vin),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF20262B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Elimina ora'),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class RentedCardItem {
  final CarCard carCard;
  final String vin;
  final int quantity;
  final double totalPrice;

  const RentedCardItem({
    required this.carCard,
    required this.vin,
    required this.quantity,
    required this.totalPrice,
  });
}
