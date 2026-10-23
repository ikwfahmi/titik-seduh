import 'package:flutter/material.dart';

import '../models/cafe.dart';
import '../models/cafe_query.dart';
import '../services/cafe_service.dart';
import '../services/favorites_store.dart';
import '../theme/app_theme.dart';
import '../widgets/cafe_card.dart';
import '../widgets/coffee_art.dart';
import '../widgets/state_message.dart';
import 'cafe_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.favorites, this.service});
  final FavoritesStore favorites;
  final CafeService? service;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CafeService _service;
  late Future<List<Cafe>> _cafes;
  final _search = TextEditingController();
  final _scroll = ScrollController();
  String? _area;
  bool _highlyRated = false, _open24 = false;
  int _tab = 0;
  CafeSort _sort = CafeSort.reviews;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? CafeService();
    // Future disimpan di state supaya pencarian tidak mengirim HTTP berulang.
    _cafes = _service.fetchCafes();
  }

  @override
  void dispose() {
    _search.dispose();
    _scroll.dispose();
    if (widget.service == null) _service.close();
    super.dispose();
  }

  Future<void> _reload() async {
    final request = _service.fetchCafes();
    setState(() {
      _cafes = request;
    });
    try {
      await request;
    } catch (_) {
      /* Error ditampilkan oleh FutureBuilder. */
    }
  }

  void _reset() => setState(() {
    _search.clear();
    _area = null;
    _highlyRated = false;
    _open24 = false;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      bottom: false,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1120),
          child: ListenableBuilder(
            listenable: widget.favorites,
            builder: (context, _) => FutureBuilder<List<Cafe>>(
              future: _cafes,
              builder: (context, snapshot) {
                final loading =
                    snapshot.connectionState != ConnectionState.done;
                final cafes = snapshot.data ?? <Cafe>[];
                final areas =
                    cafes
                        .map((e) => e.area)
                        .where((e) => e.isNotEmpty)
                        .toSet()
                        .toList()
                      ..sort();
                final results = filterCafes(
                  cafes,
                  query: _search.text,
                  area: _area,
                  highlyRated: _highlyRated,
                  open24Hours: _open24,
                  sort: _sort,
                  favoriteIds: _tab == 1 ? widget.favorites.ids : null,
                );
                return RefreshIndicator(
                  onRefresh: _reload,
                  child: CustomScrollView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _header(),
                              const SizedBox(height: 26),
                              if (_tab == 0)
                                _hero(
                                  loading || snapshot.hasError
                                      ? null
                                      : cafes.length,
                                )
                              else ...[
                                const Text(
                                  'KOLEKSI PRIBADIMU',
                                  style: TextStyle(
                                    color: AppTheme.orange,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Tempat yang ingin\nkamu singgahi.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Simpan yang menarik, temukan lagi di sini.',
                                  style: TextStyle(color: AppTheme.muted),
                                ),
                              ],
                              const SizedBox(height: 26),
                              TextField(
                                controller: _search,
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  hintText:
                                      'Cari nama kafe, alamat, atau wilayah',
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    size: 23,
                                  ),
                                  suffixIcon: _search.text.isEmpty
                                      ? null
                                      : IconButton(
                                          tooltip: 'Hapus pencarian',
                                          onPressed: () =>
                                              setState(_search.clear),
                                          icon: const Icon(
                                            Icons.close,
                                            size: 20,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 17),
                              if (areas.isNotEmpty)
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      _areaChip('Semua wilayah', null),
                                      for (final area in areas)
                                        _areaChip(
                                          area.replaceFirst('Surabaya ', ''),
                                          area,
                                        ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 9,
                                runSpacing: 4,
                                children: [
                                  FilterChip(
                                    label: const Text('Rating 4+'),
                                    avatar: Icon(
                                      Icons.star_outline_rounded,
                                      size: 17,
                                      color: _highlyRated
                                          ? Colors.white
                                          : AppTheme.orange,
                                    ),
                                    labelStyle: TextStyle(
                                      color: _highlyRated
                                          ? Colors.white
                                          : AppTheme.ink,
                                      fontSize: 12,
                                    ),
                                    selected: _highlyRated,
                                    showCheckmark: false,
                                    onSelected: (v) =>
                                        setState(() => _highlyRated = v),
                                  ),
                                  FilterChip(
                                    label: const Text('Buka 24 jam'),
                                    avatar: Icon(
                                      Icons.schedule_rounded,
                                      size: 17,
                                      color: _open24
                                          ? Colors.white
                                          : AppTheme.ink,
                                    ),
                                    labelStyle: TextStyle(
                                      color: _open24
                                          ? Colors.white
                                          : AppTheme.ink,
                                      fontSize: 12,
                                    ),
                                    selected: _open24,
                                    showCheckmark: false,
                                    onSelected: (v) =>
                                        setState(() => _open24 = v),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _tab == 0
                                          ? 'Jelajahi kafe'
                                          : 'Kafe favorit',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Muat ulang data',
                                    onPressed: loading ? null : _reload,
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 21,
                                    ),
                                  ),
                                  PopupMenuButton<CafeSort>(
                                    tooltip: 'Urutkan kafe',
                                    initialValue: _sort,
                                    onSelected: (value) =>
                                        setState(() => _sort = value),
                                    itemBuilder: (_) => CafeSort.values
                                        .map(
                                          (e) => CheckedPopupMenuItem(
                                            value: e,
                                            checked: e == _sort,
                                            child: Text(e.label),
                                          ),
                                        )
                                        .toList(),
                                    icon: const Icon(
                                      Icons.sort_rounded,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                              if (!loading && !snapshot.hasError)
                                Text(
                                  '${results.length} tempat ditemukan · ${_sort.label}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              const SizedBox(height: 18),
                            ],
                          ),
                        ),
                      ),
                      if (loading)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(54),
                            child: Column(
                              children: [
                                CircularProgressIndicator(strokeWidth: 2),
                                SizedBox(height: 20),
                                Text('Sedang mencari tempat untukmu…'),
                              ],
                            ),
                          ),
                        )
                      else if (snapshot.hasError)
                        SliverToBoxAdapter(
                          child: StateMessage(
                            icon: Icons.wifi_off_rounded,
                            title: 'Kafe belum bisa dimuat',
                            message: snapshot.error is CafeApiException
                                ? snapshot.error.toString()
                                : 'Terjadi kendala saat memuat data. Silakan coba lagi.',
                            actionLabel: 'Coba lagi',
                            onAction: _reload,
                          ),
                        )
                      else if (results.isEmpty)
                        SliverToBoxAdapter(
                          child: StateMessage(
                            icon: _tab == 1
                                ? Icons.bookmark_border_rounded
                                : Icons.search_off_rounded,
                            title: _tab == 1 && widget.favorites.ids.isEmpty
                                ? 'Belum ada kafe favorit'
                                : 'Belum menemukan yang cocok',
                            message: _tab == 1 && widget.favorites.ids.isEmpty
                                ? 'Ketuk ikon simpan pada kafe yang kamu suka. Favorit tersimpan di perangkat ini.'
                                : cafes.isEmpty
                                ? 'API belum menyediakan data kafe. Coba muat ulang beberapa saat lagi.'
                                : 'Coba kata kunci lain atau atur ulang filter pencarianmu.',
                            actionLabel:
                                _tab == 1 && widget.favorites.ids.isEmpty
                                ? 'Jelajahi kafe'
                                : 'Atur ulang pencarian',
                            onAction: () {
                              _reset();
                              if (_tab == 1 && widget.favorites.ids.isEmpty) {
                                setState(() => _tab = 0);
                              }
                            },
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          sliver: SliverLayoutBuilder(
                            builder: (context, constraints) {
                              final columns = constraints.crossAxisExtent >= 950
                                  ? 3
                                  : constraints.crossAxisExtent >= 650
                                  ? 2
                                  : 1;
                              Widget card(int index) => CafeCard(
                                cafe: results[index],
                                favorites: widget.favorites,
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => CafeDetailScreen(
                                      cafe: results[index],
                                      favorites: widget.favorites,
                                    ),
                                  ),
                                ),
                              );
                              if (columns == 1) {
                                return SliverList.separated(
                                  itemCount: results.length,
                                  itemBuilder: (_, i) => card(i),
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 12),
                                );
                              }
                              return SliverGrid.builder(
                                itemCount: results.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      mainAxisExtent:
                                          262 *
                                          MediaQuery.textScalerOf(context)
                                              .scale(1)
                                              .clamp(1, 2),
                                      mainAxisSpacing: 16,
                                      crossAxisSpacing: 16,
                                    ),
                                itemBuilder: (_, i) => card(i),
                              );
                            },
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Text(
                            'TITIK SEDUH  /  TEMUKAN JEDA DI SURABAYA',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.muted,
                              fontSize: 9,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _tab,
      height: 72,
      onDestinationSelected: (value) {
        if (_tab == value) return;
        _reset();
        setState(() => _tab = value);
        if (_scroll.hasClients) _scroll.jumpTo(0);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore_rounded),
          label: 'Jelajahi',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_border_rounded),
          selectedIcon: Icon(Icons.bookmark_rounded),
          label: 'Favorit',
        ),
      ],
    ),
  );

  Widget _areaChip(String label, String? area) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _area == area,
      showCheckmark: false,
      labelStyle: TextStyle(
        color: _area == area ? Colors.white : AppTheme.ink,
        fontSize: 12,
      ),
      onSelected: (_) => setState(() => _area = area),
    ),
  );

  Widget _header() => Row(
    children: [
      const CoffeeArt(size: 43),
      const SizedBox(width: 11),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'titik seduh.',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(letterSpacing: -.7),
            ),
            const Text(
              'PANDUAN KAFE SURABAYA',
              style: TextStyle(
                fontSize: 8,
                letterSpacing: 1.8,
                color: AppTheme.muted,
              ),
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Tentang aplikasi',
        icon: const Icon(Icons.info_outline_rounded, size: 22),
        onPressed: () => showAboutDialog(
          context: context,
          applicationName: 'Titik Seduh',
          applicationVersion: '1.0.0',
          applicationIcon: const Icon(
            Icons.local_cafe_rounded,
            size: 36,
            color: AppTheme.orange,
          ),
          children: const [
            Text(
              'Temukan kafe Surabaya berdasarkan wilayah, rating, dan informasi jam dari Surabaya Cafe API.\n\nFavorit disimpan secara lokal. Data kafe memerlukan internet.\n\nUTS Pemrograman Mobile\nM. Ikhwan Fahmi · 240605110116\nKelas C · 2026',
            ),
          ],
        ),
      ),
    ],
  );

  Widget _hero(int? count) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 600;
      final copy = Column(
        crossAxisAlignment: wide
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          const Text(
            'SEDUH CERITA BARU',
            style: TextStyle(
              color: AppTheme.orange,
              fontSize: 9,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'Jeda sejenak,\nngopi di mana?',
            textAlign: wide ? TextAlign.left : TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              height: 1.18,
              fontSize: wide ? 36 : 27,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            count == null
                ? 'Temukan sudut favoritmu di Surabaya.'
                : '$count tempat. Lima wilayah.\nSatu tempat untuk menemukan jedamu.',
            textAlign: wide ? TextAlign.left : TextAlign.center,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      );
      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: ColoredBox(
              color: AppTheme.peach,
              child: CoffeePattern(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  child: wide
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(child: copy),
                            const CoffeeCartArt(width: 270),
                          ],
                        )
                      : const Center(child: CoffeeCartArt(width: 225)),
                ),
              ),
            ),
          ),
          if (!wide) ...[const SizedBox(height: 18), copy],
        ],
      );
    },
  );
}
