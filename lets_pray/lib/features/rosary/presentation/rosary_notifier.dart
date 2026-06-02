import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/rosary_bead.dart';

class RosaryState {
  final String activeMysteryKey;
  final int currentBeadIndex;
  final List<RosaryBead> beads;
  final bool isPlaying;
  final String intention;

  RosaryState({
    required this.activeMysteryKey,
    required this.currentBeadIndex,
    required this.beads,
    required this.isPlaying,
    required this.intention,
  });

  RosaryState copyWith({
    String? activeMysteryKey,
    int? currentBeadIndex,
    List<RosaryBead>? beads,
    bool? isPlaying,
    String? intention,
  }) {
    return RosaryState(
      activeMysteryKey: activeMysteryKey ?? this.activeMysteryKey,
      currentBeadIndex: currentBeadIndex ?? this.currentBeadIndex,
      beads: beads ?? this.beads,
      isPlaying: isPlaying ?? this.isPlaying,
      intention: intention ?? this.intention,
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
  RosaryNotifier()
      : super(RosaryState(
          activeMysteryKey: _defaultMystery(),
          currentBeadIndex: 0,
          beads: RosaryMystery.generateBeadsList(),
          isPlaying: false,
          intention: '',
        ));

  static String _defaultMystery() {
    final weekday = DateTime.now().weekday;
    if (weekday == DateTime.monday || weekday == DateTime.saturday) return 'Joyful';
    if (weekday == DateTime.tuesday || weekday == DateTime.friday) return 'Sorrowful';
    if (weekday == DateTime.wednesday || weekday == DateTime.sunday) return 'Glorious';
    return 'Luminous'; // Thursday
  }

  void selectMystery(String key) {
    if (RosaryMystery.allMysteries.containsKey(key)) {
      state = state.copyWith(activeMysteryKey: key, currentBeadIndex: 0);
      _triggerHaptic();
    }
  }

  void updateIntention(String value) {
    state = state.copyWith(intention: value);
  }

  void nextBead() {
    if (state.currentBeadIndex < state.beads.length - 1) {
      state = state.copyWith(currentBeadIndex: state.currentBeadIndex + 1);
      _triggerHaptic();
    }
  }

  void previousBead() {
    if (state.currentBeadIndex > 0) {
      state = state.copyWith(currentBeadIndex: state.currentBeadIndex - 1);
      _triggerHaptic();
    }
  }

  void jumpToBead(int index) {
    if (index >= 0 && index < state.beads.length) {
      state = state.copyWith(currentBeadIndex: index);
      _triggerHaptic();
    }
  }

  void togglePlay() {
    state = state.copyWith(isPlaying: !state.isPlaying);
    _triggerHaptic();
  }

  void reset() {
    state = state.copyWith(currentBeadIndex: 0, isPlaying: false);
    _triggerHaptic();
  }

  void _triggerHaptic() {
    HapticFeedback.lightImpact();
  }
}

final rosaryProvider = StateNotifierProvider<RosaryNotifier, RosaryState>((ref) {
  return RosaryNotifier();
});
