import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:upgrader/upgrader.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../rosary/presentation/rosary_notifier.dart';
import '../../game/presentation/bible_quiz_screen.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rosaryState = ref.watch(rosaryProvider);
    final locale = ref.watch(localeProvider);

    // Calculate liturgical variables based on current date and locale
    final String season = _getLiturgicalSeason(locale);
    final Color seasonColor = _getLiturgicalSeasonColor(season);
    final String saintName = _getSaintOfTheDay(locale);
    final String saintQuote = _getSaintQuote(locale);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.church, color: AppTheme.liturgicalGold, size: 24),
            const SizedBox(width: 8),
            Text(
              AppStrings.of(ref, 'dashboard_title'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
            ),
          ],
        ),
      ),
      body: UpgradeAlert(
        
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Liturgical Season Card Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        seasonColor.withOpacity(0.75),
                        seasonColor.withOpacity(0.35),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: seasonColor.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getFormattedDate(locale),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        season,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 26,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        locale == 'sw'
                            ? 'Tukiinue mioyo yetu katika tafakari ya kimya na masomo leo.'
                            : 'Let us elevate our hearts in quiet contemplation and study today.',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
        
                // 2. Saint of the Day Section
                Text(
                  AppStrings.of(ref, 'dashboard_saint').toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.liturgicalGold, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              saintName,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          saintQuote,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Lora',
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
        
                // 3. Quick Action Devotionals Grid
                Text(
                  locale == 'sw' ? 'DEVOSHONALI ZA HARAKA' : 'QUICK DEVOTIONALS',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
        
                // Rosary Quick Card
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onNavigate(2), // Navigate to Rosary Screen
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.liturgicalGold.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.circle_outlined,
                              color: AppTheme.liturgicalGold,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.of(ref, 'card_rosary_title'),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  locale == 'sw'
                                      ? 'Leo: Tafakari juu ya Masumbuko ya ${_getMysteryNameSw(rosaryState.activeMysteryKey)}'
                                      : 'Today: Meditate on the ${rosaryState.activeMysteryKey} Mysteries',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
        
                // Bible Study Quick Card
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onNavigate(1), // Navigate to Bible Screen
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.menu_book,
                              color: Colors.blue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.of(ref, 'card_bible_title'),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  locale == 'sw'
                                      ? 'Soma Agano la Kale, Jipya, na Vitabu vya Deuterokanononi'
                                      : 'Read OT, NT, and Deuterocanonical Books',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
        
                // Bible Quiz Game Card
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BibleQuizScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppTheme.liturgicalViolet.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.psychology,
                              color: AppTheme.liturgicalViolet,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.of(ref, 'card_game_title'),
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  AppStrings.of(ref, 'card_game_subtitle'),
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textMuted),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Liturgical helper methods
  String _getLiturgicalSeason(String locale) {
    // Basic approximation of liturgical seasons
    final month = DateTime.now().month;
    if (month == 12) {
      return locale == 'sw' ? 'Msimu wa Ujio / Krismasi' : 'Season of Advent / Christmas';
    }
    if (month == 3 || month == 4) {
      return locale == 'sw' ? 'Msimu wa Kwaresma / Pasaka' : 'Season of Lent / Easter';
    }
    return locale == 'sw' ? 'Kipindi cha Kawaida' : 'Ordinary Time';
  }

  Color _getLiturgicalSeasonColor(String season) {
    if (season.contains('Advent') || season.contains('Ujio') || season.contains('Lent') || season.contains('Kwaresma')) {
      return AppTheme.liturgicalViolet;
    }
    if (season.contains('Christmas') || season.contains('Krismasi') || season.contains('Easter') || season.contains('Pasaka')) {
      return AppTheme.liturgicalGold;
    }
    return AppTheme.liturgicalGreen;
  }

  String _getSaintOfTheDay(String locale) {
    final day = DateTime.now().day;
    final saintsEn = [
      'St. Augustine of Hippo',
      'St. Therese of Lisieux',
      'St. Francis of Assisi',
      'St. Thomas Aquinas',
      'St. Padre Pio',
      'St. Ignatius of Loyola',
      'St. Teresa of Avila'
    ];
    final saintsSw = [
      'Mtakatifu Agostina wa Hippo',
      'Mtakatifu Teresa wa Lisieux',
      'Mtakatifu Fransisko wa Asizi',
      'Mtakatifu Tomaso wa Akwino',
      'Mtakatifu Padre Pio',
      'Mtakatifu Inyasi wa Loyola',
      'Mtakatifu Teresa wa Avila'
    ];
    return locale == 'sw' ? saintsSw[day % saintsSw.length] : saintsEn[day % saintsEn.length];
  }

  String _getSaintQuote(String locale) {
    final day = DateTime.now().day;
    final quotesEn = [
      '"Thou hast made us for Thyself, O Lord, and our hearts are restless until they rest in Thee."',
      '"Without love, deeds, even the most brilliant, count as nothing."',
      '"Start by doing what\'s necessary; then do what\'s possible; and suddenly you are doing the impossible."',
      '"To one who has faith, no explanation is necessary. To one without faith, no explanation is possible."',
      '"Pray, hope, and don\'t worry. Worry is useless. God is merciful and will hear your prayer."',
      '"He who is not key to our hearts, does not know the way of our soul."',
      '"Let nothing disturb thee, nothing affright thee; all things are passing; God never changeth."'
    ];
    final quotesSw = [
      '"Ulimtengeneza kwa ajili yako mwenyewe, Ee Bwana, na mioyo yetu haina utulivu mpaka ipumzike ndani yako."',
      '"Bila upendo, matendo, hata yale ya kupendeza zaidi, si kitu."',
      '"Anza kwa kufanya kile kinachohitajika; kisha fanya kile kinachowezekana; na ghafla unafanya yasiyowezekana."',
      '"Kwa mtu mwenye imani, hakuna ufafanuzi unaohitajika. Kwa mtu asiye na imani, hakuna ufafanuzi unaowezekana."',
      '"Sali, tumaini, na usiwe na wasiwasi. Wasiwasi haufai kitu. Mungu ni mwenye rehema na atasikia sala yako."',
      '"Yeye asiye ufunguo wa mioyo yetu, hajui njia ya roho zetu."',
      '"Usisumbuke na chochote, usiogope chochote; mambo yote yanapita; Mungu habadiliki kamwe."'
    ];
    return locale == 'sw' ? quotesSw[day % quotesSw.length] : quotesEn[day % quotesEn.length];
  }

  String _getFormattedDate(String locale) {
    final date = DateTime.now();
    final weekdayNamesEn = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekdayNamesSw = ['Jumatatu', 'Jumanne', 'Jumatano', 'Alhamisi', 'Ijumaa', 'Jumamosi', 'Jumapili'];
    final monthNamesEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final monthNamesSw = ['Jan', 'Feb', 'Mac', 'Apr', 'Mei', 'Jun', 'Jul', 'Ago', 'Sep', 'Okt', 'Nov', 'Des'];

    final weekday = locale == 'sw' ? weekdayNamesSw[date.weekday - 1] : weekdayNamesEn[date.weekday - 1];
    final month = locale == 'sw' ? monthNamesSw[date.month - 1] : monthNamesEn[date.month - 1];

    return '${weekday.toUpperCase()}, ${month.toUpperCase()} ${date.day}';
  }

  String _getMysteryNameSw(String englishMystery) {
    switch (englishMystery) {
      case 'Joyful':
        return 'Furaha';
      case 'Sorrowful':
        return 'Huzuni';
      case 'Glorious':
        return 'Utukufu';
      case 'Luminous':
        return 'Mwanga';
      default:
        return englishMystery;
    }
  }
}
