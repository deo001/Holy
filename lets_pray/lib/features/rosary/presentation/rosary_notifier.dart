import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../domain/rosary_bead.dart';

class RosaryState {
  final String activeMysteryKey;
  final int currentBeadIndex;
  final List<RosaryBead> beads;
  final bool isPlaying;
  final String intention;
  final Duration position;
  final Duration duration;

  RosaryState({
    required this.activeMysteryKey,
    required this.currentBeadIndex,
    required this.beads,
    required this.isPlaying,
    required this.intention,
    required this.position,
    required this.duration,
  });

  RosaryState copyWith({
    String? activeMysteryKey,
    int? currentBeadIndex,
    List<RosaryBead>? beads,
    bool? isPlaying,
    String? intention,
    Duration? position,
    Duration? duration,
  }) {
    return RosaryState(
      activeMysteryKey: activeMysteryKey ?? this.activeMysteryKey,
      currentBeadIndex: currentBeadIndex ?? this.currentBeadIndex,
      beads: beads ?? this.beads,
      isPlaying: isPlaying ?? this.isPlaying,
      intention: intention ?? this.intention,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  RosaryBead get currentBead => beads[currentBeadIndex];
  RosaryMystery get activeMystery => RosaryMystery.allMysteries[activeMysteryKey]!;

  // Calculations to see which decade we are in based on bead index
  int get currentDecade {
    final idx = currentBead.index;
    if (idx < 8) return 0; // Intro prayers
    if (idx >= 8 && idx <= 20) return 1;
    if (idx >= 21 && idx <= 33) return 2;
    if (idx >= 34 && idx <= 46) return 3;
    if (idx >= 47 && idx <= 59) return 4;
    return 5;
  }

  // Calculate Hail Mary count inside the current decade
  int get currentHailMaryIndex {
    final idx = currentBead.index;
    if (currentBead.type != PrayerType.hailMary) return 0;
    
    // Intro Hail Marys (beads 3, 4, 5)
    if (idx >= 3 && idx <= 5) return idx - 2;

    // Decade Hail Marys (10 per decade)
    int decadeStart = 8 + (currentDecade - 1) * 13;
    int hmIndex = idx - decadeStart;
    return hmIndex;
  }
}

class RosaryNotifier extends StateNotifier<RosaryState> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isUrlLoaded = false;

  static const Map<String, String> _mysteryUrls = {
    'Joyful': 'https://churchoftheholyfamily.org/wp-content/uploads/2024/11/The-Joyful-Mysteries-Womens.mp3',
    'Sorrowful': 'https://churchoftheholyfamily.org/wp-content/uploads/2024/11/The-Sorrowful-Mysteries-Womens.mp3',
    'Glorious': 'https://churchoftheholyfamily.org/wp-content/uploads/2024/11/The-Glorious-Mysteries-Womens.mp3',
    'Luminous': 'https://churchoftheholyfamily.org/wp-content/uploads/2024/11/The-Luminous-Mysteries-Womens.mp3',
  };

  RosaryNotifier()
      : super(RosaryState(
          activeMysteryKey: _defaultMystery(),
          currentBeadIndex: 0,
          beads: RosaryMystery.generateBeadsList(),
          isPlaying: false,
          intention: '',
          position: Duration.zero,
          duration: Duration.zero,
        )) {
    // Listen to player position changes
    _audioPlayer.positionStream.listen((pos) {
      if (mounted) {
        final dur = state.duration;
        if (dur > Duration.zero) {
          double progress = pos.inMilliseconds / dur.inMilliseconds;
          int newIndex = getBeadIndexFromProgress(progress);
          if (newIndex != state.currentBeadIndex) {
            state = state.copyWith(currentBeadIndex: newIndex, position: pos);
          } else {
            state = state.copyWith(position: pos);
          }
        } else {
          state = state.copyWith(position: pos);
        }
      }
    });

    // Listen to player duration changes
    _audioPlayer.durationStream.listen((dur) {
      if (mounted && dur != null) {
        state = state.copyWith(duration: dur);
      }
    });

    // Listen to playback state changes
    _audioPlayer.playerStateStream.listen((playerState) {
      if (mounted) {
        state = state.copyWith(isPlaying: playerState.playing);
      }
    });
  }

  // Get starting progress percentage for a bead index (0 to 73)
  static double getBeadStartProgress(int index) {
    if (index < 0) return 0.0;
    if (index >= 74) return 1.0;

    // Intro (0 to 6)
    if (index == 0) return 0.0; // Creed
    if (index == 1) return 0.035; // Our Father
    if (index == 2) return 0.05; // HM 1
    if (index == 3) return 0.06; // HM 2
    if (index == 4) return 0.07; // HM 3
    if (index == 5) return 0.08; // Glory Be
    if (index == 6) return 0.09; // Fatima
 

    // Decades (7 to 71)
    // 5 decades of 13 beads each.
    // Decade 1 starts at 7, Decade 5 ends at 71.
    if (index >= 7 && index <= 71) {
      int decadeIndex = (index - 7) ~/ 13; // 0 to 4
      int beadInDecade = (index - 7) % 13; // 0 to 12
      
      double decadeStart = 0.10 + decadeIndex * 0.168;
      
      // Distribute 13 beads in this decade range
      return decadeStart + (beadInDecade / 13) * 0.168;
    }

    // Outro (72 to 73)
    if (index == 72) return 0.94; // Hail Holy Queen
    if (index == 73) return 0.975; // Concluding Prayer
    return 1.0;
  }

  // Map progress (0.0 to 1.0) to corresponding bead index
  static int getBeadIndexFromProgress(double progress) {
    if (progress <= 0.0) return 0;
    if (progress >= 1.0) return 73;

    for (int i = 0; i < 73; i++) {
      double start = getBeadStartProgress(i);
      double end = getBeadStartProgress(i + 1);
      if (progress >= start && progress < end) {
        return i;
      }
    }
    return 73;
  }

  static String _defaultMystery() {
    final weekday = DateTime.now().weekday;
    if (weekday == DateTime.monday || weekday == DateTime.saturday) return 'Joyful';
    if (weekday == DateTime.tuesday || weekday == DateTime.friday) return 'Sorrowful';
    if (weekday == DateTime.wednesday || weekday == DateTime.sunday) return 'Glorious';
    return 'Luminous'; // Thursday
  }

  Future<void> selectMystery(String key) async {
    if (RosaryMystery.allMysteries.containsKey(key)) {
      final wasPlaying = state.isPlaying;
      await _audioPlayer.stop();
      _isUrlLoaded = false;
      if (mounted) {
        state = state.copyWith(
          activeMysteryKey: key,
          currentBeadIndex: 0,
          position: Duration.zero,
          duration: Duration.zero,
        );
      }
      _triggerHaptic();
      if (wasPlaying) {
        await togglePlay();
      }
    }
  }

  void updateIntention(String value) {
    state = state.copyWith(intention: value);
  }

  void nextBead() {
    if (state.currentBeadIndex < state.beads.length - 1) {
      final nextIndex = state.currentBeadIndex + 1;
      state = state.copyWith(currentBeadIndex: nextIndex);
      _triggerHaptic();
      _syncAudioToBead(nextIndex);
    }
  }

  void previousBead() {
    if (state.currentBeadIndex > 0) {
      final prevIndex = state.currentBeadIndex - 1;
      state = state.copyWith(currentBeadIndex: prevIndex);
      _triggerHaptic();
      _syncAudioToBead(prevIndex);
    }
  }

  void jumpToBead(int index) {
    if (index >= 0 && index < state.beads.length) {
      state = state.copyWith(currentBeadIndex: index);
      _triggerHaptic();
      _syncAudioToBead(index);
    }
  }

  void _syncAudioToBead(int index) {
    final dur = state.duration;
    if (dur > Duration.zero) {
      double targetProgress = getBeadStartProgress(index);
      seek(Duration(milliseconds: (dur.inMilliseconds * targetProgress).toInt()));
    }
  }

  Future<void> togglePlay([String locale = 'en']) async {
    _triggerHaptic();
    if (state.isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (!_isUrlLoaded) {
        try {
          final url = _mysteryUrls[state.activeMysteryKey]!;
          await _audioPlayer.setUrl(url);
          _isUrlLoaded = true;
        } catch (e) {
          return;
        }
      }
      await _audioPlayer.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> reset() async {
    await _audioPlayer.stop();
    await _audioPlayer.seek(Duration.zero);
    if (mounted) {
      state = state.copyWith(
        currentBeadIndex: 0,
        isPlaying: false,
        position: Duration.zero,
      );
    }
    _triggerHaptic();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }
}

final rosaryProvider = StateNotifierProvider<RosaryNotifier, RosaryState>((ref) {
  return RosaryNotifier();
});
