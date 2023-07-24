// To parse this JSON data, do
//     final movie = movieFromJson(jsonString);

import 'dart:convert';

List<Movie> movieFromJson(String str) =>
    List<Movie>.from(json.decode(str).map((x) => Movie.fromJson(x)));

String movieToJson(List<Movie> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Movie {
  String movieId;
  String title;
  String genres;
  String images;

  Movie({
    required this.movieId,
    required this.title,
    required this.genres,
    required this.images,
  });

  factory Movie.fromJson(Map<String, dynamic> json) => Movie(
        movieId: json["movieId"],
        title: json["title"],
        genres: json["genres"],
        images: json["images"],
      );

  Map<String, dynamic> toJson() => {
        "movieId": movieId,
        "title": title,
        "genres": genres,
        "images": images,
      };
}
