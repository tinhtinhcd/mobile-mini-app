import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final pomodoroControllerProvider =
    NotifierProvider<PomodoroController, PomodoroState>(PomodoroController.new);

enum PomodoroMode {
  focus('Focus'),
  shortBreak('Short break'),
  longBreak('Long break');

  const PomodoroMode(this.label);

  final String label;
}

class PomodoroState {
  const PomodoroState({
    required this.mode,
    required this.remaining,
    required this.sessionLength,
    required this.isRunning,
    required this.completedFocusSessions,
    required this.focusMinutesToday,
  });

  factory PomodoroState.initial() {
    const focusLength = Duration(minutes: 25);

    return const PomodoroState(
      mode: PomodoroMode.focus,
      remaining: focusLength,
      sessionLength: focusLength,
      isRunning: false,
      completedFocusSessions: 0,
      focusMinutesToday: 0,
    );
  }

  final PomodoroMode mode;
  final Duration remaining;
  final Duration sessionLength;
  final bool isRunning;
  final int completedFocusSessions;
  final int focusMinutesToday;

  double get progress {
    if (sessionLength.inSeconds == 0) {
      return 0;
    }

    final complete = sessionLength.inSeconds - remaining.inSeconds;
    return complete / sessionLength.inSeconds;
  }

  PomodoroState copyWith({
    PomodoroMode? mode,
    Duration? remaining,
    Duration? sessionLength,
    bool? isRunning,
    int? completedFocusSessions,
    int? focusMinutesToday,
  }) {
    return PomodoroState(
      mode: mode ?? this.mode,
      remaining: remaining ?? this.remaining,
      sessionLength: sessionLength ?? this.sessionLength,
      isRunning: isRunning ?? this.isRunning,
      completedFocusSessions:
          completedFocusSessions ?? this.completedFocusSessions,
      focusMinutesToday: focusMinutesToday ?? this.focusMinutesToday,
    );
  }
}

class PomodoroController extends Notifier<PomodoroState> {
  Timer? _timer;

  @override
  PomodoroState build() {
    ref.onDispose(() => _timer?.cancel());
    return PomodoroState.initial();
  }

  void toggleTimer() {
    if (state.isRunning) {
      _pause();
      return;
    }

    _start();
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(
      isRunning: false,
      remaining: state.sessionLength,
    );
  }

  void skipToNextMode() {
    _timer?.cancel();
    final nextMode = _nextMode(state.mode, state.completedFocusSessions);
    _moveToMode(nextMode);
  }

  void selectMode(PomodoroMode mode) {
    _timer?.cancel();
    _moveToMode(mode);
  }

  void _start() {
    _timer?.cancel();
    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  void _tick() {
    if (state.remaining.inSeconds <= 1) {
      _completeSession();
      return;
    }

    state = state.copyWith(
      remaining: Duration(seconds: state.remaining.inSeconds - 1),
    );
  }

  void _completeSession() {
    _timer?.cancel();

    final completedFocusSessions = state.mode == PomodoroMode.focus
        ? state.completedFocusSessions + 1
        : state.completedFocusSessions;
    final focusMinutesToday = state.mode == PomodoroMode.focus
        ? state.focusMinutesToday + state.sessionLength.inMinutes
        : state.focusMinutesToday;
    final nextMode = _nextMode(state.mode, completedFocusSessions);

    state = state.copyWith(
      isRunning: false,
      completedFocusSessions: completedFocusSessions,
      focusMinutesToday: focusMinutesToday,
    );

    _moveToMode(nextMode);
  }

  void _moveToMode(PomodoroMode mode) {
    final duration = _durationFor(mode);
    state = state.copyWith(
      mode: mode,
      remaining: duration,
      sessionLength: duration,
      isRunning: false,
    );
  }

  PomodoroMode _nextMode(PomodoroMode currentMode, int completedFocusSessions) {
    switch (currentMode) {
      case PomodoroMode.focus:
        return completedFocusSessions % 4 == 0
            ? PomodoroMode.longBreak
            : PomodoroMode.shortBreak;
      case PomodoroMode.shortBreak:
      case PomodoroMode.longBreak:
        return PomodoroMode.focus;
    }
  }

  Duration _durationFor(PomodoroMode mode) {
    switch (mode) {
      case PomodoroMode.focus:
        return const Duration(minutes: 25);
      case PomodoroMode.shortBreak:
        return const Duration(minutes: 5);
      case PomodoroMode.longBreak:
        return const Duration(minutes: 15);
    }
  }
}

