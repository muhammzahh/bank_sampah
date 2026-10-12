import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class LokasiBankSampahScreen extends StatelessWidget {
  const LokasiBankSampahScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lokasi Bank Sampah'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari lokasi...',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          
          // Map Placeholder
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage('https://maps.googleapis.com/maps/api/staticmap?center=-6.200000,106.816666&zoom=14&size=600x300&maptype=roadmap&markers=color:green%7C-6.200000,106.816666&key=YOUR_API_KEY_HERE'), // Just a visual placeholder, will fail to load without key, so we use fallback
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Icon(Icons.map_rounded, size: 80, color: Colors.white.withValues(alpha: 0.5)),
                ),
                // Custom Map Pin
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 32),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // List of Locations
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _LokasiTile(
                  nama: 'Bank Sampah Melati',
                  jarak: '0.8 km',
                  alamat: 'Jl. Melati No. 12',
                  status: 'Buka',
                  jam: '08.00 - 16.00',
                ),
                const SizedBox(height: 12),
                _LokasiTile(
                  nama: 'Bank Sampah Sejahtera',
                  jarak: '1.2 km',
                  alamat: 'Jl. Anggrek No. 5',
                  status: 'Buka',
                  jam: '08.00 - 15.00',
                ),
                const SizedBox(height: 12),
                _LokasiTile(
                  nama: 'Bank Sampah Bersama',
                  jarak: '2.4 km',
                  alamat: 'Jl. Kenanga No. 8',
                  status: 'Buka',
                  jam: '08.00 - 14.00',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LokasiTile extends StatelessWidget {
  final String nama;
  final String jarak;
  final String alamat;
  final String status;
  final String jam;

  const _LokasiTile({
    required this.nama,
    required this.jarak,
    required this.alamat,
    required this.status,
    required this.jam,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$jarak • $alamat',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                status,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                jam,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
