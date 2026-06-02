import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';

class BibleScreen extends ConsumerStatefulWidget {
  const BibleScreen({super.key});

  @override
  ConsumerState<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends ConsumerState<BibleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allBooks = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Active reading state
  Map<String, dynamic>? _selectedBook;
  int _selectedChapter = 1;
  List<Map<String, dynamic>> _currentVerses = [];
  double _fontSize = 18.0;
  String _selectedTranslation = 'DR';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedTranslation = ref.read(localeProvider) == 'sw' ? 'SUV' : 'DR';
    _loadBooks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    final books = await DatabaseHelper.instance.getBibleBooks();
    setState(() {
      _allBooks = books;
      if (books.isNotEmpty) {
        // Default select Genesis (index 0)
        _selectedBook = books.firstWhere((b) => b['abbreviation'] == 'Gen', orElse: () => books.first);
      }
      _isLoading = false;
    });
    _loadVerses();
  }

  Future<void> _loadVerses() async {
    if (_selectedBook == null) return;
    final verses = await DatabaseHelper.instance.getVerses(
      _selectedBook!['id'] as int,
      _selectedChapter,
      translation: _selectedTranslation,
    );
    setState(() {
      _currentVerses = verses;
    });
  }

  void _selectBook(Map<String, dynamic> book) {
    setState(() {
      _selectedBook = book;
      _selectedChapter = 1;
    });
    _loadVerses();
  }

  void _changeChapter(int offset) {
    if (_selectedBook == null) return;
    final total = _selectedBook!['total_chapters'] as int;
    final next = _selectedChapter + offset;
    if (next >= 1 && next <= total) {
      setState(() {
        _selectedChapter = next;
      });
      _loadVerses();
    }
  }

  void _showChapterSelector() {
    if (_selectedBook == null) return;
    final total = _selectedBook!['total_chapters'] as int;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.of(ref, 'bible_select_chapter'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  itemCount: total,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final chapterNum = index + 1;
                    final isSelected = chapterNum == _selectedChapter;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedChapter = chapterNum;
                        });
                        _loadVerses();
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.liturgicalGold : AppTheme.surfaceLightDark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '$chapterNum',
                            style: TextStyle(
                              color: isSelected ? Colors.black : AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVerseOptions(Map<String, dynamic> verse) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${ref.watch(localeProvider) == 'sw' ? 'Mstari' : 'Verse'} ${verse['verse']}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '"${verse['text']}"',
                style: const TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 24),
              
              // Color Highlight Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildHighlightOption(verse['id'], '#FFFFD700', Colors.yellow), // Gold
                  _buildHighlightOption(verse['id'], '#FF6495ED', Colors.blue), // Blue
                  _buildHighlightOption(verse['id'], '#FFFF6B6B', Colors.redAccent), // Red
                  _buildHighlightOption(verse['id'], '#FF4CAF50', Colors.green), // Green
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.liturgicalRed, size: 28),
                    onPressed: () async {
                      // Delete highlights if any (we can add detailed query or just call database delete)
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.of(ref, 'bible_highlight_cleared'))),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHighlightOption(int verseId, String colorHex, Color color) {
    return GestureDetector(
      onTap: () async {
        await DatabaseHelper.instance.addAnnotation(verseId, colorHex, null);
        HapticFeedback.mediumImpact();
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppStrings.of(ref, 'bible_highlighted'))),
          );
        }
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: color.withOpacity(0.6),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.of(ref, 'bible_title')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: AppStrings.of(ref, 'bible_ot')),
              Tab(text: AppStrings.of(ref, 'bible_nt')),
              Tab(text: AppStrings.of(ref, 'bible_deutero')),
            ],
            indicatorColor: AppTheme.liturgicalGold,
            labelColor: AppTheme.liturgicalGold,
            unselectedLabelColor: AppTheme.textMuted,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.liturgicalGold))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBooksTab('OT'),
                _buildBooksTab('NT'),
                _buildBooksTab('DEUTERO'),
              ],
            ),
    );
  }

  Widget _buildBooksTab(String testament) {
    final books = _allBooks.where((b) => b['testament'] == testament).toList();
    final activeLocale = ref.watch(localeProvider);

    return Row(
      children: [
        // Left Column: Books Selector
        Container(
          width: 140,
          decoration: const BoxDecoration(
            border: Border(right: BorderSide(color: AppTheme.surfaceLightDark, width: 1.0)),
          ),
          child: ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final isSelected = _selectedBook != null && book['id'] == _selectedBook!['id'];
              final String bookName = activeLocale == 'sw'
                  ? DatabaseHelper.getSwahiliBookName(book['name'] as String)
                  : book['name'] as String;

              return InkWell(
                onTap: () => _selectBook(book),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
                  color: isSelected ? AppTheme.surfaceLightDark.withOpacity(0.5) : Colors.transparent,
                  child: Text(
                    bookName,
                    style: TextStyle(
                      color: isSelected ? AppTheme.liturgicalGold : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Right Column: Scripture Reader Pane
        Expanded(
          child: _selectedBook == null
              ? Center(child: Text(AppStrings.of(ref, 'bible_select_book')))
              : Column(
                  children: [
                    // Reading Header Controls
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: AppTheme.surfaceDark,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous Chapter
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: AppTheme.textSecondary),
                            onPressed: _selectedChapter > 1 ? () => _changeChapter(-1) : null,
                          ),
                          // Active Chapter Select Card
                          GestureDetector(
                            onTap: _showChapterSelector,
                            child: Chip(
                              backgroundColor: AppTheme.surfaceLightDark,
                              side: BorderSide.none,
                              label: Text(
                                '${activeLocale == 'sw' ? 'Sura' : 'Chapter'} $_selectedChapter',
                                style: const TextStyle(
                                  color: AppTheme.liturgicalGold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Next Chapter
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
                            onPressed: _selectedChapter < (_selectedBook!['total_chapters'] as int)
                                ? () => _changeChapter(1)
                                : null,
                          ),
                        ],
                      ),
                    ),

                    // Font Sizing Row & Translation Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      color: AppTheme.surfaceDark.withOpacity(0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Translation Toggle
                          Row(
                            children: [
                              Text(
                                '${AppStrings.of(ref, 'bible_translation_label')}: ',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedTranslation = _selectedTranslation == 'DR' ? 'SUV' : 'DR';
                                  });
                                  _loadVerses();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surfaceLightDark,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppTheme.liturgicalGold.withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    _selectedTranslation,
                                    style: const TextStyle(
                                      color: AppTheme.liturgicalGold,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Font Sizing
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.text_fields_outlined, size: 18, color: AppTheme.textSecondary),
                                onPressed: () {
                                  setState(() {
                                    if (_fontSize > 12) _fontSize -= 2.0;
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.text_fields, size: 24, color: AppTheme.textSecondary),
                                onPressed: () {
                                  setState(() {
                                    if (_fontSize < 30) _fontSize += 2.0;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Fallback Notice Banner
                    if (_selectedTranslation == 'SUV' &&
                        _currentVerses.isNotEmpty &&
                        _currentVerses.first['translation'] == 'DR')
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: AppTheme.liturgicalRed.withOpacity(0.15),
                        child: Text(
                          AppStrings.of(ref, 'bible_fallback_notice'),
                          style: const TextStyle(
                            color: AppTheme.liturgicalRed,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    // Verses Scrollable List
                    Expanded(
                      child: _currentVerses.isEmpty
                          ? Center(
                              child: Text(
                                activeLocale == 'sw'
                                    ? 'Maandiko ya sura $_selectedChapter bado hayajawekwa. Tafadhali tumia Zaburi 23 au Yohana 3 kujaribu.'
                                    : 'Scriptures for chapter $_selectedChapter are currently unseeded. Use Psalms 23 or John 3 to test.',
                                style: const TextStyle(color: AppTheme.textMuted),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _currentVerses.length,
                              itemBuilder: (context, index) {
                                final verse = _currentVerses[index];
                                final int verseNum = verse['verse'] as int;
                                final String verseText = verse['text'] as String;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: GestureDetector(
                                    onLongPress: () => _showVerseOptions(verse),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: _fontSize,
                                          height: 1.5,
                                        ),
                                        children: [
                                          TextSpan(
                                            text: '$verseNum ',
                                            style: TextStyle(
                                              color: AppTheme.liturgicalGold,
                                              fontWeight: FontWeight.bold,
                                              fontSize: _fontSize - 4,
                                            ),
                                          ),
                                          TextSpan(
                                            text: verseText,
                                            style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontFamily: 'Lora',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
