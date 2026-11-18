
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'catalog_screen.dart';
import 'car_details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isTablet = screenWidth >= 700;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E12),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isTablet ? 520 : 430),
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : 0,
                vertical: isTablet ? 20 : 0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF10151A),
                borderRadius: BorderRadius.circular(isTablet ? 32 : 0),
              ),
              child: const _HomeContent(),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  // VIN REALE della Toyota Highlander (presente nel catalogo)
  static const String _featuredVin = 'JTMB3REB1LJ012345';

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userEmail = userProvider.userEmail ?? 'Ospite';
    final userName = userProvider.userName ?? '';
    final isFeaturedFavorite =
        userProvider.favoriteVins.contains(_featuredVin);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),

          // BRAND E AVATAR UTENTE
          _BrandRow(userName: userName),

          const SizedBox(height: 16),

          Text(
            'Bentornato, $userEmail',
            style: const TextStyle(
              color: Color(0xFFB7BDC1),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Non solo un\'auto.\nIl tuo prossimo\nviaggio.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              height: 1.02,
            ),
          ),

          const SizedBox(height: 22),

          Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF1B2127),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                SizedBox(width: 16),
                Icon(Icons.search, color: Color(0xFF9AA3A8)),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Cerca marca o modello',
                    style: TextStyle(
                      color: Color(0xFF9AA3A8),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Expanded(
                child: _CategoryCard(
                  title: 'Standard',
                  subtitle: 'Pratica, ogni giorno',
                  icon: Icons.local_taxi_rounded,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CatalogScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _CategoryCard(
                  title: 'Luxury',
                  subtitle: 'Oltre l’ordinario',
                  icon: Icons.auto_awesome,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CatalogScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'In primo piano',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CatalogScreen(),
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB7F56A),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Esplora tutte',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          _FeaturedCard(
            vin: _featuredVin,
            isFavorite: isFeaturedFavorite,
            onFavoriteToggle: () {
              userProvider.toggleFavorite(_featuredVin);
            },
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CarDetailsScreen(
                  brand: 'Toyota',
                  model: 'Highlander',
                  price: '569',
                  image:
                      'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=80',
                  year: 2022,
                  mileage: '24.500 km',
                  region: 'Europa',
                  fuel: 'Benzina',
                  transmission: 'Automatico',
                  description:
                      'Toyota Highlander del 2022, alimentazione Benzina, cambio Automatico. Potenza 295 CV, cilindrata 3.5L.',
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(0, 14, 0, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Text(
                    'Toyota\nHighlander',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: '€569',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: '/giorno',
                        style: TextStyle(
                          color: Color(0xFF9AA3A8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Text(
            '295 CV · Automatico · Benzina',
            style: TextStyle(
              color: Color(0xFFB7BDC1),
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Le più richieste',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CatalogScreen(),
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFB7F56A),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'Vedi tutte',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          _PopularCarItem(
            title: 'Fiat 500 Hybrid',
            subtitle: 'Standard · Ibrida · 4 posti',
            price: '€49 / giorno',
            image:
                'https://images.unsplash.com/photo-1553440569-bcc63803a83d?auto=format&fit=crop&w=900&q=80',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CarDetailsScreen(
                  brand: 'Fiat',
                  model: '500 Hybrid',
                  price: '49',
                  image:
                      'https://images.unsplash.com/photo-1553440569-bcc63803a83d?auto=format&fit=crop&w=900&q=80',
                  year: 2023,
                  mileage: '10.000 km',
                  region: 'Europa',
                  fuel: 'Ibrida',
                  transmission: 'Automatico',
                  description:
                      'Fiat 500 Hybrid, 4 posti, ideale per la città.',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGET DELLA CARD IN PRIMO PIANO (CON STELLA) ---
class _FeaturedCard extends StatelessWidget {
  final String vin;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const _FeaturedCard({
    required this.vin,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&w=1200&q=80',
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'LUXURY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // STELLA PER I PREFERITI
              Positioned(
                top: 12,
                right: 12,
                child: GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0B0E12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: const Color(0xFFF2C14E),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET DEL BRAND E AVATAR UTENTE ---
class _BrandRow extends StatelessWidget {
  final String userName;

  const _BrandRow({required this.userName});

  @override
  Widget build(BuildContext context) {
    final iniziale = userName.trim().isNotEmpty
        ? userName.trim()[0].toUpperCase()
        : '?';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 18,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFB7F56A),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                  topRight: Radius.circular(3),
                  bottomRight: Radius.circular(3),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'DRIVEON.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
              ),
            ),
          ],
        ),

        // AVATAR GRANDE CON INIZIALE DINAMICA
        CircleAvatar(
  radius: 22,
  backgroundColor: const Color(0xFF1C232A),
  child: Text(
    iniziale,
    style: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: 18,
    ),
  ),
),
      ],
    );
  }
}

// --- WIDGET DELLE CATEGORIE (Standard / Luxury) ---
class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 98,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2127),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF12181C),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFB7F56A),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9AA3A8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET DELL'ITEM "LE PIÙ RICHIESTE" ---
class _PopularCarItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String image;
  final VoidCallback onTap;

  const _PopularCarItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2127),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                image,
                width: 120,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF9AA3A8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward,
              color: Color(0xFFB7F56A),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
