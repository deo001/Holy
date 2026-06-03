import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static Future<Database>? _databaseFuture;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _databaseFuture ??= _initDB('lets_pray.db');
    try {
      _database = await _databaseFuture!;
      return _database!;
    } catch (e) {
      // Allow next call to retry initialization after a failed open.
      _databaseFuture = null;
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    Database db;
    try {
      db = await openDatabase(
        path,
        version:
            5, // Bump to version 5 to force database schema upgrade and recreate tables
        onCreate: _createDB,
        onUpgrade: (db, oldVersion, newVersion) async {
          // Reset database schema clean for version 2 to support translations
          await db.execute('DROP TABLE IF EXISTS bible_verses');
          await db.execute('DROP TABLE IF EXISTS bible_books');
          await db.execute('DROP TABLE IF EXISTS user_annotations');
          await db.execute('DROP TABLE IF EXISTS prayer_intentions');
          await db.execute('DROP TABLE IF EXISTS app_settings');
          await _createDB(db, newVersion);
        },
      );
    } catch (e) {
      print('Database opening failed: $e. Healing by deleting and recreating.');
      await deleteDatabase(path);
      db = await openDatabase(path, version: 5, onCreate: _createDB);
    }

    // Heal partially-migrated databases where user_version is current but
    // one or more tables are missing.
    await _ensureCoreTables(db);

    // Automatically check and seed the Bible text from JSON
    await _checkAndSeedBible(db);

    // Some sqflite failures during heavy seed operations may close the handle.
    // Reopen so callers never receive a closed database instance.
    if (!db.isOpen) {
      db = await openDatabase(
        path,
        version: 5,
        onCreate: _createDB,
        onUpgrade: (db, oldVersion, newVersion) async {
          await db.execute('DROP TABLE IF EXISTS bible_verses');
          await db.execute('DROP TABLE IF EXISTS bible_books');
          await db.execute('DROP TABLE IF EXISTS user_annotations');
          await db.execute('DROP TABLE IF EXISTS prayer_intentions');
          await db.execute('DROP TABLE IF EXISTS app_settings');
          await _createDB(db, newVersion);
        },
      );
    }

    return db;
  }

  Future<void> _ensureCoreTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bible_books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        testament TEXT NOT NULL,
        abbreviation TEXT NOT NULL,
        total_chapters INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS bible_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        text TEXT NOT NULL,
        translation TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES bible_books (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_annotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER NOT NULL,
        highlight_color TEXT,
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS prayer_intentions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        is_answered INTEGER DEFAULT 0,
        reminder_time TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Create Bible Books Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bible_books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        testament TEXT NOT NULL, -- 'OT', 'NT', 'DEUTERO'
        abbreviation TEXT NOT NULL,
        total_chapters INTEGER NOT NULL
      )
    ''');

    // 2. Create Bible Verses Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS bible_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        text TEXT NOT NULL,
        translation TEXT NOT NULL, -- 'DR' (English), 'SUV' (Swahili)
        FOREIGN KEY (book_id) REFERENCES bible_books (id) ON DELETE CASCADE
      )
    ''');

    // 3. Create Bookmarks/Highlights Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_annotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER NOT NULL,
        highlight_color TEXT, -- hex string or null
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 4. Create Prayer Intentions Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS prayer_intentions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        is_answered INTEGER DEFAULT 0, -- 0 = false, 1 = true
        reminder_time TEXT, -- HH:mm format or null
        created_at TEXT NOT NULL
      )
    ''');

    // 5. Create App Settings Table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    // Seed the database
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // Seed Catholic Bible Books (OT, NT, and Deuterocanonical Books)
    final books = [
      // Pentateuch
      {
        'name': 'Genesis',
        'testament': 'OT',
        'abbreviation': 'Gen',
        'total_chapters': 50,
      },
      {
        'name': 'Exodus',
        'testament': 'OT',
        'abbreviation': 'Exo',
        'total_chapters': 40,
      },
      {
        'name': 'Leviticus',
        'testament': 'OT',
        'abbreviation': 'Lev',
        'total_chapters': 27,
      },
      {
        'name': 'Numbers',
        'testament': 'OT',
        'abbreviation': 'Num',
        'total_chapters': 36,
      },
      {
        'name': 'Deuteronomy',
        'testament': 'OT',
        'abbreviation': 'Deu',
        'total_chapters': 34,
      },
      // Historical
      {
        'name': 'Joshua',
        'testament': 'OT',
        'abbreviation': 'Jos',
        'total_chapters': 24,
      },
      {
        'name': 'Judges',
        'testament': 'OT',
        'abbreviation': 'Jdg',
        'total_chapters': 21,
      },
      {
        'name': 'Ruth',
        'testament': 'OT',
        'abbreviation': 'Rut',
        'total_chapters': 4,
      },
      {
        'name': '1 Samuel',
        'testament': 'OT',
        'abbreviation': '1 Sam',
        'total_chapters': 31,
      },
      {
        'name': '2 Samuel',
        'testament': 'OT',
        'abbreviation': '2 Sam',
        'total_chapters': 24,
      },
      {
        'name': '1 Kings',
        'testament': 'OT',
        'abbreviation': '1 Kgs',
        'total_chapters': 22,
      },
      {
        'name': '2 Kings',
        'testament': 'OT',
        'abbreviation': '2 Kgs',
        'total_chapters': 25,
      },
      {
        'name': '1 Chronicles',
        'testament': 'OT',
        'abbreviation': '1 Chr',
        'total_chapters': 29,
      },
      {
        'name': '2 Chronicles',
        'testament': 'OT',
        'abbreviation': '2 Chr',
        'total_chapters': 36,
      },
      {
        'name': 'Ezra',
        'testament': 'OT',
        'abbreviation': 'Ezr',
        'total_chapters': 10,
      },
      {
        'name': 'Nehemiah',
        'testament': 'OT',
        'abbreviation': 'Neh',
        'total_chapters': 13,
      },
      // Deuterocanonical Historical
      {
        'name': 'Tobit',
        'testament': 'DEUTERO',
        'abbreviation': 'Tob',
        'total_chapters': 14,
      },
      {
        'name': 'Judith',
        'testament': 'DEUTERO',
        'abbreviation': 'Jdt',
        'total_chapters': 16,
      },
      {
        'name': 'Esther',
        'testament': 'OT',
        'abbreviation': 'Est',
        'total_chapters': 10,
      },
      {
        'name': '1 Maccabees',
        'testament': 'DEUTERO',
        'abbreviation': '1 Mac',
        'total_chapters': 16,
      },
      {
        'name': '2 Maccabees',
        'testament': 'DEUTERO',
        'abbreviation': '2 Mac',
        'total_chapters': 15,
      },
      // Wisdom / Poetry
      {
        'name': 'Job',
        'testament': 'OT',
        'abbreviation': 'Job',
        'total_chapters': 42,
      },
      {
        'name': 'Psalms',
        'testament': 'OT',
        'abbreviation': 'Psa',
        'total_chapters': 150,
      },
      {
        'name': 'Proverbs',
        'testament': 'OT',
        'abbreviation': 'Pro',
        'total_chapters': 31,
      },
      {
        'name': 'Ecclesiastes',
        'testament': 'OT',
        'abbreviation': 'Ecc',
        'total_chapters': 12,
      },
      {
        'name': 'Song of Songs',
        'testament': 'OT',
        'abbreviation': 'Song',
        'total_chapters': 8,
      },
      // Deuterocanonical Wisdom
      {
        'name': 'Wisdom of Solomon',
        'testament': 'DEUTERO',
        'abbreviation': 'Wis',
        'total_chapters': 19,
      },
      {
        'name': 'Sirach (Ecclesiasticus)',
        'testament': 'DEUTERO',
        'abbreviation': 'Sir',
        'total_chapters': 51,
      },
      // Prophets
      {
        'name': 'Isaiah',
        'testament': 'OT',
        'abbreviation': 'Isa',
        'total_chapters': 66,
      },
      {
        'name': 'Jeremiah',
        'testament': 'OT',
        'abbreviation': 'Jer',
        'total_chapters': 52,
      },
      {
        'name': 'Lamentations',
        'testament': 'OT',
        'abbreviation': 'Lam',
        'total_chapters': 5,
      },
      // Deuterocanonical Prophets
      {
        'name': 'Baruch',
        'testament': 'DEUTERO',
        'abbreviation': 'Bar',
        'total_chapters': 6,
      },
      {
        'name': 'Ezekiel',
        'testament': 'OT',
        'abbreviation': 'Eze',
        'total_chapters': 48,
      },
      {
        'name': 'Daniel',
        'testament': 'OT',
        'abbreviation': 'Dan',
        'total_chapters': 14,
      },
      // Minor Prophets
      {
        'name': 'Hosea',
        'testament': 'OT',
        'abbreviation': 'Hos',
        'total_chapters': 14,
      },
      {
        'name': 'Joel',
        'testament': 'OT',
        'abbreviation': 'Joe',
        'total_chapters': 3,
      },
      {
        'name': 'Amos',
        'testament': 'OT',
        'abbreviation': 'Amo',
        'total_chapters': 9,
      },
      {
        'name': 'Obadiah',
        'testament': 'OT',
        'abbreviation': 'Oba',
        'total_chapters': 1,
      },
      {
        'name': 'Jonah',
        'testament': 'OT',
        'abbreviation': 'Jon',
        'total_chapters': 4,
      },
      {
        'name': 'Micah',
        'testament': 'OT',
        'abbreviation': 'Mic',
        'total_chapters': 7,
      },
      {
        'name': 'Nahum',
        'testament': 'OT',
        'abbreviation': 'Nah',
        'total_chapters': 3,
      },
      {
        'name': 'Habakkuk',
        'testament': 'OT',
        'abbreviation': 'Hab',
        'total_chapters': 3,
      },
      {
        'name': 'Zephaniah',
        'testament': 'OT',
        'abbreviation': 'Zep',
        'total_chapters': 3,
      },
      {
        'name': 'Haggai',
        'testament': 'OT',
        'abbreviation': 'Hag',
        'total_chapters': 2,
      },
      {
        'name': 'Zechariah',
        'testament': 'OT',
        'abbreviation': 'Zec',
        'total_chapters': 14,
      },
      {
        'name': 'Malachi',
        'testament': 'OT',
        'abbreviation': 'Mal',
        'total_chapters': 4,
      },

      // Gospels
      {
        'name': 'Matthew',
        'testament': 'NT',
        'abbreviation': 'Mat',
        'total_chapters': 28,
      },
      {
        'name': 'Mark',
        'testament': 'NT',
        'abbreviation': 'Mrk',
        'total_chapters': 16,
      },
      {
        'name': 'Luke',
        'testament': 'NT',
        'abbreviation': 'Luk',
        'total_chapters': 24,
      },
      {
        'name': 'John',
        'testament': 'NT',
        'abbreviation': 'Jhn',
        'total_chapters': 21,
      },
      // Acts
      {
        'name': 'Acts',
        'testament': 'NT',
        'abbreviation': 'Act',
        'total_chapters': 28,
      },
      // Epistles
      {
        'name': 'Romans',
        'testament': 'NT',
        'abbreviation': 'Rom',
        'total_chapters': 16,
      },
      {
        'name': '1 Corinthians',
        'testament': 'NT',
        'abbreviation': '1 Cor',
        'total_chapters': 16,
      },
      {
        'name': '2 Corinthians',
        'testament': 'NT',
        'abbreviation': '2 Cor',
        'total_chapters': 13,
      },
      {
        'name': 'Galatians',
        'testament': 'NT',
        'abbreviation': 'Gal',
        'total_chapters': 6,
      },
      {
        'name': 'Ephesians',
        'testament': 'NT',
        'abbreviation': 'Eph',
        'total_chapters': 6,
      },
      {
        'name': 'Philippians',
        'testament': 'NT',
        'abbreviation': 'Php',
        'total_chapters': 4,
      },
      {
        'name': 'Colossians',
        'testament': 'NT',
        'abbreviation': 'Col',
        'total_chapters': 4,
      },
      {
        'name': '1 Thessalonians',
        'testament': 'NT',
        'abbreviation': '1 Th',
        'total_chapters': 5,
      },
      {
        'name': '2 Thessalonians',
        'testament': 'NT',
        'abbreviation': '2 Th',
        'total_chapters': 3,
      },
      {
        'name': '1 Timothy',
        'testament': 'NT',
        'abbreviation': '1 Tim',
        'total_chapters': 6,
      },
      {
        'name': '2 Timothy',
        'testament': 'NT',
        'abbreviation': '2 Tim',
        'total_chapters': 4,
      },
      {
        'name': 'Titus',
        'testament': 'NT',
        'abbreviation': 'Tit',
        'total_chapters': 3,
      },
      {
        'name': 'Philemon',
        'testament': 'NT',
        'abbreviation': 'Phm',
        'total_chapters': 1,
      },
      {
        'name': 'Hebrews',
        'testament': 'NT',
        'abbreviation': 'Heb',
        'total_chapters': 13,
      },
      {
        'name': 'James',
        'testament': 'NT',
        'abbreviation': 'Jas',
        'total_chapters': 5,
      },
      {
        'name': '1 Peter',
        'testament': 'NT',
        'abbreviation': '1 Pe',
        'total_chapters': 5,
      },
      {
        'name': '2 Peter',
        'testament': 'NT',
        'abbreviation': '2 Pe',
        'total_chapters': 3,
      },
      {
        'name': '1 John',
        'testament': 'NT',
        'abbreviation': '1 Jn',
        'total_chapters': 5,
      },
      {
        'name': '2 John',
        'testament': 'NT',
        'abbreviation': '2 Jn',
        'total_chapters': 1,
      },
      {
        'name': '3 John',
        'testament': 'NT',
        'abbreviation': '3 Jn',
        'total_chapters': 1,
      },
      {
        'name': 'Jude',
        'testament': 'NT',
        'abbreviation': 'Jud',
        'total_chapters': 1,
      },
      {
        'name': 'Revelation',
        'testament': 'NT',
        'abbreviation': 'Rev',
        'total_chapters': 22,
      },
    ];

    for (var book in books) {
      await db.insert('bible_books', book);
    }

    // Seeding sample verses removed in favor of full JSON seeding
  }

  // Mapping from Douay-Rheims JSON book names to database book names
  static const Map<String, String> _jsonKeyToDbBookName = {
    'Genesis': 'Genesis',
    'Exodus': 'Exodus',
    'Leviticus': 'Leviticus',
    'Numbers': 'Numbers',
    'Deuteronomy': 'Deuteronomy',
    'Josue': 'Joshua',
    'Judges': 'Judges',
    'Ruth': 'Ruth',
    '1 Kings': '1 Samuel',
    '2 Kings': '2 Samuel',
    '3 Kings': '1 Kings',
    '4 Kings': '2 Kings',
    '1 Paralipomenon': '1 Chronicles',
    '2 Paralipomenon': '2 Chronicles',
    '1 Esdras': 'Ezra',
    '2 Esdras': 'Nehemiah',
    'Tobias': 'Tobit',
    'Judith': 'Judith',
    'Esther': 'Esther',
    '1 Machabees': '1 Maccabees',
    '2 Machabees': '2 Maccabees',
    'Job': 'Job',
    'Psalms': 'Psalms',
    'Proverbs': 'Proverbs',
    'Ecclesiastes': 'Ecclesiastes',
    'Canticles': 'Song of Songs',
    'Wisdom': 'Wisdom of Solomon',
    'Ecclesiasticus': 'Sirach (Ecclesiasticus)',
    'Isaias': 'Isaiah',
    'Jeremias': 'Jeremiah',
    'Lamentations': 'Lamentations',
    'Baruch': 'Baruch',
    'Ezechiel': 'Ezekiel',
    'Daniel': 'Daniel',
    'Osee': 'Hosea',
    'Joel': 'Joel',
    'Amos': 'Amos',
    'Abdias': 'Obadiah',
    'Jonas': 'Jonah',
    'Micheas': 'Micah',
    'Nahum': 'Nahum',
    'Habacuc': 'Habakkuk',
    'Sophonias': 'Zephaniah',
    'Aggeus': 'Haggai',
    'Zacharias': 'Zechariah',
    'Malachias': 'Malachi',
    'Matthew': 'Matthew',
    'Mark': 'Mark',
    'Luke': 'Luke',
    'John': 'John',
    'Acts': 'Acts',
    'Romans': 'Romans',
    '1 Corinthians': '1 Corinthians',
    '2 Corinthians': '2 Corinthians',
    'Galatians': 'Galatians',
    'Ephesians': 'Ephesians',
    'Philippians': 'Philippians',
    'Colossians': 'Colossians',
    '1 Thessalonians': '1 Thessalonians',
    '2 Thessalonians': '2 Thessalonians',
    '1 Timothy': '1 Timothy',
    '2 Timothy': '2 Timothy',
    'Titus': 'Titus',
    'Philemon': 'Philemon',
    'Hebrews': 'Hebrews',
    'James': 'James',
    '1 Peter': '1 Peter',
    '2 Peter': '2 Peter',
    '1 John': '1 John',
    '2 John': '2 John',
    '3 John': '3 John',
    'Jude': 'Jude',
    'Apocalypse': 'Revelation',
  };

  Future<void> _checkAndSeedBible(Database db) async {
    try {
      // Ensure the books count is verified
      final booksCount =
          Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM bible_books'),
          ) ??
          0;

      if (booksCount == 0) {
        // If books are not seeded for some reason, seed them first
        await _seedDatabase(db);
      }

      // Check if English verses are seeded
      final drCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM bible_verses WHERE translation = 'DR'",
            ),
          ) ??
          0;

      if (drCount < 100) {
        await _seedBibleFromJson(db);
      }

      // Check if Swahili verses are seeded
      final suvCount =
          Sqflite.firstIntValue(
            await db.rawQuery(
              "SELECT COUNT(*) FROM bible_verses WHERE translation = 'SUV'",
            ),
          ) ??
          0;

      if (suvCount < 100) {
        await _seedSwahiliBibleFromJson(db);
      }
    } catch (e) {
      print('Error during Bible seeding check: $e');
    }
  }

  Future<void> _seedBibleFromJson(Database db) async {
    try {
      print('Seeding English Bible from JSON asset...');
      final jsonString = await rootBundle.loadString(
        'assets/scripture/douay_rheims.json',
      );
      final Map<String, dynamic> bibleJson = json.decode(jsonString);

      // Fetch books to map names to their database IDs
      final List<Map<String, dynamic>> bookRows = await db.query('bible_books');
      final Map<String, int> bookNameToId = {
        for (var row in bookRows) row['name'] as String: row['id'] as int,
      };

      await db.transaction((txn) async {
        await txn.delete(
          'bible_verses',
          where: 'translation = ?',
          whereArgs: ['DR'],
        );

        var batch = txn.batch();
        var queued = 0;
        const chunkSize = 1000;

        for (var jsonKey in bibleJson.keys) {
          final dbBookName = _jsonKeyToDbBookName[jsonKey];
          if (dbBookName == null) {
            print(
              'Warning: No database book mapping found for JSON key $jsonKey',
            );
            continue;
          }

          final bookId = bookNameToId[dbBookName];
          if (bookId == null) {
            print('Warning: Book ID not found for $dbBookName in database');
            continue;
          }

          final Map<String, dynamic> chaptersMap = bibleJson[jsonKey];
          for (var chapterStr in chaptersMap.keys) {
            final int? chapter = int.tryParse(chapterStr);
            if (chapter == null) continue;

            final Map<String, dynamic> versesMap = chaptersMap[chapterStr];
            for (var verseStr in versesMap.keys) {
              final int? verse = int.tryParse(verseStr);
              if (verse == null) continue;

              String text = versesMap[verseStr] as String;
              // Clean up the text: remove Vulgate footnotes indicator '*' and trim whitespace
              text = text.replaceAll('*', '').trim();

              batch.insert('bible_verses', {
                'book_id': bookId,
                'chapter': chapter,
                'verse': verse,
                'text': text,
                'translation': 'DR',
              });
              queued++;

              if (queued >= chunkSize) {
                await batch.commit(noResult: true);
                batch = txn.batch();
                queued = 0;
              }
            }
          }
        }

        if (queued > 0) {
          await batch.commit(noResult: true);
        }
      });
      print('English Bible database successfully seeded with all verses.');
    } catch (e) {
      print('Error seeding Bible from JSON: $e');
    }
  }

  // Mapping from Swahili JSON book names to database book names
  static const Map<String, String> _swahiliBookMapping = {
    'Mwanzo': 'Genesis',
    'Kutoka': 'Exodus',
    'Mambo ya Walawi': 'Leviticus',
    'Hesabu': 'Numbers',
    'Kumbukumbu la Torati': 'Deuteronomy',
    'Yoshua': 'Joshua',
    'Waamuzi': 'Judges',
    'Ruthu': 'Ruth',
    '1 Samueli': '1 Samuel',
    '2 Samueli': '2 Samuel',
    '1 Wafalme': '1 Kings',
    '2 Wafalme': '2 Kings',
    '1 Mambo ya Nyakati': '1 Chronicles',
    '2 Mambo ya Nyakati': '2 Chronicles',
    'Ezra': 'Ezra',
    'Nehemia': 'Nehemiah',
    'Esta': 'Esther',
    'Ayubu': 'Job',
    'Zaburi': 'Psalms',
    'Mithali': 'Proverbs',
    'Mhubiri': 'Ecclesiastes',
    'Wimbo Ulio Bora': 'Song of Songs',
    'Isaya': 'Isaiah',
    'Yeremia': 'Jeremiah',
    'Maombolezo': 'Lamentations',
    'Ezekieli': 'Ezekiel',
    'Danieli': 'Daniel',
    'Hosea': 'Hosea',
    'Yoeli': 'Joel',
    'Amosi': 'Amos',
    'Obadia': 'Obadiah',
    'Yona': 'Jonah',
    'Mika': 'Micah',
    'Nahumu': 'Nahum',
    'Habakuki': 'Habakkuk',
    'Sefania': 'Zephaniah',
    'Hagai': 'Haggai',
    'Zekaria': 'Zechariah',
    'Malaki': 'Malachi',
    'Mathayo': 'Matthew',
    'Marko': 'Mark',
    'Luka': 'Luke',
    'Yohana': 'John',
    'Matendo ya Mitume': 'Acts',
    'Warumi': 'Romans',
    '1 Wakorintho': '1 Corinthians',
    '2 Wakorintho': '2 Corinthians',
    'Wagalatia': 'Galatians',
    'Waefeso': 'Ephesians',
    'Wafilipi': 'Philippians',
    'Wakolosai': 'Colossians',
    '1 Wathesalonike': '1 Thessalonians',
    '2 Wathesalonike': '2 Thessalonians',
    '1 Timotheo': '1 Timothy',
    '2 Timotheo': '2 Timothy',
    'Tito': 'Titus',
    'Filemoni': 'Philemon',
    'Waebrania': 'Hebrews',
    'Yakobo': 'James',
    '1 Petro': '1 Peter',
    '2 Petro': '2 Peter',
    '1 Yohana': '1 John',
    '2 Yohana': '2 John',
    '3 Yohana': '3 John',
    'Yuda': 'Jude',
    'Ufunuo wa Yohana': 'Revelation',
  };

  Future<void> _seedSwahiliBibleFromJson(Database db) async {
    try {
      print('Seeding Swahili Bible from JSON asset...');
      final jsonString = await rootBundle.loadString(
        'assets/scripture/swahili_union.json',
      );
      final Map<String, dynamic> bibleJson = json.decode(jsonString);

      // Fetch books to map names to their database IDs
      final List<Map<String, dynamic>> bookRows = await db.query('bible_books');
      final Map<String, int> bookNameToId = {
        for (var row in bookRows) row['name'] as String: row['id'] as int,
      };

      await db.transaction((txn) async {
        await txn.delete(
          'bible_verses',
          where: 'translation = ?',
          whereArgs: ['SUV'],
        );

        var batch = txn.batch();
        var queued = 0;
        const chunkSize = 1000;

        final List<dynamic> booksList = bibleJson['BIBLEBOOK'] as List<dynamic>;
        for (var bookObj in booksList) {
          final String? swBookName = bookObj['book_name'] as String?;
          if (swBookName == null) continue;

          final dbBookName = _swahiliBookMapping[swBookName];
          if (dbBookName == null) {
            print(
              'Warning: No database book mapping found for Swahili key $swBookName',
            );
            continue;
          }

          final bookId = bookNameToId[dbBookName];
          if (bookId == null) {
            print('Warning: Book ID not found for $dbBookName in database');
            continue;
          }

          final rawChapters = bookObj['CHAPTER'];
          final List<dynamic> chaptersList = rawChapters is List
              ? rawChapters
              : (rawChapters is Map ? [rawChapters] : []);

          for (var chapterObj in chaptersList) {
            final String? chapterStr = chapterObj['chapter_number'] as String?;
            final int? chapter = chapterStr != null
                ? int.tryParse(chapterStr)
                : null;
            if (chapter == null) continue;

            final rawVerses = chapterObj['VERSES'];
            final List<dynamic> versesList = rawVerses is List
                ? rawVerses
                : (rawVerses is Map ? [rawVerses] : []);

            for (var verseObj in versesList) {
              final String? verseStr = verseObj['verse_number'] as String?;
              final int? verse = verseStr != null
                  ? int.tryParse(verseStr)
                  : null;
              if (verse == null) continue;

              final String? text = verseObj['verse_text'] as String?;
              if (text == null) continue;

              batch.insert('bible_verses', {
                'book_id': bookId,
                'chapter': chapter,
                'verse': verse,
                'text': text.trim(),
                'translation': 'SUV',
              });
              queued++;

              if (queued >= chunkSize) {
                await batch.commit(noResult: true);
                batch = txn.batch();
                queued = 0;
              }
            }
          }
        }

        if (queued > 0) {
          await batch.commit(noResult: true);
        }
      });
      print('Swahili Bible database successfully seeded.');
    } catch (e) {
      print('Error seeding Swahili Bible: $e');
    }
  }

  // --- API Methods for Scripture ---

  Future<List<Map<String, dynamic>>> getBibleBooks() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return [
        {
          'id': 1,
          'name': 'Genesis',
          'testament': 'OT',
          'abbreviation': 'Gen',
          'total_chapters': 50,
        },
        {
          'id': 23,
          'name': 'Psalms',
          'testament': 'OT',
          'abbreviation': 'Psa',
          'total_chapters': 150,
        },
        {
          'id': 50,
          'name': 'John',
          'testament': 'NT',
          'abbreviation': 'Jhn',
          'total_chapters': 21,
        },
      ];
    }
    final db = await instance.database;
    return await db.query('bible_books', orderBy: 'id ASC');
  }

  Future<List<Map<String, dynamic>>> getVerses(
    int bookId,
    int chapter, {
    String translation = 'DR',
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return [];
    }
    final db = await instance.database;
    final results = await db.query(
      'bible_verses',
      where: 'book_id = ? AND chapter = ? AND translation = ?',
      whereArgs: [bookId, chapter, translation],
      orderBy: 'verse ASC',
    );

    if (results.isEmpty && translation != 'DR') {
      // Fallback to English (DR) if Swahili (SUV) is not seeded for this book (e.g. Deuterocanon)
      return await db.query(
        'bible_verses',
        where: 'book_id = ? AND chapter = ? AND translation = ?',
        whereArgs: [bookId, chapter, 'DR'],
        orderBy: 'verse ASC',
      );
    }
    return results;
  }

  Future<List<Map<String, dynamic>>> searchScriptures(
    String query, {
    String translation = 'DR',
  }) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return [];
    }
    final db = await instance.database;
    return await db.query(
      'bible_verses',
      where: 'text LIKE ? AND translation = ?',
      whereArgs: ['%$query%', translation],
      limit: 50,
    );
  }

  // --- API Methods for User Annotations ---

  Future<List<Map<String, dynamic>>> getAnnotations() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return [];
    }
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT a.*, v.text as verse_text, v.verse, v.chapter, b.name as book_name
      FROM user_annotations a
      JOIN bible_verses v ON a.verse_id = v.id
      JOIN bible_books b ON v.book_id = b.id
      ORDER BY a.id DESC
    ''');
  }

  Future<int> addAnnotation(int verseId, String? color, String? note) async {
    final db = await instance.database;
    return await db.insert('user_annotations', {
      'verse_id': verseId,
      'highlight_color': color,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> deleteAnnotation(int id) async {
    final db = await instance.database;
    return await db.delete(
      'user_annotations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- API Methods for Intentions ---

  Future<List<Map<String, dynamic>>> getIntentions() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return [];
    }
    final db = await instance.database;
    return await db.query('prayer_intentions', orderBy: 'id DESC');
  }

  Future<int> addIntention(
    String title,
    String? description,
    String? reminderTime,
  ) async {
    final db = await instance.database;
    return await db.insert('prayer_intentions', {
      'title': title,
      'description': description,
      'is_answered': 0,
      'reminder_time': reminderTime,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> updateIntention(int id, Map<String, dynamic> data) async {
    final db = await instance.database;
    return await db.update(
      'prayer_intentions',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteIntention(int id) async {
    final db = await instance.database;
    return await db.delete(
      'prayer_intentions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- API Methods for App Settings ---

  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query(
      'app_settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
    );
    if (results.isNotEmpty) {
      return results.first['value'] as String?;
    }
    return null;
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert('app_settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static String getSwahiliBookName(String englishName) {
    for (var entry in _swahiliBookMapping.entries) {
      if (entry.value == englishName) {
        return entry.key;
      }
    }
    switch (englishName) {
      case 'Tobit':
        return 'Tobiti';
      case 'Judith':
        return 'Yudithi';
      case '1 Maccabees':
        return '1 Wamakabayo';
      case '2 Maccabees':
        return '2 Wamakabayo';
      case 'Wisdom of Solomon':
        return 'Hekima ya Sulemani';
      case 'Sirach (Ecclesiasticus)':
        return 'Yoshua bin Sira';
      case 'Baruch':
        return 'Baruku';
      default:
        return englishName;
    }
  }
}
