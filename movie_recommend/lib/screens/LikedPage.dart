import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movie_recommend/recommend_model.dart';
import 'package:movie_recommend/screens/HomePage.dart';
import 'package:movie_recommend/screens/constants.dart';

import '../movie_model.dart';

class LikedPage extends StatefulWidget {
  final List<Movie> likedMovies;
  final String username;
  final String movieId; // Yeni eklenen movieId değişkeni

  const LikedPage({
    Key? key,
    required this.likedMovies,
    required this.username,
    required this.movieId, // movieId constructor'a eklendi
  }) : super(key: key);

  @override
  State<LikedPage> createState() => _LikedPageState();
}

class _LikedPageState extends State<LikedPage> {
  final String baseUrl = 'http://192.168.1.7:5000';
  final dio = Dio(BaseOptions(headers: {'Connection': 'keep-alive'}));
  List<int> movieIds = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> suggestMovie(String movieId) async {
    final String url = '$baseUrl/recommend/$movieId';

    try {
      final response = await dio.get(url);
      if (response.statusCode == 200) {
        var result = recommendFromJson(response.data);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Suggested Movies'),
              content: SizedBox(
                height: 500,
                width: 500,
                child: ListView.builder(
                  itemCount: result.length,
                  itemBuilder: (context, index) {
                    final movie = result[index];
                    return ListTile(
                      title: Text(movie.title.toString()),
                    );
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        throw Exception('Failed to suggest movies.');
      }
    } catch (error) {
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      body: SizedBox(
        width: screenWidth,
        height: screenHeight,
        child: Stack(
          children: [
            BackgroundWidget(),
            Positioned(
              top: screenHeight * 0.15,
              left: screenWidth * 0.5 - 75,
              child: Container(
                height: 150,
                width: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  image: DecorationImage(
                    image: AssetImage('img/profile_image.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.40,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Liked Movies',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.5,
              left: 0,
              right: 0,
              bottom: 0,
              child: ListView.builder(
                itemCount: widget.likedMovies.length,
                itemBuilder: (context, index) {
                  final film = widget.likedMovies[index];
                  return ListTile(
                    title: Text(
                      film.title,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    subtitle: Text(
                      film.movieId,
                      style: const TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(film.images),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.add_box,
                        color: Colors.purple,
                      ),
                      onPressed: () {
                        suggestMovie(film.movieId);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      username: widget.username,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
