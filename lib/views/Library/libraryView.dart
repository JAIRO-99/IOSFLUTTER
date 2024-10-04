import 'package:flutter/material.dart';

class LibraryView extends StatelessWidget {
  final List<String> genres = [
    'Pop',
    'Rock',
    'Jazz',
    'Hip-Hop',
    'Clásica',
    'Electrónica',
    'Reggae'
  ];

  final List<Map<String, String>> artists = [
    {'name': 'Taylor Swift', 'image': 'assets/taylor.png'},
    {'name': 'Drake', 'image': 'assets/drake.png'},
    {'name': 'Adele', 'image': 'assets/adele.png'},
    {'name': 'Ed Sheeran', 'image': 'assets/edsheeran.png'},
  ];

  final List<Map<String, String>> songs = [
    {'title': 'Blinding Lights', 'artist': 'The Weeknd'},
    {'title': 'Watermelon Sugar', 'artist': 'Harry Styles'},
    {'title': 'Levitating', 'artist': 'Dua Lipa'},
    {'title': 'Peaches', 'artist': 'Justin Bieber'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Buscar
              Padding(
                padding: const EdgeInsets.only(
                    top: 40.0), // Ajuste de margen superior
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar',
                    hintStyle: TextStyle(color: Colors.white54),
                    prefixIcon: Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),

              // Géneros
              Text(
                'Géneros',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: genres.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            genres[index],
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Artistas
              SizedBox(height: 32),
              Text(
                'Artistas',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: artists.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                AssetImage(artists[index]['image']!),
                            radius: 30,
                          ),
                          SizedBox(height: 8),
                          Text(
                            artists[index]['name']!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Canciones
              SizedBox(height: 32),
              Text(
                'Canciones',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.music_note, color: Colors.white),
                      ),
                      title: Text(
                        songs[index]['title']!,
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        songs[index]['artist']!,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
