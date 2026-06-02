import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('lets_pray.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Create Bible Books Table
    await db.execute('''
      CREATE TABLE bible_books (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        testament TEXT NOT NULL, -- 'OT', 'NT', 'DEUTERO'
        abbreviation TEXT NOT NULL,
        total_chapters INTEGER NOT NULL
      )
    ''');

    // 2. Create Bible Verses Table
    await db.execute('''
      CREATE TABLE bible_verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id INTEGER NOT NULL,
        chapter INTEGER NOT NULL,
        verse INTEGER NOT NULL,
        text TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES bible_books (id) ON DELETE CASCADE
      )
    ''');

    // 3. Create Bookmarks/Highlights Table
    await db.execute('''
      CREATE TABLE user_annotations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verse_id INTEGER NOT NULL,
        highlight_color TEXT, -- hex string or null
        note TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // 4. Create Prayer Intentions Table
    await db.execute('''
      CREATE TABLE prayer_intentions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        is_answered INTEGER DEFAULT 0, -- 0 = false, 1 = true
        reminder_time TEXT, -- HH:mm format or null
        created_at TEXT NOT NULL
      )
    ''');

    // Seed the database
    await _seedDatabase(db);
  }

  Future<void> _seedDatabase(Database db) async {
    // Seed Catholic Bible Books (OT, NT, and Deuterocanonical Books)
    final books = [
      // Pentateuch
      {'name': 'Genesis', 'testament': 'OT', 'abbreviation': 'Gen', 'total_chapters': 50},
      {'name': 'Exodus', 'testament': 'OT', 'abbreviation': 'Exo', 'total_chapters': 40},
      {'name': 'Leviticus', 'testament': 'OT', 'abbreviation': 'Lev', 'total_chapters': 27},
      {'name': 'Numbers', 'testament': 'OT', 'abbreviation': 'Num', 'total_chapters': 36},
      {'name': 'Deuteronomy', 'testament': 'OT', 'abbreviation': 'Deu', 'total_chapters': 34},
      // Historical
      {'name': 'Joshua', 'testament': 'OT', 'abbreviation': 'Jos', 'total_chapters': 24},
      {'name': 'Judges', 'testament': 'OT', 'abbreviation': 'Jdg', 'total_chapters': 21},
      {'name': 'Ruth', 'testament': 'OT', 'abbreviation': 'Rut', 'total_chapters': 4},
      {'name': '1 Samuel', 'testament': 'OT', 'abbreviation': '1 Sam', 'total_chapters': 31},
      {'name': '2 Samuel', 'testament': 'OT', 'abbreviation': '2 Sam', 'total_chapters': 24},
      {'name': '1 Kings', 'testament': 'OT', 'abbreviation': '1 Kgs', 'total_chapters': 22},
      {'name': '2 Kings', 'testament': 'OT', 'abbreviation': '2 Kgs', 'total_chapters': 25},
      {'name': '1 Chronicles', 'testament': 'OT', 'abbreviation': '1 Chr', 'total_chapters': 29},
      {'name': '2 Chronicles', 'testament': 'OT', 'abbreviation': '2 Chr', 'total_chapters': 36},
      {'name': 'Ezra', 'testament': 'OT', 'abbreviation': 'Ezr', 'total_chapters': 10},
      {'name': 'Nehemiah', 'testament': 'OT', 'abbreviation': 'Neh', 'total_chapters': 13},
      // Deuterocanonical Historical
      {'name': 'Tobit', 'testament': 'DEUTERO', 'abbreviation': 'Tob', 'total_chapters': 14},
      {'name': 'Judith', 'testament': 'DEUTERO', 'abbreviation': 'Jdt', 'total_chapters': 16},
      {'name': 'Esther', 'testament': 'OT', 'abbreviation': 'Est', 'total_chapters': 10},
      {'name': '1 Maccabees', 'testament': 'DEUTERO', 'abbreviation': '1 Mac', 'total_chapters': 16},
      {'name': '2 Maccabees', 'testament': 'DEUTERO', 'abbreviation': '2 Mac', 'total_chapters': 15},
      // Wisdom / Poetry
      {'name': 'Job', 'testament': 'OT', 'abbreviation': 'Job', 'total_chapters': 42},
      {'name': 'Psalms', 'testament': 'OT', 'abbreviation': 'Psa', 'total_chapters': 150},
      {'name': 'Proverbs', 'testament': 'OT', 'abbreviation': 'Pro', 'total_chapters': 31},
      {'name': 'Ecclesiastes', 'testament': 'OT', 'abbreviation': 'Ecc', 'total_chapters': 12},
      {'name': 'Song of Songs', 'testament': 'OT', 'abbreviation': 'Song', 'total_chapters': 8},
      // Deuterocanonical Wisdom
      {'name': 'Wisdom of Solomon', 'testament': 'DEUTERO', 'abbreviation': 'Wis', 'total_chapters': 19},
      {'name': 'Sirach (Ecclesiasticus)', 'testament': 'DEUTERO', 'abbreviation': 'Sir', 'total_chapters': 51},
      // Prophets
      {'name': 'Isaiah', 'testament': 'OT', 'abbreviation': 'Isa', 'total_chapters': 66},
      {'name': 'Jeremiah', 'testament': 'OT', 'abbreviation': 'Jer', 'total_chapters': 52},
      {'name': 'Lamentations', 'testament': 'OT', 'abbreviation': 'Lam', 'total_chapters': 5},
      // Deuterocanonical Prophets
      {'name': 'Baruch', 'testament': 'DEUTERO', 'abbreviation': 'Bar', 'total_chapters': 6},
      {'name': 'Ezekiel', 'testament': 'OT', 'abbreviation': 'Eze', 'total_chapters': 48},
      {'name': 'Daniel', 'testament': 'OT', 'abbreviation': 'Dan', 'total_chapters': 14},
      // Minor Prophets
      {'name': 'Hosea', 'testament': 'OT', 'abbreviation': 'Hos', 'total_chapters': 14},
      {'name': 'Joel', 'testament': 'OT', 'abbreviation': 'Joe', 'total_chapters': 3},
      {'name': 'Amos', 'testament': 'OT', 'abbreviation': 'Amo', 'total_chapters': 9},
      {'name': 'Obadiah', 'testament': 'OT', 'abbreviation': 'Oba', 'total_chapters': 1},
      {'name': 'Jonah', 'testament': 'OT', 'abbreviation': 'Jon', 'total_chapters': 4},
      {'name': 'Micah', 'testament': 'OT', 'abbreviation': 'Mic', 'total_chapters': 7},
      {'name': 'Nahum', 'testament': 'OT', 'abbreviation': 'Nah', 'total_chapters': 3},
      {'name': 'Habakkuk', 'testament': 'OT', 'abbreviation': 'Hab', 'total_chapters': 3},
      {'name': 'Zephaniah', 'testament': 'OT', 'abbreviation': 'Zep', 'total_chapters': 3},
      {'name': 'Haggai', 'testament': 'OT', 'abbreviation': 'Hag', 'total_chapters': 2},
      {'name': 'Zechariah', 'testament': 'OT', 'abbreviation': 'Zec', 'total_chapters': 14},
      {'name': 'Malachi', 'testament': 'OT', 'abbreviation': 'Mal', 'total_chapters': 4},

      // Gospels
      {'name': 'Matthew', 'testament': 'NT', 'abbreviation': 'Mat', 'total_chapters': 28},
      {'name': 'Mark', 'testament': 'NT', 'abbreviation': 'Mrk', 'total_chapters': 16},
      {'name': 'Luke', 'testament': 'NT', 'abbreviation': 'Luk', 'total_chapters': 24},
      {'name': 'John', 'testament': 'NT', 'abbreviation': 'Jhn', 'total_chapters': 21},
      // Acts
      {'name': 'Acts', 'testament': 'NT', 'abbreviation': 'Act', 'total_chapters': 28},
      // Epistles
      {'name': 'Romans', 'testament': 'NT', 'abbreviation': 'Rom', 'total_chapters': 16},
      {'name': '1 Corinthians', 'testament': 'NT', 'abbreviation': '1 Cor', 'total_chapters': 16},
      {'name': '2 Corinthians', 'testament': 'NT', 'abbreviation': '2 Cor', 'total_chapters': 13},
      {'name': 'Galatians', 'testament': 'NT', 'abbreviation': 'Gal', 'total_chapters': 6},
      {'name': 'Ephesians', 'testament': 'NT', 'abbreviation': 'Eph', 'total_chapters': 6},
      {'name': 'Philippians', 'testament': 'NT', 'abbreviation': 'Php', 'total_chapters': 4},
      {'name': 'Colossians', 'testament': 'NT', 'abbreviation': 'Col', 'total_chapters': 4},
      {'name': '1 Thessalonians', 'testament': 'NT', 'abbreviation': '1 Th', 'total_chapters': 5},
      {'name': '2 Thessalonians', 'testament': 'NT', 'abbreviation': '2 Th', 'total_chapters': 3},
      {'name': '1 Timothy', 'testament': 'NT', 'abbreviation': '1 Tim', 'total_chapters': 6},
      {'name': '2 Timothy', 'testament': 'NT', 'abbreviation': '2 Tim', 'total_chapters': 4},
      {'name': 'Titus', 'testament': 'NT', 'abbreviation': 'Tit', 'total_chapters': 3},
      {'name': 'Philemon', 'testament': 'NT', 'abbreviation': 'Phm', 'total_chapters': 1},
      {'name': 'Hebrews', 'testament': 'NT', 'abbreviation': 'Heb', 'total_chapters': 13},
      {'name': 'James', 'testament': 'NT', 'abbreviation': 'Jas', 'total_chapters': 5},
      {'name': '1 Peter', 'testament': 'NT', 'abbreviation': '1 Pe', 'total_chapters': 5},
      {'name': '2 Peter', 'testament': 'NT', 'abbreviation': '2 Pe', 'total_chapters': 3},
      {'name': '1 John', 'testament': 'NT', 'abbreviation': '1 Jn', 'total_chapters': 5},
      {'name': '2 John', 'testament': 'NT', 'abbreviation': '2 Jn', 'total_chapters': 1},
      {'name': '3 John', 'testament': 'NT', 'abbreviation': '3 Jn', 'total_chapters': 1},
      {'name': 'Jude', 'testament': 'NT', 'abbreviation': 'Jud', 'total_chapters': 1},
      {'name': 'Revelation', 'testament': 'NT', 'abbreviation': 'Rev', 'total_chapters': 22},
    ];

    for (var book in books) {
      await db.insert('bible_books', book);
    }

    // Seed sample verses from key scriptures
    final verses = [
      // Psalms 23
      {'book_id': 23, 'chapter': 23, 'verse': 1, 'text': 'The Lord is my shepherd; I shall not want.'},
      {'book_id': 23, 'chapter': 23, 'verse': 2, 'text': 'He maketh me to lie down in green pastures: he leadeth me beside the still waters.'},
      {'book_id': 23, 'chapter': 23, 'verse': 3, 'text': 'He restoreth my soul: he leadeth me in the paths of righteousness for his name\'s sake.'},
      {'book_id': 23, 'chapter': 23, 'verse': 4, 'text': 'Yea, though I walk through the valley of the shadow of death, I will fear no evil: for thou art with me; thy rod and thy staff they comfort me.'},
      {'book_id': 23, 'chapter': 23, 'verse': 5, 'text': 'Thou preparest a table before me in the presence of mine enemies: thou anointest my head with oil; my cup runneth over.'},
      {'book_id': 23, 'chapter': 23, 'verse': 6, 'text': 'Surely goodness and mercy shall follow me all the days of my life: and I will dwell in the house of the Lord for ever.'},

      // John 3:16
      {'book_id': 50, 'chapter': 3, 'verse': 16, 'text': 'For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.'},

      // Luke 1:28 (Hail Mary Scriptural Origin)
      {'book_id': 49, 'chapter': 1, 'verse': 28, 'text': 'And the angel being come in, said unto her: Hail, full of grace, the Lord is with thee: blessed art thou among women.'},
      {'book_id': 49, 'chapter': 1, 'verse': 42, 'text': 'And she cried out with a loud voice, and said: Blessed art thou among women, and blessed is the fruit of thy womb.'},

      // Matthew 6 (Our Father Scriptural Origin)
      {'book_id': 47, 'chapter': 6, 'verse': 9, 'text': 'Thus therefore shall you pray: Our Father who art in heaven, hallowed be thy name.'},
      {'book_id': 47, 'chapter': 6, 'verse': 10, 'text': 'Thy kingdom come. Thy will be done on earth as it is in heaven.'},
      {'book_id': 47, 'chapter': 6, 'verse': 11, 'text': 'Give us this day our supersubstantial bread.'},
      {'book_id': 47, 'chapter': 6, 'verse': 12, 'text': 'And forgive us our debts, as we also forgive our debtors.'},
      {'book_id': 47, 'chapter': 6, 'verse': 13, 'text': 'And lead us not into temptation. But deliver us from evil. Amen.'},

      // Sirach (Deuterocanonical Example)
      {'book_id': 28, 'chapter': 2, 'verse': 1, 'text': 'My son, when thou comest to the service of God, stand in justice and in fear, and prepare thy soul for temptation.'},
      {'book_id': 28, 'chapter': 2, 'verse': 2, 'text': 'Humble thy heart, and endure: incline thy ear, and receive the words of understanding: and make not haste in the time of clouds.'},
      {'book_id': 28, 'chapter': 2, 'verse': 3, 'text': 'Wait on God with patience: join thyself to God, and endure, that thy life may be increased in the latter end.'},
      {'book_id': 28, 'chapter': 2, 'verse': 4, 'text': 'Take all that shall be brought upon thee: and in thy sorrow endure, and in thy humiliation keep patience.'},
      {'book_id': 28, 'chapter': 2, 'verse': 5, 'text': 'For gold and silver are tried in the fire, but acceptable men in the furnace of humiliation.'},
    ];

    for (var verse in verses) {
      await db.insert('bible_verses', verse);
    }
  }

  // --- API Methods for Scripture ---

  Future<List<Map<String, dynamic>>> getBibleBooks() async {
    final db = await instance.database;
    return await db.query('bible_books', orderBy: 'id ASC');
  }

  Future<List<Map<String, dynamic>>> getVerses(int bookId, int chapter) async {
    final db = await instance.database;
    return await db.query(
      'bible_verses',
      where: 'book_id = ? AND chapter = ?',
      whereArgs: [bookId, chapter],
      orderBy: 'verse ASC',
    );
  }

  Future<List<Map<String, dynamic>>> searchScriptures(String query) async {
    final db = await instance.database;
    return await db.query(
      'bible_verses',
      where: 'text LIKE ?',
      whereArgs: ['%$query%'],
      limit: 50,
    );
  }

  // --- API Methods for User Annotations ---

  Future<List<Map<String, dynamic>>> getAnnotations() async {
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
    return await db.delete('user_annotations', where: 'id = ?', whereArgs: [id]);
  }

  // --- API Methods for Intentions ---

  Future<List<Map<String, dynamic>>> getIntentions() async {
    final db = await instance.database;
    return await db.query('prayer_intentions', orderBy: 'id DESC');
  }

  Future<int> addIntention(String title, String? description, String? reminderTime) async {
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
    return await db.update('prayer_intentions', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteIntention(int id) async {
    final db = await instance.database;
    return await db.delete('prayer_intentions', where: 'id = ?', whereArgs: [id]);
  }
}
