import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String photoUrl;
  final List<String> favoriteGenres;
  final List<String> favoriteSongs;
  final List<String> favoriteArtists;
  final List<String> recentlyPlayed;
  final Map<String, int> genrePreferences;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final bool isPremium;
  final String subscription;

  AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl = '',
    this.favoriteGenres = const [],
    this.favoriteSongs = const [],
    this.favoriteArtists = const [],
    this.recentlyPlayed = const [],
    this.genrePreferences = const {},
    required this.createdAt,
    DateTime? lastLoginAt,
    this.isPremium = false,
    this.subscription = 'free',
  }) : lastLoginAt = lastLoginAt ?? createdAt;

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      favoriteGenres: List<String>.from(data['favoriteGenres'] ?? []),
      favoriteSongs: List<String>.from(data['favoriteSongs'] ?? []),
      favoriteArtists: List<String>.from(data['favoriteArtists'] ?? []),
      recentlyPlayed: List<String>.from(data['recentlyPlayed'] ?? []),
      genrePreferences: Map<String, int>.from(data['genrePreferences'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLoginAt:
          (data['lastLoginAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPremium: data['isPremium'] ?? false,
      subscription: data['subscription'] ?? 'free',
    );
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      favoriteGenres: List<String>.from(map['favoriteGenres'] ?? []),
      favoriteSongs: List<String>.from(map['favoriteSongs'] ?? []),
      favoriteArtists: List<String>.from(map['favoriteArtists'] ?? []),
      recentlyPlayed: List<String>.from(map['recentlyPlayed'] ?? []),
      genrePreferences: Map<String, int>.from(map['genrePreferences'] ?? {}),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastLoginAt: map['lastLoginAt'] is Timestamp
          ? (map['lastLoginAt'] as Timestamp).toDate()
          : DateTime.now(),
      isPremium: map['isPremium'] ?? false,
      subscription: map['subscription'] ?? 'free',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'favoriteGenres': favoriteGenres,
      'favoriteSongs': favoriteSongs,
      'favoriteArtists': favoriteArtists,
      'recentlyPlayed': recentlyPlayed,
      'genrePreferences': genrePreferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'isPremium': isPremium,
      'subscription': subscription,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'favoriteGenres': favoriteGenres,
      'favoriteSongs': favoriteSongs,
      'favoriteArtists': favoriteArtists,
      'recentlyPlayed': recentlyPlayed,
      'genrePreferences': genrePreferences,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'isPremium': isPremium,
      'subscription': subscription,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? favoriteGenres,
    List<String>? favoriteSongs,
    List<String>? favoriteArtists,
    List<String>? recentlyPlayed,
    Map<String, int>? genrePreferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isPremium,
    String? subscription,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      favoriteSongs: favoriteSongs ?? this.favoriteSongs,
      favoriteArtists: favoriteArtists ?? this.favoriteArtists,
      recentlyPlayed: recentlyPlayed ?? this.recentlyPlayed,
      genrePreferences: genrePreferences ?? this.genrePreferences,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isPremium: isPremium ?? this.isPremium,
      subscription: subscription ?? this.subscription,
    );
  }

  AppUser addFavoriteSong(String songId) {
    if (favoriteSongs.contains(songId)) return this;

    List<String> newFavorites = List.from(favoriteSongs);
    newFavorites.add(songId);

    return copyWith(favoriteSongs: newFavorites);
  }

  AppUser removeFavoriteSong(String songId) {
    List<String> newFavorites = List.from(favoriteSongs);
    newFavorites.remove(songId);

    return copyWith(favoriteSongs: newFavorites);
  }

  AppUser addFavoriteArtist(String artist) {
    if (favoriteArtists.contains(artist)) return this;

    List<String> newFavorites = List.from(favoriteArtists);
    newFavorites.add(artist);

    return copyWith(favoriteArtists: newFavorites);
  }

  AppUser removeFavoriteArtist(String artist) {
    List<String> newFavorites = List.from(favoriteArtists);
    newFavorites.remove(artist);

    return copyWith(favoriteArtists: newFavorites);
  }

  AppUser addFavoriteGenre(String genre) {
    if (favoriteGenres.contains(genre)) return this;

    List<String> newGenres = List.from(favoriteGenres);
    newGenres.add(genre);

    return copyWith(favoriteGenres: newGenres);
  }

  AppUser removeFavoriteGenre(String genre) {
    List<String> newGenres = List.from(favoriteGenres);
    newGenres.remove(genre);

    return copyWith(favoriteGenres: newGenres);
  }

  AppUser addToRecentlyPlayed(String songId) {
    List<String> newRecent = List.from(recentlyPlayed);

    newRecent.remove(songId);

    newRecent.insert(0, songId);

    if (newRecent.length > 50) {
      newRecent = newRecent.take(50).toList();
    }

    return copyWith(recentlyPlayed: newRecent);
  }

  AppUser updateGenrePreference(String genre, int increment) {
    Map<String, int> newPreferences = Map.from(genrePreferences);
    newPreferences[genre] = (newPreferences[genre] ?? 0) + increment;

    return copyWith(genrePreferences: newPreferences);
  }

  AppUser updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  bool get hasProfilePhoto => photoUrl.isNotEmpty;

  String get displayNameOrEmail => displayName.isEmpty ? email : displayName;

  String get initials {
    if (displayName.isEmpty) {
      return email.isNotEmpty ? email[0].toUpperCase() : 'U';
    }

    List<String> words = displayName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else {
      return displayName[0].toUpperCase();
    }
  }

  String? get topGenre {
    if (genrePreferences.isEmpty) return null;

    String topGenre = genrePreferences.keys.first;
    int maxCount = genrePreferences.values.first;

    for (var entry in genrePreferences.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        topGenre = entry.key;
      }
    }

    return topGenre;
  }

  bool isFavoriteSong(String songId) => favoriteSongs.contains(songId);

  bool isFavoriteArtist(String artist) => favoriteArtists.contains(artist);

  bool isFavoriteGenre(String genre) => favoriteGenres.contains(genre);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppUser(id: $id, displayName: $displayName, email: $email)';
  }
}

// Subscription types
class SubscriptionType {
  static const String free = 'free';
  static const String premium = 'premium';
  static const String family = 'family';

  static const List<String> all = [free, premium, family];

  static String getDisplayName(String type) {
    switch (type) {
      case free:
        return 'Free';
      case premium:
        return 'Premium';
      case family:
        return 'Family';
      default:
        return 'Unknown';
    }
  }

  static List<String> getFeatures(String type) {
    switch (type) {
      case free:
        return [
          'Limited skips',
          'Ads between songs',
          'Shuffle play only',
          'Basic audio quality',
        ];
      case premium:
        return [
          'Unlimited skips',
          'No ads',
          'Play any song',
          'High audio quality',
          'Offline downloads',
        ];
      case family:
        return [
          'All Premium features',
          'Up to 6 accounts',
          'Individual profiles',
          'Kid-safe mode',
        ];
      default:
        return [];
    }
  }
}
