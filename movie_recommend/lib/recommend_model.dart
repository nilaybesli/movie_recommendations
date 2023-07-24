// To parse this JSON data, do
//     final recommend = recommendFromJson(jsonString);

import 'dart:convert';

List<Recommend> recommendFromJson(String str) =>
    List<Recommend>.from(json.decode(str).map((x) => Recommend.fromJson(x)));

String recommendToJson(List<Recommend> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Recommend {
  int movieId;
  String title;
  String genres;
  int userId;
  int rating;

  Recommend({
    required this.movieId,
    required this.title,
    required this.genres,
    required this.userId,
    required this.rating,
  });

  factory Recommend.fromJson(Map<String, dynamic> json) => Recommend(
        movieId: json["movieId"],
        title: json["title"],
        genres: json["genres"],
        userId: json["userId"],
        rating: json["rating"],
      );

  Map<String, dynamic> toJson() => {
        "movieId": movieId,
        "title": title,
        "genres": genres,
        "userId": userId,
        "rating": rating,
      };
}
