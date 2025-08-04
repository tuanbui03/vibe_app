import 'song.dart';
import 'playlist.dart';

enum PlayerState {
  stopped,
  playing,
  paused,
  loading,
  buffering,
  error,
}

enum RepeatMode {
  off,
  one,
  all,
}

enum ShuffleMode {
  off,
  on,
}

class AudioPlayerState {
  final Song? currentSong;
  final Playlist? currentPlaylist;
  final List<Song> queue;
  final int currentIndex;

  final PlayerState playerState;
  final Duration position;
  final Duration duration;
  final double volume;
  final double speed;

  final RepeatMode repeatMode;
  final ShuffleMode shuffleMode;
  final bool isBuffering;
  final String? errorMessage;

  const AudioPlayerState({
    this.currentSong,
    this.currentPlaylist,
    this.queue = const [],
    this.currentIndex = 0,
    this.playerState = PlayerState.stopped,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.volume = 1.0,
    this.speed = 1.0,
    this.repeatMode = RepeatMode.off,
    this.shuffleMode = ShuffleMode.off,
    this.isBuffering = false,
    this.errorMessage,
  });

  AudioPlayerState copyWith({
    Song? currentSong,
    Playlist? currentPlaylist,
    List<Song>? queue,
    int? currentIndex,
    PlayerState? playerState,
    Duration? position,
    Duration? duration,
    double? volume,
    double? speed,
    RepeatMode? repeatMode,
    ShuffleMode? shuffleMode,
    bool? isBuffering,
    String? errorMessage,
  }) {
    return AudioPlayerState(
      currentSong: currentSong ?? this.currentSong,
      currentPlaylist: currentPlaylist ?? this.currentPlaylist,
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      playerState: playerState ?? this.playerState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      repeatMode: repeatMode ?? this.repeatMode,
      shuffleMode: shuffleMode ?? this.shuffleMode,
      isBuffering: isBuffering ?? this.isBuffering,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get isPlaying => playerState == PlayerState.playing;
  bool get isPaused => playerState == PlayerState.paused;
  bool get isStopped => playerState == PlayerState.stopped;
  bool get isLoading => playerState == PlayerState.loading;
  bool get hasError => playerState == PlayerState.error;
  bool get hasQueue => queue.isNotEmpty;
  bool get hasPrevious => currentIndex > 0;
  bool get hasNext => currentIndex < queue.length - 1;

  double get progress {
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  Duration get remainingTime {
    return duration - position;
  }

  String get formattedPosition {
    return _formatDuration(position);
  }

  String get formattedDuration {
    return _formatDuration(duration);
  }

  String get formattedRemainingTime {
    return '-${_formatDuration(remainingTime)}';
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  Song? get nextSong {
    if (!hasNext) {
      if (repeatMode == RepeatMode.all && queue.isNotEmpty) {
        return queue.first;
      }
      return null;
    }
    return queue[currentIndex + 1];
  }

  Song? get previousSong {
    if (!hasPrevious) {
      if (repeatMode == RepeatMode.all && queue.isNotEmpty) {
        return queue.last;
      }
      return null;
    }
    return queue[currentIndex - 1];
  }

  bool get isShuffleEnabled => shuffleMode == ShuffleMode.on;

  bool get isRepeatEnabled => repeatMode != RepeatMode.off;
  bool get isRepeatOne => repeatMode == RepeatMode.one;
  bool get isRepeatAll => repeatMode == RepeatMode.all;

  double get volumePercentage => volume * 100;

  String get speedDisplayText {
    if (speed == 0.5) return '0.5x';
    if (speed == 0.75) return '0.75x';
    if (speed == 1.0) return '1x';
    if (speed == 1.25) return '1.25x';
    if (speed == 1.5) return '1.5x';
    if (speed == 2.0) return '2x';
    return '${speed.toStringAsFixed(1)}x';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioPlayerState &&
        other.currentSong == currentSong &&
        other.currentPlaylist == currentPlaylist &&
        other.currentIndex == currentIndex &&
        other.playerState == playerState &&
        other.position == position &&
        other.duration == duration &&
        other.volume == volume &&
        other.speed == speed &&
        other.repeatMode == repeatMode &&
        other.shuffleMode == shuffleMode &&
        other.isBuffering == isBuffering &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return Object.hash(
      currentSong,
      currentPlaylist,
      currentIndex,
      playerState,
      position,
      duration,
      volume,
      speed,
      repeatMode,
      shuffleMode,
      isBuffering,
      errorMessage,
    );
  }

  @override
  String toString() {
    return 'AudioPlayerState('
        'currentSong: ${currentSong?.title}, '
        'playerState: $playerState, '
        'position: $formattedPosition, '
        'duration: $formattedDuration, '
        'repeatMode: $repeatMode, '
        'shuffleMode: $shuffleMode'
        ')';
  }
}

enum AudioQuality {
  low,
  normal,
  high,
  lossless,
}

extension AudioQualityExtension on AudioQuality {
  String get displayName {
    switch (this) {
      case AudioQuality.low:
        return 'Low (96 kbps)';
      case AudioQuality.normal:
        return 'Normal (160 kbps)';
      case AudioQuality.high:
        return 'High (320 kbps)';
      case AudioQuality.lossless:
        return 'Lossless';
    }
  }

  int get bitrate {
    switch (this) {
      case AudioQuality.low:
        return 96;
      case AudioQuality.normal:
        return 160;
      case AudioQuality.high:
        return 320;
      case AudioQuality.lossless:
        return 1411;
    }
  }
}

// Equalizer preset
class EqualizerPreset {
  final String name;
  final List<double> bands; // -12dB to +12dB for each frequency band

  const EqualizerPreset({
    required this.name,
    required this.bands,
  });

  static const List<EqualizerPreset> presets = [
    EqualizerPreset(name: 'Flat', bands: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]),
    EqualizerPreset(name: 'Pop', bands: [-1, 2, 4, 2, 0, -1, -1, -1, 0, 1]),
    EqualizerPreset(name: 'Rock', bands: [3, 2, -2, -3, -1, 1, 3, 4, 4, 4]),
    EqualizerPreset(name: 'Jazz', bands: [2, 1, 1, 1, -1, -1, 0, 1, 2, 3]),
    EqualizerPreset(
        name: 'Classical', bands: [3, 2, -1, -1, -1, 0, 1, 2, 3, 4]),
    EqualizerPreset(
        name: 'Electronic', bands: [2, 1, 0, -1, -2, 1, 0, 1, 2, 3]),
    EqualizerPreset(name: 'Hip Hop', bands: [4, 3, 1, 1, -1, -1, 1, 2, 3, 4]),
    EqualizerPreset(name: 'Latin', bands: [3, 2, 0, 0, -1, -1, -1, 0, 2, 3]),
    EqualizerPreset(name: 'Vocal', bands: [-2, -1, -1, 1, 3, 3, 2, 1, 0, -1]),
  ];
}
