import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_pray/core/theme/app_theme.dart';
import '../domain/rosary_bead.dart';
import 'rosary_notifier.dart';

class RosaryScreen extends ConsumerWidget {
  const RosaryScreen({super.key});

  // Mystery Artworks from Wikimedia Commons (reverent classical paintings)
  static const Map<String, String> mysteryArtwork = {
    'Joyful': 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/ec/Fra_Angelico_-_The_Annunciation_-_wga00424.jpg/800px-Fra_Angelico_-_The_Annunciation_-_wga00424.jpg',
    'Sorrowful': 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Caravaggio_-_The_Crowning_with_Thorns_-_Vienna.jpg/800px-Caravaggio_-_The_Crowning_with_Thorns_-_Vienna.jpg',
    'Glorious': 'https://upload.wikimedia.org/wikipedia/commons/thumb/f/f6/Pietro_Perugino_038.jpg/800px-Pietro_Perugino_038.jpg',
    'Luminous': 'https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Transfiguration_Raphael.jpg/800px-Transfiguration_Raphael.jpg',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rosaryProvider);
    final notifier = ref.read(rosaryProvider.notifier);

    // Calculate current mystery info
    final mystery = state.activeMystery;
    final currentBead = state.currentBead;

    // Get current decade info
    final currentDecadeIndex = state.currentDecade;
    final decadeName = currentDecadeIndex > 0 && currentDecadeIndex <= mystery.decades.length
        ? mystery.decades[currentDecadeIndex - 1]
        : 'Introductory Prayers';

    final scriptureText = currentDecadeIndex > 0 && currentDecadeIndex <= mystery.scriptureVerses.length
        ? mystery.scriptureVerses[currentDecadeIndex - 1]
        : 'In the name of the Father, and of the Son, and of the Holy Spirit. Amen.';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LET\'S PRAY THE ROSARY',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
            onPressed: () => notifier.reset(),
            tooltip: 'Reset Rosary',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Liturgical Day / Mystery Info header
              Text(
                '${_getWeekdayString()} | ${state.activeMysteryKey.toUpperCase()} MYSTERIES',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.liturgicalGold,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
              ),
              const SizedBox(height: 12),

              // 2. Classical Mystery Artwork Card
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 4,
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        mysteryArtwork[state.activeMysteryKey] ?? '',
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppTheme.surfaceLightDark,
                            child: const Center(
                              child: CircularProgressIndicator(color: AppTheme.liturgicalGold),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.surfaceLightDark,
                            child: Icon(
                              Icons.menu_book,
                              size: 48,
                              color: AppTheme.textSecondary.withOpacity(0.5),
                            ),
                          );
                        },
                      ),
                      // Overlay Gradient
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                      // Text overlay
                      Positioned(
                        bottom: 12,
                        left: 16,
                        right: 16,
                        child: Text(
                          decadeName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. Dynamic Bead Visualizer in Center
              SizedBox(
                height: 240,
                width: double.infinity,
                child: Center(
                  child: _buildBeadsVisualizer(state, notifier),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Current Prayer Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.surfaceLightDark),
                ),
                child: Column(
                  children: [
                    Text(
                      currentBead.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.liturgicalGold,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      currentBead.text,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                            height: 1.45,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 5. Intention bar (if set)
              if (state.intention.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.liturgicalGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.liturgicalGold.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.favorite, color: AppTheme.liturgicalGold, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Praying for: ${state.intention}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.liturgicalGold,
                                fontStyle: FontStyle.italic,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // 6. Playback controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous button
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_previous, color: AppTheme.textSecondary),
                    onPressed: state.currentBeadIndex > 0 ? () => notifier.previousBead() : null,
                  ),
                  const SizedBox(width: 20),

                  // Play/Pause circular button
                  GestureDetector(
                    onTap: () => notifier.togglePlay(),
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.liturgicalGold,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.liturgicalGold.withOpacity(0.4),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        state.isPlaying ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),

                  // Next button
                  IconButton(
                    iconSize: 36,
                    icon: const Icon(Icons.skip_next, color: AppTheme.textSecondary),
                    onPressed: state.currentBeadIndex < state.beads.length - 1
                        ? () => notifier.nextBead()
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 7. Background soundscapes selector button
              OutlinedButton.icon(
                onPressed: () => _showSoundscapesSheet(context),
                icon: const Icon(Icons.music_note, color: AppTheme.liturgicalGold),
                label: const Text(
                  'ADJUST BACKGROUND SOUNDSCAPES',
                  style: TextStyle(color: AppTheme.liturgicalGold, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.surfaceLightDark),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Visualizing the Rosary as a circular path of beads
  Widget _buildBeadsVisualizer(RosaryState state, RosaryNotifier notifier) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double size = min(width, height);
        final double radius = (size / 2) - 20;

        final double centerX = width / 2;
        final double centerY = height / 2;

        // Render 10 beads in a circular loop representing the active decade (or initial introductory beads)
        final List<Widget> children = [];

        // Circle outline
        children.add(
          Positioned(
            left: centerX - radius,
            top: centerY - radius,
            child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surfaceLightDark.withOpacity(0.5), width: 1.5),
              ),
            ),
          ),
        );

        // 10 Beads in a circle
        const int numBeadsInCircle = 10;
        final int activeDecade = state.currentDecade;
        final int currentHMIndex = state.currentHailMaryIndex;

        for (int i = 0; i < numBeadsInCircle; i++) {
          final double angle = (2 * pi * i / numBeadsInCircle) - (pi / 2);
          final double x = centerX + radius * cos(angle) - 12;
          final double y = centerY + radius * sin(angle) - 12;

          // Determine if this bead is active, completed, or upcoming
          final bool isCurrentBead = state.currentBead.type == PrayerType.hailMary && (currentHMIndex == i + 1);
          final bool isCompleted = state.currentBead.type == PrayerType.hailMary && (currentHMIndex > i + 1) || (activeDecade > state.currentDecade);

          Color beadColor = AppTheme.surfaceLightDark;
          double scale = 1.0;
          List<BoxShadow>? shadows;

          if (isCurrentBead) {
            beadColor = AppTheme.liturgicalGold;
            scale = 1.35;
            shadows = [
              BoxShadow(
                color: AppTheme.liturgicalGold.withOpacity(0.6),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ];
          } else if (isCompleted) {
            beadColor = AppTheme.liturgicalGold.withOpacity(0.4);
          }

          children.add(
            Positioned(
              left: x,
              top: y,
              child: GestureDetector(
                onTap: () {
                  // Jump to corresponding Hail Mary index in current decade
                  int targetIndex = _getHailMaryBeadIndex(state, i + 1);
                  if (targetIndex != -1) {
                    notifier.jumpToBead(targetIndex);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24 * scale,
                  height: 24 * scale,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: beadColor,
                    boxShadow: shadows,
                    border: Border.all(
                      color: isCurrentBead ? Colors.white : AppTheme.surfaceLightDark,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Add Center Text showing decade details (e.g. "Decade 3")
        children.add(
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (state.currentBead.type == PrayerType.hailMary) ...[
                  Text(
                    'HAIL MARY',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentHMIndex / 10',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.liturgicalGold,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ] else ...[
                  Text(
                    state.currentBead.type == PrayerType.ourFather
                        ? 'OUR FATHER'
                        : state.currentBead.type == PrayerType.apostlesCreed
                            ? 'CREED'
                            : 'PRAYER',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.church, color: AppTheme.liturgicalGold, size: 28),
                ]
              ],
            ),
          ),
        );

        return Stack(children: children);
      },
    );
  }

  // Find exact index of the ith Hail Mary in the current decade
  int _getHailMaryBeadIndex(RosaryState state, int targetHM) {
    final int decade = state.currentDecade;
    if (decade == 0) {
      // Intro Hail Marys are indices 2, 3, 4 (1-based: 3, 4, 5)
      if (targetHM <= 3) return targetHM + 1;
      return -1;
    }
    // Decade 1 starts with Our Father at index 7. Hail Marys are 8 to 17 (0-based)
    // Decade 2 starts with Our Father at index 20. Hail Marys are 21 to 30.
    // Decade d: Our Father is 7 + (d-1)*13. Hail Marys are decadeStart + 1 to decadeStart + 10.
    int decadeStart = 7 + (decade - 1) * 13;
    return decadeStart + targetHM;
  }

  String _getWeekdayString() {
    final date = DateTime.now();
    final weekdayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final monthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${weekdayNames[date.weekday - 1]}, ${monthNames[date.month - 1]} ${date.day}';
  }

  void _showSoundscapesSheet(BuildContext context) {
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
                'Background Soundscapes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Select ambient music to play behind the prayer guides.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              _buildSoundscapeOption(context, 'Cathedral Gregorian Chants', true),
              _buildSoundscapeOption(context, 'Soft Cello & Synthesizer', false),
              _buildSoundscapeOption(context, 'Gentle Rain & Wind Chimes', false),
              _buildSoundscapeOption(context, 'Silent Meditation', false),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSoundscapeOption(BuildContext context, String title, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.liturgicalGold.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppTheme.liturgicalGold : AppTheme.surfaceLightDark,
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppTheme.liturgicalGold : AppTheme.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: AppTheme.liturgicalGold)
            : const Icon(Icons.circle_outlined, color: AppTheme.textMuted),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
