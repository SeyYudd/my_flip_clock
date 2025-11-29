import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class GifWidget extends StatefulWidget {
  const GifWidget({super.key});

  @override
  State<GifWidget> createState() => _GifWidgetState();
}

class _GifWidgetState extends State<GifWidget> {
  // Tenor API key (public)
  static const String _tenorApiKey = 'AIzaSyAWL6FNvMOE4Jx5l5gwYLNLZWRGzVsyauo';

  // Default GIF list - cute cats that are safe
  static const List<Map<String, String>> _defaultGifs = [
    {
      'id': 'seriously_cat',
      'name': 'Seriously Cat',
      'url':
          'https://media.tenor.com/TKq6Fn71XPgAAAAM/seriously-seriously-cat.gif',
      'preview':
          'https://media.tenor.com/TKq6Fn71XPgAAAAe/seriously-seriously-cat.webp',
    },
    {
      'id': 'tinyhxh_melting',
      'name': 'Tinyhxh Melting',
      'url': 'https://media.tenor.com/Km8rOFOjgfQAAAAM/tinyhxh-melting.gif',
      'preview':
          'https://media.tenor.com/Km8rOFOjgfQAAAAe/tinyhxh-melting.webp',
    },
    {
      'id': 'ted_dance',
      'name': 'Ted Dance',
      'url': 'https://media.tenor.com/VQBahlBHyn8AAAAm/ted-puppy.webp',
      'preview': 'https://media.tenor.com/VQBahlBHyn8AAAAe/ted-puppy.webp',
    },
    {
      'id': 'cat_typing',
      'name': 'Cat Typing',
      'url':
          'https://media1.tenor.com/m/Ax7JUhhhMt4AAAAd/angry-typing-kitty.gif',
      'preview': 'https://media.tenor.com/CMbgfhoGn1cAAAAe/cat-typing.webp',
    },
    {
      'id': 'curious_cat',
      'name': 'Curious Cat',
      'url': 'https://media1.tenor.com/m/ZfR68DdhQBsAAAAd/cat-curious-cat.gif',
      'preview':
          'https://media.tenor.com/6Y1b0k1bXHAAAAAe/cat-curious-cat.webp',
    },
  ];

  String? _selectedGifUrl;
  String? _selectedGifId;
  List<Map<String, String>> _searchedGifs = [];
  bool _isLoadingMore = false;
  String? _nextPos; // For pagination
  int _loadedCount = 0;
  static const int _maxGifs = 10;
  static const int _gifsPerLoad = 3;

  @override
  void initState() {
    super.initState();
    _loadSelectedGif();
    _loadCachedSearchGifs();
  }

  Future<void> _loadSelectedGif() async {
    final prefs = await SharedPreferences.getInstance();
    final gifId = prefs.getString('selected_gif_id');
    final gifUrl = prefs.getString('selected_gif_url');
    if (mounted && gifId != null && gifUrl != null) {
      setState(() {
        _selectedGifId = gifId;
        _selectedGifUrl = gifUrl;
      });
    }
  }

  Future<void> _saveSelectedGif(String id, String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_gif_id', id);
    await prefs.setString('selected_gif_url', url);
  }

  Future<void> _loadCachedSearchGifs() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getStringList('cached_search_gifs');
    final pos = prefs.getString('cached_next_pos');
    final count = prefs.getInt('cached_loaded_count') ?? 0;
    if (cached != null && cached.isNotEmpty) {
      setState(() {
        _searchedGifs = cached
            .map((e) => Map<String, String>.from(jsonDecode(e)))
            .toList();
        _nextPos = pos;
        _loadedCount = count;
      });
    }
  }

  Future<void> _saveSearchedGifs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'cached_search_gifs',
      _searchedGifs.map((e) => jsonEncode(e)).toList(),
    );
    if (_nextPos != null) {
      await prefs.setString('cached_next_pos', _nextPos!);
    }
    await prefs.setInt('cached_loaded_count', _loadedCount);
  }

  Future<void> _clearSearchedGifs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cached_search_gifs');
    await prefs.remove('cached_next_pos');
    await prefs.remove('cached_loaded_count');
    setState(() {
      _searchedGifs = [];
      _nextPos = null;
      _loadedCount = 0;
    });
  }

  Future<void> _searchTenorGifs({bool loadMore = false}) async {
    if (_isLoadingMore) return;
    if (_loadedCount >= _maxGifs && loadMore) return;

    setState(() => _isLoadingMore = true);

    try {
      final limit = loadMore ? _gifsPerLoad : _gifsPerLoad;
      String url =
          'https://tenor.googleapis.com/v2/search?q=cute%20cat&key=$_tenorApiKey&limit=$limit&contentfilter=high&media_filter=gif';

      if (loadMore && _nextPos != null) {
        url += '&pos=$_nextPos';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final results = data['results'] as List;
        _nextPos = data['next'];

        final newGifs = results.map<Map<String, String>>((item) {
          final gif = item['media_formats']['gif'];
          final preview = item['media_formats']['tinygif'] ?? gif;
          return {
            'id': item['id'].toString(),
            'name': item['content_description'] ?? 'Cute Cat',
            'url': gif['url'],
            'preview': preview['url'],
          };
        }).toList();

        setState(() {
          if (loadMore) {
            _searchedGifs.addAll(newGifs);
          } else {
            _searchedGifs = newGifs;
          }
          _loadedCount = _searchedGifs.length;
        });

        await _saveSearchedGifs();
      }
    } catch (e) {
      debugPrint('Error searching Tenor: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  void _selectGif(Map<String, String> gif) {
    setState(() {
      _selectedGifId = gif['id'];
      _selectedGifUrl = gif['url'];
    });
    _saveSelectedGif(gif['id']!, gif['url']!);
    Navigator.pop(context);
  }

  void _clearSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('selected_gif_id');
    await prefs.remove('selected_gif_url');
    setState(() {
      _selectedGifId = null;
      _selectedGifUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedGifUrl == null) {
      return _buildEmptyState();
    }
    return _buildGifDisplay();
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: _showGifSelector,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white70, size: 32),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih GIF',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap untuk memilih',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGifDisplay() {
    return GestureDetector(
      onTap: _showGifSelector,
      onLongPress: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Hapus GIF?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Apakah kamu ingin menghapus GIF ini?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  _clearSelection();
                  Navigator.pop(ctx);
                },
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: _selectedGifUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade900,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade900,
            child: const Icon(Icons.error, color: Colors.red),
          ),
        ),
      ),
    );
  }

  void _showGifSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final allGifs = [..._defaultGifs, ..._searchedGifs];
          final canLoadMore = _loadedCount < _maxGifs;

          return Container(
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pilih GIF 🐱',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Default: ${_defaultGifs.length} • Searched: $_loadedCount/$_maxGifs',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
                const SizedBox(height: 16),
                // GIF grid
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1,
                          ),
                      itemCount: allGifs.length + 1, // +1 for load more
                      itemBuilder: (context, index) {
                        if (index == allGifs.length) {
                          // Load more / Search button
                          return _buildLoadMoreTile(setModalState, canLoadMore);
                        }
                        final gif = allGifs[index];
                        final isSelected = _selectedGifId == gif['id'];
                        return _buildGifTile(gif, isSelected);
                      },
                    ),
                  ),
                ),
                // Clear search button
                if (_searchedGifs.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: TextButton.icon(
                      onPressed: () {
                        _clearSearchedGifs();
                        setModalState(() {});
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: Colors.red,
                      ),
                      label: const Text(
                        'Clear Search Results',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGifTile(Map<String, String> gif, bool isSelected) {
    return GestureDetector(
      onTap: () => _selectGif(gif),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.blue, width: 3) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSelected ? 9 : 12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: gif['preview'] ?? gif['url']!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade800,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade800,
                  child: const Icon(Icons.error, color: Colors.red, size: 20),
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreTile(StateSetter setModalState, bool canLoadMore) {
    return GestureDetector(
      onTap: () async {
        if (_isLoadingMore) return;

        if (_searchedGifs.isEmpty) {
          // First search
          await _searchTenorGifs(loadMore: false);
        } else if (canLoadMore) {
          // Load more
          await _searchTenorGifs(loadMore: true);
        }
        setModalState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canLoadMore || _searchedGifs.isEmpty
                ? Colors.blue
                : Colors.grey,
            width: 2,
          ),
        ),
        child: _isLoadingMore
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchedGifs.isEmpty
                        ? Icons.search
                        : (canLoadMore
                              ? Icons.add_circle_outline
                              : Icons.check_circle),
                    color: canLoadMore || _searchedGifs.isEmpty
                        ? Colors.blue
                        : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _searchedGifs.isEmpty
                        ? 'Search'
                        : (canLoadMore ? '+3 More' : 'Max'),
                    style: TextStyle(
                      color: canLoadMore || _searchedGifs.isEmpty
                          ? Colors.blue
                          : Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}
