import 'song.dart';

enum DownloadStatus {
  none,
  queued,
  downloading,
  completed,
  failed,
  paused,
}

class Download {
  final String id;
  final Song song;
  final DownloadStatus status;
  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? localPath;
  final String? errorMessage;

  const Download({
    required this.id,
    required this.song,
    this.status = DownloadStatus.none,
    this.progress = 0.0,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.startedAt,
    this.completedAt,
    this.localPath,
    this.errorMessage,
  });

  Download copyWith({
    String? id,
    Song? song,
    DownloadStatus? status,
    double? progress,
    int? downloadedBytes,
    int? totalBytes,
    DateTime? startedAt,
    DateTime? completedAt,
    String? localPath,
    String? errorMessage,
  }) {
    return Download(
      id: id ?? this.id,
      song: song ?? this.song,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      localPath: localPath ?? this.localPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'songId': song.id,
      'status': status.index,
      'progress': progress,
      'downloadedBytes': downloadedBytes,
      'totalBytes': totalBytes,
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'localPath': localPath,
      'errorMessage': errorMessage,
    };
  }

  factory Download.fromMap(Map<String, dynamic> map, Song song) {
    return Download(
      id: map['id'] ?? '',
      song: song,
      status: DownloadStatus.values[map['status'] ?? 0],
      progress: map['progress']?.toDouble() ?? 0.0,
      downloadedBytes: map['downloadedBytes'] ?? 0,
      totalBytes: map['totalBytes'] ?? 0,
      startedAt:
          map['startedAt'] != null ? DateTime.parse(map['startedAt']) : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      localPath: map['localPath'],
      errorMessage: map['errorMessage'],
    );
  }

  bool get isDownloading => status == DownloadStatus.downloading;
  bool get isCompleted => status == DownloadStatus.completed;
  bool get isFailed => status == DownloadStatus.failed;
  bool get isPaused => status == DownloadStatus.paused;
  bool get isQueued => status == DownloadStatus.queued;
  bool get hasError => status == DownloadStatus.failed && errorMessage != null;

  double get progressPercentage => progress * 100;

  double get downloadedMB => downloadedBytes / (1024 * 1024);

  double get totalMB => totalBytes / (1024 * 1024);

  int get remainingBytes => totalBytes - downloadedBytes;

  double get remainingMB => remainingBytes / (1024 * 1024);

  double get downloadSpeedMBps {
    if (!isDownloading || startedAt == null) return 0.0;

    final elapsed = DateTime.now().difference(startedAt!);
    if (elapsed.inSeconds == 0) return 0.0;

    return downloadedMB / elapsed.inSeconds;
  }

  Duration get estimatedTimeRemaining {
    final speed = downloadSpeedMBps;
    if (speed <= 0) return Duration.zero;

    final remainingSeconds = (remainingMB / speed).round();
    return Duration(seconds: remainingSeconds);
  }

  String get formattedSize {
    if (totalBytes == 0) return 'Unknown';
    return _formatBytes(totalBytes);
  }

  String get formattedDownloadedSize {
    return _formatBytes(downloadedBytes);
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024)
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String get statusDisplayText {
    switch (status) {
      case DownloadStatus.none:
        return 'Not Downloaded';
      case DownloadStatus.queued:
        return 'Queued';
      case DownloadStatus.downloading:
        return 'Downloading...';
      case DownloadStatus.completed:
        return 'Downloaded';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.paused:
        return 'Paused';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Download && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Download(id: $id, song: ${song.title}, status: $status, progress: ${progressPercentage.toStringAsFixed(1)}%)';
  }
}

enum DownloadQuality {
  low,
  normal,
  high,
}

extension DownloadQualityExtension on DownloadQuality {
  String get displayName {
    switch (this) {
      case DownloadQuality.low:
        return 'Low Quality (96 kbps)';
      case DownloadQuality.normal:
        return 'Normal Quality (160 kbps)';
      case DownloadQuality.high:
        return 'High Quality (320 kbps)';
    }
  }

  String get suffix {
    switch (this) {
      case DownloadQuality.low:
        return '_96';
      case DownloadQuality.normal:
        return '_160';
      case DownloadQuality.high:
        return '_320';
    }
  }

  double get estimatedSizePerMinute {
    switch (this) {
      case DownloadQuality.low:
        return 0.72;
      case DownloadQuality.normal:
        return 1.2;
      case DownloadQuality.high:
        return 2.4;
    }
  }
}

class CacheInfo {
  final String songId;
  final String localPath;
  final int fileSize;
  final DateTime cachedAt;
  final DateTime lastAccessedAt;
  final int accessCount;

  const CacheInfo({
    required this.songId,
    required this.localPath,
    required this.fileSize,
    required this.cachedAt,
    required this.lastAccessedAt,
    this.accessCount = 0,
  });

  CacheInfo copyWith({
    String? songId,
    String? localPath,
    int? fileSize,
    DateTime? cachedAt,
    DateTime? lastAccessedAt,
    int? accessCount,
  }) {
    return CacheInfo(
      songId: songId ?? this.songId,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      cachedAt: cachedAt ?? this.cachedAt,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      accessCount: accessCount ?? this.accessCount,
    );
  }

  CacheInfo accessed() {
    return copyWith(
      lastAccessedAt: DateTime.now(),
      accessCount: accessCount + 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'songId': songId,
      'localPath': localPath,
      'fileSize': fileSize,
      'cachedAt': cachedAt.toIso8601String(),
      'lastAccessedAt': lastAccessedAt.toIso8601String(),
      'accessCount': accessCount,
    };
  }

  factory CacheInfo.fromMap(Map<String, dynamic> map) {
    return CacheInfo(
      songId: map['songId'] ?? '',
      localPath: map['localPath'] ?? '',
      fileSize: map['fileSize'] ?? 0,
      cachedAt: DateTime.parse(map['cachedAt']),
      lastAccessedAt: DateTime.parse(map['lastAccessedAt']),
      accessCount: map['accessCount'] ?? 0,
    );
  }

  Duration get age => DateTime.now().difference(cachedAt);

  Duration get timeSinceLastAccess => DateTime.now().difference(lastAccessedAt);

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CacheInfo && other.songId == songId;
  }

  @override
  int get hashCode => songId.hashCode;

  @override
  String toString() {
    return 'CacheInfo(songId: $songId, size: $formattedSize, age: ${age.inDays} days)';
  }
}
