import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:movie_recommend/movie_model.dart';
import 'package:movie_recommend/screens/constants.dart';

class SearchPage extends StatefulWidget {
  final String username;
  const SearchPage({Key? key, required this.username}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final String baseUrl = 'http://192.168.1.7:5000/';
  final dio = Dio(BaseOptions(
    headers: {'Connection': 'keep-alive'},
    connectTimeout: const Duration(seconds: 60),
  ));
  List<Movie> movieList = [];
  List<Movie> filteredMovieList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    try {
      final response = await dio.get('$baseUrl/images/1');
      if (response.statusCode == 200) {
        var result = movieFromJson(response.data.toString());
        setState(() {
          movieList = result;
          filteredMovieList = result;
        });
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void filterMovies(String query) {
    if (query.isNotEmpty) {
      setState(() {
        filteredMovieList = movieList
            .where((movie) =>
                movie.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } else {
      setState(() {
        filteredMovieList = movieList;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.blackColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: Constants.appColor,
          ),
        ),
        title: const Text(
          'Search Movies',
          style: TextStyle(
            color: Constants.whiteColor,
            fontSize: 20,
          ),
        ),
      ),
      body: Stack(
        children: [
          BackgroundWidget(),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  onChanged: filterMovies,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: const InputDecoration(
                    labelText: 'Search',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredMovieList.length,
                  itemBuilder: (context, index) {
                    final movie = filteredMovieList[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(movie.images),
                      ),
                      title: Text(
                        movie.title,
                        style: const TextStyle(
                          color: Constants.whiteColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        movie.genres,
                        style: const TextStyle(
                          color: Constants.whiteColor,
                        ),
                      ),
                      onTap: () {
                        // Handle movie selection
                        print('Selected movie: ${movie.title}');
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
