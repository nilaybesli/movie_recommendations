import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movie_recommend/movie_model.dart';
import 'package:movie_recommend/screens/LikedPage.dart';
import 'package:movie_recommend/screens/SearchPage.dart';
import 'package:movie_recommend/screens/constants.dart';

class HomePage extends StatefulWidget {
  final String username;

  const HomePage({Key? key, required this.username}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String baseUrl = 'http://192.168.1.7:5000/';
  final dio = Dio(BaseOptions(
    headers: {'Connection': 'keep-alive'},
    connectTimeout: const Duration(seconds: 60),
  ));
  late List<Movie> movieResult;
  late List<String> genres;
  late Map<String, List<Movie>> categorizedMovies;
  List<Movie> likedMovies = [];
  String selectedGenre = '';

  int currentPage = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchMovieImages();
    genres = [];
  }

  Future<void> fetchMovieImages() async {
    try {
      final response = await dio.get('$baseUrl/images/$currentPage');
      if (response.statusCode == 200) {
        final result = movieFromJson(response.data.toString());
        if (mounted) {
          setState(() {
            movieResult = result;
            genres = extractGenres(result);
            categorizedMovies = categorizeMovies(result);
          });
        }
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  List<String> extractGenres(List<Movie> movies) {
    final Set<String> genreSet = {};
    for (var movie in movies) {
      final genres = movie.genres.split(", ");
      genreSet.addAll(genres);
    }
    return genreSet.toList();
  }

  Map<String, List<Movie>> categorizeMovies(List<Movie> movies) {
    final Map<String, List<Movie>> categorizedMovies = {};
    for (var genre in genres) {
      categorizedMovies[genre] =
          movies.where((movie) => movie.genres.contains(genre)).toList();
    }
    return categorizedMovies;
  }

  List<Movie> getFilteredMovies() {
    if (selectedGenre.isEmpty) {
      return movieResult;
    } else {
      return categorizedMovies[selectedGenre] ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Constants.blackColor,
      extendBody: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: Constants.appColor,
          ),
        ),
        title: const Text(
          'moVApp',
          style: TextStyle(
            color: Constants.whiteColor,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(
                    username: widget.username,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          BackgroundWidget(),
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: genres.map((genre) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedGenre = genre;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: selectedGenre == genre
                              ? MaterialStateProperty.all<Color>(
                                  Colors.purpleAccent)
                              : MaterialStateProperty.all<Color>(Colors.purple),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: selectedGenre == genre
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16.0),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: getFilteredMovies().length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 0.4,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemBuilder: (context, index) {
                  final movie = getFilteredMovies()[index];
                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            image: DecorationImage(
                              image: NetworkImage(movie.images),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        movie.title,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        movie.genres,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.white70,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          likedMovies.contains(movie)
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: likedMovies.contains(movie)
                              ? Colors.red
                              : Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            if (likedMovies.contains(movie)) {
                              likedMovies.remove(movie);
                            } else {
                              likedMovies.add(movie);
                            }
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LikedPage(
                likedMovies: likedMovies,
                username: widget.username,
                movieId: '',
              ),
            ),
          );
        },
        child: const Icon(
          Icons.favorite,
        ),
      ),
    );
  }
}
