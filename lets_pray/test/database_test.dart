import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bible JSON Asset Integrity Tests', () {
    late Map<String, dynamic> bibleJson;

    setUpAll(() {
      final file = File('assets/scripture/douay_rheims.json');
      expect(file.existsSync(), isTrue, reason: 'douay_rheims.json asset file must exist');
      
      final content = file.readAsStringSync();
      bibleJson = json.decode(content) as Map<String, dynamic>;
    });

    test('JSON contains exactly 73 Catholic books', () {
      expect(bibleJson.keys.length, equals(73));
    });

    test('All books contain valid chapters and verses structure', () {
      // Test Genesis
      expect(bibleJson.containsKey('Genesis'), isTrue);
      final genesis = bibleJson['Genesis'] as Map<String, dynamic>;
      expect(genesis.containsKey('1'), isTrue);
      
      final gen1 = genesis['1'] as Map<String, dynamic>;
      expect(gen1.containsKey('1'), isTrue);
      expect(gen1['1'], startsWith('In the'));

      // Test Sirach (Deuterocanon)
      expect(bibleJson.containsKey('Ecclesiasticus'), isTrue);
      final sirach = bibleJson['Ecclesiasticus'] as Map<String, dynamic>;
      expect(sirach.containsKey('1'), isTrue);

      // Test Revelation (Apocalypse)
      expect(bibleJson.containsKey('Apocalypse'), isTrue);
      final apocalypse = bibleJson['Apocalypse'] as Map<String, dynamic>;
      expect(apocalypse.containsKey('22'), isTrue);
    });

    test('Mapping mapping covers all JSON keys', () {
      final jsonKeys = bibleJson.keys.toList();
      
      // Re-define the mapping keys to verify them
      const jsonKeyToDbBookName = [
        'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Josue', 'Judges', 'Ruth',
        '1 Kings', '2 Kings', '3 Kings', '4 Kings', '1 Paralipomenon', '2 Paralipomenon',
        '1 Esdras', '2 Esdras', 'Tobias', 'Judith', 'Esther', '1 Machabees', '2 Machabees',
        'Job', 'Psalms', 'Proverbs', 'Ecclesiastes', 'Canticles', 'Wisdom', 'Ecclesiasticus',
        'Isaias', 'Jeremias', 'Lamentations', 'Baruch', 'Ezechiel', 'Daniel', 'Osee', 'Joel',
        'Amos', 'Abdias', 'Jonas', 'Micheas', 'Nahum', 'Habacuc', 'Sophonias', 'Aggeus',
        'Zacharias', 'Malachias', 'Matthew', 'Mark', 'Luke', 'John', 'Acts', 'Romans',
        '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians', 'Philippians', 'Colossians',
        '1 Thessalonians', '2 Thessalonians', '1 Timothy', '2 Timothy', 'Titus', 'Philemon',
        'Hebrews', 'James', '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Apocalypse'
      ];

      for (var key in jsonKeys) {
        expect(jsonKeyToDbBookName.contains(key), isTrue, reason: 'Mapping must contain $key');
      }
    });
  });

  group('Swahili Union Bible JSON Asset Integrity Tests', () {
    late Map<String, dynamic> swahiliJson;

    setUpAll(() {
      final file = File('assets/scripture/swahili_union.json');
      expect(file.existsSync(), isTrue, reason: 'swahili_union.json asset file must exist');

      final content = file.readAsStringSync();
      swahiliJson = json.decode(content) as Map<String, dynamic>;
    });

    test('JSON contains BIBLEBOOK list of exactly 66 books', () {
      expect(swahiliJson.containsKey('BIBLEBOOK'), isTrue);
      final booksList = swahiliJson['BIBLEBOOK'] as List<dynamic>;
      expect(booksList.length, equals(66));
    });

    test('All books contain valid chapters and verses structure', () {
      final booksList = swahiliJson['BIBLEBOOK'] as List<dynamic>;
      final genesis = booksList.firstWhere((b) => b['book_name'] == 'Mwanzo') as Map<String, dynamic>;
      expect(genesis.containsKey('CHAPTER'), isTrue);
      
      final chapters = genesis['CHAPTER'] as List<dynamic>;
      final ch1 = chapters.firstWhere((c) => c['chapter_number'] == '1') as Map<String, dynamic>;
      expect(ch1.containsKey('VERSES'), isTrue);
      
      final verses = ch1['VERSES'] as List<dynamic>;
      final v1 = verses.firstWhere((v) => v['verse_number'] == '1') as Map<String, dynamic>;
      expect(v1['verse_text'], startsWith('Hapo mwanzo'));
    });

    test('Swahili book mapping covers all book names in Swahili JSON', () {
      final booksList = swahiliJson['BIBLEBOOK'] as List<dynamic>;
      const swahiliBookMappingKeys = [
        'Mwanzo', 'Kutoka', 'Mambo ya Walawi', 'Hesabu', 'Kumbukumbu la Torati', 'Yoshua', 'Waamuzi', 'Ruthu',
        '1 Samueli', '2 Samueli', '1 Wafalme', '2 Wafalme', '1 Mambo ya Nyakati', '2 Mambo ya Nyakati', 'Ezra',
        'Nehemia', 'Esta', 'Ayubu', 'Zaburi', 'Mithali', 'Mhubiri', 'Wimbo Ulio Bora', 'Isaya', 'Yeremia',
        'Maombolezo', 'Ezekieli', 'Danieli', 'Hosea', 'Yoeli', 'Amosi', 'Obadia', 'Yona', 'Mika', 'Nahumu',
        'Habakuki', 'Sefania', 'Hagai', 'Zekaria', 'Malaki', 'Mathayo', 'Marko', 'Luka', 'Yohana', 'Matendo ya Mitume',
        'Warumi', '1 Wakorintho', '2 Wakorintho', 'Wagalatia', 'Waefeso', 'Wafilipi', 'Wakolosai', '1 Wathesalonike',
        '2 Wathesalonike', '1 Timotheo', '2 Timotheo', 'Tito', 'Filemoni', 'Waebrania', 'Yakobo', '1 Petro',
        '2 Petro', '1 Yohana', '2 Yohana', '3 Yohana', 'Yuda', 'Ufunuo wa Yohana'
      ];

      for (var bookObj in booksList) {
        final swBookName = bookObj['book_name'] as String;
        expect(swahiliBookMappingKeys.contains(swBookName), isTrue, reason: 'Mapping must contain $swBookName');
      }
    });
  });
}
