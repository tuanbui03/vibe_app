import 'package:cloud_firestore/cloud_firestore.dart';

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final int duration;
  final String audioUrl;
  final String imageUrl;
  final String genre;
  final int plays;
  final int likes;
  final DateTime createdAt;
  final List<String> tags;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.audioUrl,
    required this.imageUrl,
    required this.genre,
    this.plays = 0,
    this.likes = 0,
    required this.createdAt,
    this.tags = const [],
  });

  factory Song.fromFireStore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Song(
      id: doc.id,
      title: data['title'] ?? '',
      artist: data['artist'] ?? 'Unknow Artist',
      album: data['album'] ?? 'Unknow Album',
      duration: data['duration'] ?? 0,
      audioUrl: data['audioUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      genre: data['genre'] ?? 'Unknown',
      plays: data['plays'] ?? 0,
      likes: data['likes'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  factory Song.fromMap(Map<String, dynamic> map, String id) {
    return Song(
      id: id,
      title: map['title'] ?? '',
      artist: map['artist'] ?? '',
      album: map['album'] ?? '',
      duration: map['duration'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      genre: map['genre'] ?? 'Unknown',
      plays: map['pllays'] ?? 0,
      likes: map['likes'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'genre': genre,
      'plays': plays,
      'likes': likes,
      'createdAt': Timestamp.fromDate(createdAt),
      'tags': tags,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'duration': duration,
      'audioUrl': audioUrl,
      'imageUrl': imageUrl,
      'genre': genre,
      'plays': plays,
      'likes': likes,
      'createdAt': createdAt.toIso8601String(),
      'tags': tags,
    };
  }

  Song CopyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    int? duration,
    String? audioUrl,
    String? imageUrl,
    String? genre,
    int? plays,
    int? likes,
    DateTime? createdAt,
    List<String>? tags,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      genre: genre ?? this.genre,
      plays: plays ?? this.plays,
      likes: likes ?? this.likes,
      createdAt: createdAt ?? this.createdAt,
      tags: tags ?? this.tags,
    );
  }

  String get formattedDuration {
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedPlays {
    if (plays >= 1000000) {
      return '${(plays / 1000000).toStringAsFixed(1)}M';
    } else if (plays >= 1000) {
      return '${(plays / 1000).toStringAsFixed(1)}K';
    }
    return plays.toString();
  }

  bool get hasValidAudio => audioUrl.isNotEmpty;

  bool get hasCoverImage => imageUrl.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Song && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Song(id: $id, title: $title, artist: $artist, duration: $formattedDuration)';
  }
}
