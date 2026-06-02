import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../rosary/presentation/rosary_notifier.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rosaryState = ref.watch(rosaryProvider);

    // Calculate liturgical variables based on current date
    final String season = _getLiturgicalSeason();
    final Color seasonColor = _getLiturgicalSeasonColor(season);
    final String saintName = _getSaintOfTheDay();
    final String saintQuote = _getSaintQuote();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.church, color: AppTheme.liturgicalGold, size: 24),
            const SizedBox(width: 8),
            Text(
              'LET\'S PRAY',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
            ),
          ],
        ),
      ),
      body: SafeArea(
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
                      _getFormattedDate(),
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
                    const Text(
                      'Let us elevate our hearts in quiet contemplation and study today.',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 2. Saint of the Day Section
              Text(
                'SAINT OF THE DAY',
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
                'QUICK DEVOTIONALS',
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
                                'Pray the Holy Rosary',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Today: Meditate on the ${rosaryState.activeMysteryKey} Mysteries',
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
                                'Catholic Bible Study',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Read OT, NT, and Deuterocanonical Books',
                                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
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
    );
  }

  // Liturgical helper methods
  String _getLiturgicalSeason() {
    // Basic approximation of liturgical seasons
    final month = DateTime.now().month;
    if (month == 12) return 'Season of Advent / Christmas';
    if (month == 3 || month == 4) return 'Season of Lent / Easter';
    return 'Ordinary Time';
  }

  Color _getLiturgicalSeasonColor(String season) {
    if (season.contains('Advent') || season.contains('Lent')) {
      return AppTheme.liturgicalViolet;
    }
    if (season.contains('Christmas') || season.contains('Easter')) {
      return AppTheme.liturgicalGold;
    }
    return AppTheme.liturgicalGreen;
  }

  String _getSaintOfTheDay() {
    final day = DateTime.now().day;
    // Rotate through some key Catholic Saints based on calendar day
    final saints = [
      'St. Augustine of Hippo',
      'St. Therese of Lisieux',
      'St. Francis of Assisi',
      'St. Thomas Aquinas',
      'St. Padre Pio',
      'St. Ignatius of Loyola',
      'St. Teresa of Avila'
    ];
    return saints[day % saints.length];
  }

  String _getSaintQuote() {
    final day = DateTime.now().day;
    final quotes = [
      '"Thou hast made us for Thyself, O Lord, and our hearts are restless until they rest in Thee."',
      '"Without love, deeds, even the most brilliant, count as nothing."',
      '"Start by doing what\'s necessary; then do what\'s possible; and suddenly you are doing the impossible."',
      '"To one who has faith, no explanation is necessary. To one without faith, no explanation is possible."',
      '"Pray, hope, and don\'t worry. Worry is useless. God is merciful and will hear your prayer."',
      '"He who is not key to our hearts, does not know the way of our soul."',
      '"Let nothing disturb thee, nothing affright thee; all things are passing; God never changeth."'
    ];
    return quotes[day % quotes.length];
  }

  String _getFormattedDate() {
    final date = DateTime.now();
    final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${weekdayNames[date.weekday - 1].toUpperCase()}, ${monthNames[date.month - 1].toUpperCase()} ${date.day}';
  }
}
