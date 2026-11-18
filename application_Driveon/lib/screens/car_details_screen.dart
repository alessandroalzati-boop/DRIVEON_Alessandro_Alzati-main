
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CarDetailsScreen extends StatelessWidget {
  final String brand;
  final String model;
  final String price;
  final String image;
  final int year;
  final String mileage;
  final String region;
  final String fuel;
  final String transmission;
  final String description;

  const CarDetailsScreen({
    super.key,
    required this.brand,
    required this.model,
    required this.price,
    required this.image,
    required this.year,
    required this.mileage,
    this.region = 'Europa',
    required this.fuel,
    required this.transmission,
    this.description = '',
  });

  static Uri buildMapsUriForRegion(String region) {
    final normalized = region.trim().toLowerCase();

    switch (normalized) {
      case 'sesto san giovanni':
      case 'service volkswagen':
      case 'skoda':
        return Uri.https(
          'www.google.com',
          '/maps/search/',
          {
            'api': '1',
            'query': 'Vendita e Service Volkswagen e Service Skoda, Corso Grosseto, 318, 10151 Torino TO, ',
          },
        );
      case 'grosseto':
      case 'beinasco':
      case 'milano':
      case 'lombardia':
        return Uri.https(
          'www.google.com',
          '/maps/search/',
          {'api': '1', 'query': ' Via Cadibona, 9, 20137 Milano '},
        );
      case 'italia':
      case 'europa':
      case 'europe':
      case 'torino':
      case 'collegno':
      case 'america':
      case 'asia':
      default:
        return Uri.https(
          'www.google.com',
          '/maps/search/',
          {'api': '1', 'query': 'Viale Italia, 226, 20099 Sesto San Giovanni MI'},
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final summary = description.isNotEmpty
        ? description
        : '$brand $model del $year, alimentazione $fuel, cambio $transmission.';
    final mapUri = buildMapsUriForRegion(region);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E12),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0E12),
        title: const Text('Dettagli auto'),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              image,
              height: 280,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 280,
                  width: double.infinity,
                  child: Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 70,
                      color: Colors.white70,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$brand $model',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$price € / giorno',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Descrizione dettagliata',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    summary,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Caratteristiche',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildInfo(Icons.calendar_today, 'Anno', year.toString(), Colors.white),
                  _buildInfo(
                    Icons.location_on,
                    'Maps',
                    region,
                    Colors.white,
                    linkUri: mapUri,
                  ),
                  _buildInfo(Icons.speed, 'Chilometraggio', mileage, Colors.white),
                  _buildInfo(Icons.local_gas_station, 'Alimentazione', fuel, Colors.white),
                  _buildInfo(Icons.settings, 'Cambio', transmission, Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(
    IconData icon,
    String label,
    String value,
    Color color, {
    Uri? linkUri,
  }) {
    final content = linkUri == null
        ? Text(
            value,
            style: TextStyle(color: color),
          )
        : InkWell(
            onTap: () async {
              if (await canLaunchUrl(linkUri)) {
                await launchUrl(linkUri, mode: LaunchMode.externalApplication);
              }
            },
            child: Text(
              value,
              style: TextStyle(
                color: Colors.blue.shade300,
                decoration: TextDecoration.underline,
              ),
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
