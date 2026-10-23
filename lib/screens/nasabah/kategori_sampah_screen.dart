import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/formatters.dart';
import '../../models/kategori_sampah_model.dart';
import '../../providers/kategori_sampah_provider.dart';
import 'ajukan_setor_screen.dart';

class HargaItemModel {
  final String id;
  final String name;
  final String description;
  final num price;
  final String category;
  final String trend; // 'naik', 'turun', 'tetap'
  final num trendAmount;
  final IconData icon;
  final KategoriSampahModel? serverModel;

  const HargaItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.trend,
    required this.trendAmount,
    required this.icon,
    this.serverModel,
  });

  HargaItemModel copyWithPrice(num newPrice, KategoriSampahModel sModel) {
    String newTrend = trend;
    num newAmount = trendAmount;
    if (newPrice > price) {
      newTrend = 'naik';
      newAmount = newPrice - price;
    } else if (newPrice < price) {
      newTrend = 'turun';
      newAmount = price - newPrice;
    }
    return HargaItemModel(
      id: id,
      name: name,
      description: description,
      price: newPrice,
      category: category,
      trend: newTrend,
      trendAmount: newAmount,
      icon: icon,
      serverModel: sModel,
    );
  }
}

class KategoriSampahScreen extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final bool showSetorColumn;
  final void Function(KategoriSampahModel?)? onAjukanSetor;

  const KategoriSampahScreen({
    super.key,
    this.title,
    this.subtitle,
    this.showSetorColumn = true,
    this.onAjukanSetor,
  });

  @override
  State<KategoriSampahScreen> createState() => _KategoriSampahScreenState();
}

class _KategoriSampahScreenState extends State<KategoriSampahScreen> {
  static const Color _bgColor = Color(0xFFF6F8F5);
  static const Color _primaryDark = Color(0xFF144D37);
  static const Color _textDark = Color(0xFF0F2F24);
  static const Color _textMuted = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE5E7EB);

  static const List<HargaItemModel> defaultItems = [
    HargaItemModel(
      id: 'plastik_pet',
      name: 'Plastik PET',
      description: 'Botol bersih, tanpa tutup',
      price: 3200,
      category: 'Plastik',
      trend: 'naik',
      trendAmount: 200,
      icon: Icons.liquor_outlined,
    ),
    HargaItemModel(
      id: 'plastik_campur',
      name: 'Plastik campur',
      description: 'Gelas, ember, kantong tebal',
      price: 1500,
      category: 'Plastik',
      trend: 'tetap',
      trendAmount: 0,
      icon: Icons.delete_outline_rounded,
    ),
    HargaItemModel(
      id: 'kardus',
      name: 'Kardus',
      description: 'Kering, tanpa lakban',
      price: 1800,
      category: 'Kardus',
      trend: 'naik',
      trendAmount: 100,
      icon: Icons.inventory_2_outlined,
    ),
    HargaItemModel(
      id: 'kertas_hvs',
      name: 'Kertas HVS',
      description: 'Arsip, buku, koran',
      price: 2400,
      category: 'Kertas',
      trend: 'turun',
      trendAmount: 100,
      icon: Icons.description_outlined,
    ),
    HargaItemModel(
      id: 'kaleng_aluminium',
      name: 'Kaleng aluminium',
      description: 'Kaleng minuman, dipipihkan',
      price: 4500,
      category: 'Kaleng',
      trend: 'tetap',
      trendAmount: 0,
      icon: Icons.smart_screen_outlined,
    ),
    HargaItemModel(
      id: 'botol_kaca',
      name: 'Botol kaca',
      description: 'Utuh, tanpa pecahan',
      price: 600,
      category: 'Kaca',
      trend: 'tetap',
      trendAmount: 0,
      icon: Icons.wine_bar_outlined,
    ),
  ];

  static const List<String> categories = [
    'Semua',
    'Plastik',
    'Kertas',
    'Kardus',
    'Kaca',
    'Kaleng',
  ];

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  String? _selectedItemId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KategoriSampahProvider>().fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  IconData _iconForJenis(String jenis, String nama) {
    final lower = '$jenis $nama'.toLowerCase();
    if (lower.contains('plastik') || lower.contains('botol pet')) {
      return Icons.liquor_outlined;
    }
    if (lower.contains('kardus') || lower.contains('karton')) {
      return Icons.inventory_2_outlined;
    }
    if (lower.contains('kertas') || lower.contains('hvs') || lower.contains('buku')) {
      return Icons.description_outlined;
    }
    if (lower.contains('kaleng') || lower.contains('aluminium') || lower.contains('logam') || lower.contains('besi')) {
      return Icons.smart_screen_outlined;
    }
    if (lower.contains('kaca') || lower.contains('beling')) {
      return Icons.wine_bar_outlined;
    }
    return Icons.recycling_rounded;
  }

  List<HargaItemModel> _buildDisplayList(List<KategoriSampahModel> serverList) {
    final List<HargaItemModel> list = [];

    // Map default items with server prices if available
    for (final def in defaultItems) {
      KategoriSampahModel? matched;
      final defKey = def.name.toLowerCase();
      for (final s in serverList) {
        final sName = s.namaKategori.toLowerCase();
        final sJenis = s.jenis.toLowerCase();
        if (sName.contains(defKey) || defKey.contains(sName) || sJenis.contains(def.category.toLowerCase())) {
          matched = s;
          break;
        }
      }
      if (matched != null && matched.hargaPerKg > 0) {
        list.add(def.copyWithPrice(matched.hargaPerKg, matched));
      } else {
        list.add(def);
      }
    }

    // Add extra server items if not already matched
    for (final s in serverList) {
      final sName = s.namaKategori.toLowerCase();
      final alreadyPresent = list.any((it) =>
          it.name.toLowerCase() == sName ||
          it.serverModel?.id == s.id);

      if (!alreadyPresent) {
        String cat = 'Lainnya';
        final j = s.jenis.toLowerCase();
        if (j.contains('plastik')) {
          cat = 'Plastik';
        } else if (j.contains('kertas')) {
          cat = 'Kertas';
        } else if (j.contains('kardus')) {
          cat = 'Kardus';
        } else if (j.contains('kaca')) {
          cat = 'Kaca';
        } else if (j.contains('kaleng') || j.contains('logam')) {
          cat = 'Kaleng';
        }

        list.add(
          HargaItemModel(
            id: s.id,
            name: s.namaKategori,
            description: 'Kategori ${s.jenis}',
            price: s.hargaPerKg > 0 ? s.hargaPerKg : s.poinPerKg * 1000,
            category: cat,
            trend: 'tetap',
            trendAmount: 0,
            icon: _iconForJenis(s.jenis, s.namaKategori),
            serverModel: s,
          ),
        );
      }
    }

    // Apply category filter
    Iterable<HargaItemModel> filtered = list;
    if (_selectedCategory != 'Semua') {
      filtered = filtered.where(
        (it) => it.category.toLowerCase() == _selectedCategory.toLowerCase(),
      );
    }

    // Apply search filter
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      filtered = filtered.where(
        (it) =>
            it.name.toLowerCase().contains(q) ||
            it.description.toLowerCase().contains(q) ||
            it.category.toLowerCase().contains(q),
      );
    }

    return filtered.toList();
  }

  void _onItemTapped(HargaItemModel item) {
    if (widget.onAjukanSetor != null) {
      widget.onAjukanSetor!(item.serverModel);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AjukanSetorScreen(initialKategori: item.serverModel),
        ),
      );
    }
  }

  void _onSetorColumnTapped() {
    if (widget.onAjukanSetor != null) {
      widget.onAjukanSetor!(null);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const AjukanSetorScreen(),
        ),
      );
    }
  }

  String _getUpdatedDateString() {
    final now = DateTime.now();
    const months = [
      'Okt',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final monthName = months[now.month.clamp(1, 12)];
    return 'Diperbarui ${now.day} $monthName ${now.year}, 08.00';
  }

  @override
  Widget build(BuildContext context) {
    final katProvider = context.watch<KategoriSampahProvider>();
    final displayList = _buildDisplayList(katProvider.kategoriList);

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: _primaryDark,
          onRefresh: () async {
            await katProvider.fetchAll();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header (Title & Updated Date) ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (Navigator.canPop(context)) ...[
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: _borderColor),
                              ),
                              child: const Icon(
                                Icons.chevron_left_rounded,
                                color: _textDark,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                        Text(
                          widget.title ?? 'Jenis sampah',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: _textDark,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle ?? _getUpdatedDateString(),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Search Bar ───────────────────────────────────────────
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _borderColor, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: _textMuted,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) {
                            setState(() => _searchQuery = val);
                          },
                          decoration: const InputDecoration(
                            hintText: 'Cari jenis sampah',
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          child: const Icon(
                            Icons.close_rounded,
                            color: _textMuted,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // ── Category Filter Chips ────────────────────────────────
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = _selectedCategory == cat;

                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedCategory = cat);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryDark : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? _primaryDark : _borderColor,
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // ── Grid of Minimalist Waste Cards (3 Columns) ───────────
                if (displayList.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: _borderColor, width: 1.2),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 40,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tidak ada jenis sampah yang cocok',
                            style: TextStyle(
                              fontSize: 14,
                              color: _textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayList.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      return _buildWasteGridCard(item);
                    },
                  ),
                if (widget.showSetorColumn) ...[
                  const SizedBox(height: 18),
                  _buildKolomSetorSampah(),
                ],
                const SizedBox(height: 16),

                // ── Information Note Card ─────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F3ED),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: _primaryDark,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Harga mengikuti pengepul dan bisa berubah. Nilai akhir dihitung setelah sampah ditimbang petugas.',
                          style: TextStyle(
                            fontSize: 13,
                            color: _primaryDark,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWasteGridCard(HargaItemModel item) {
    final isSelected = _selectedItemId == item.id;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedItemId = item.id);
        _onItemTapped(item);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? _primaryDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _primaryDark : _borderColor,
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? _primaryDark.withValues(alpha: 0.25)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 8 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 32,
              color: isSelected ? Colors.white : const Color(0xFF0F2F24),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : const Color(0xFF0F2F24),
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Rp ${Formatters.rupiah(item.price).replaceAll('Rp ', '')}/kg',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFFD4F67B) : _textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Kolom / Card Setor Sampah ─────────────────────────────────────────────
  Widget _buildKolomSetorSampah() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF144D37), Color(0xFF1B5E44)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF144D37).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _onSetorColumnTapped,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4F67B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.recycling_rounded,
                        color: Color(0xFF144D37),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Setor Sampah',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Jemput ke rumah atau antar sendiri',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFD1E7DD),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFD4F67B),
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Siap menyetorkan sampah Anda? Ajukan penjemputan oleh petugas atau pilih jadwal antar sekarang untuk mengumpulkan poin dan saldo.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFE2E8F0),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFeatureTag(Icons.local_shipping_outlined, 'Jemput Gratis'),
                    const SizedBox(width: 8),
                    _buildFeatureTag(Icons.account_balance_wallet_outlined, 'Poin & Saldo'),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onSetorColumnTapped,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4F67B),
                      foregroundColor: const Color(0xFF144D37),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mulai Setor Sampah',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF144D37),
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: Color(0xFF144D37),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFD4F67B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
