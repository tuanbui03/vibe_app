import 'package:cloud_firestore/cloud_firestore.dart';
import 'song.dart';

class Playlist {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> songIds;
  final String userId;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> tags;
  final String category;

  List<Song>? songs;

  Playlist({
    required this.id,
    required this.name,
    this.description = '',
    this.imageUrl = '',
    this.songIds = const [],
    required this.userId,
    this.isPublic = false,
    required this.createdAt,
    DateTime? updatedAt,
    this.tags = const [],
    this.category = 'user',
    this.songs,
  }) : updatedAt = updatedAt ?? createdAt;

  factory Playlist.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Playlist(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      songIds: List<String>.from(data['songIds'] ?? []),
      userId: data['userId'] ?? '',
      isPublic: data['isPublic'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
      category: data['category'] ?? 'user',
    );
  }

  factory Playlist.fromMap(Map<String, dynamic> map, String id) {
    return Playlist(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      songIds: List<String>.from(map['songIds'] ?? []),
      userId: map['userId'] ?? '',
      isPublic: map['isPublic'] ?? false,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
      category: map['category'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'songIds': songIds,
      'userId': userId,
      'isPublic': isPublic,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'tags': tags,
      'category': category,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'songIds': songIds,
      'userId': userId,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'category': category,
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    List<String>? songIds,
    String? userId,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? category,
    List<Song>? songs,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      songIds: songIds ?? this.songIds,
      userId: userId ?? this.userId,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
      category: category ?? this.category,
      songs: songs ?? this.songs,
    );
  }

  Playlist addSong(String songId) {
    if (songIds.contains(songId)) return this;

    List<String> newSongIds = List.from(songIds);
    newSongIds.add(songId);

    return copyWith(
      songIds: newSongIds,
      updatedAt: DateTime.now(),
    );
  }

  Playlist removeSong(String songId) {
    List<String> newSongIds = List.from(songIds);
    newSongIds.remove(songId);

    return copyWith(
      songIds: newSongIds,
      updatedAt: DateTime.now(),
    );
  }

  Playlist reorderSongs(int oldIndex, int newIndex) {
    List<String> newSongIds = List.from(songIds);

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final String songId = newSongIds.removeAt(oldIndex);
    newSongIds.insert(newIndex, songId);

    return copyWith(
      songIds: newSongIds,
      updatedAt: DateTime.now(),
    );
  }

  int get totalDuration {
    if (songs == null) return 0;
    return songs!.fold(0, (sum, song) => sum + song.duration);
  }

  String get formattedTotalDuration {
    int totalSeconds = totalDuration;
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  int get songCount => songIds.length;

  bool get isEmpty => songIds.isEmpty;

  bool get hasCoverImage => imageUrl.isNotEmpty;

  String get displayImageUrl {
    if (hasCoverImage) return imageUrl;
    if (songs != null && songs!.isNotEmpty && songs!.first.hasCoverImage) {
      return songs!.first.imageUrl;
    }
    return '';
  }

  bool isOwnedBy(String currentUserId) => userId == currentUserId;

  bool containsSong(String songId) => songIds.contains(songId);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Playlist(id: $id, name: $name, songCount: $songCount)';
  }
}

class PlaylistCategory {
  static const String user = 'user';
  static const String featured = 'featured';
  static const String trending = 'trending';
  static const String newRelease = 'new_release';
  static const String genre = 'genre';
  static const String mood = 'mood';
  static const String activity = 'activity';

  static const List<String> all = [
    user,
    featured,
    trending,
    newRelease,
    genre,
    mood,
    activity,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case user:
        return 'My Playlist';
      case featured:
        return 'Featured';
      case trending:
        return 'Trending';
      case newRelease:
        return 'New Release';
      case genre:
        return 'Genre';
      case mood:
        return 'Mood';
      case activity:
        return 'Activity';
      default:
        return 'Unknown';
    }
  }
}
