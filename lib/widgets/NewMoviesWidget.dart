import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movie_app/pages/MoviesPage.dart';

final db = FirebaseFirestore.instance;

class NewMoviesWidget extends StatelessWidget {
  const NewMoviesWidget({super.key});

  String _extractMovieName(String url) {
    // Extract the part of the URL after 'posters/' and before '.jpg'
    final startIndex = url.lastIndexOf('posters/') + 'posters/'.length;
    final endIndex = url.lastIndexOf('.jpg');
    final movieName = url.substring(startIndex, endIndex);

    // Optionally, replace hyphens with spaces or perform other formatting
    return movieName.replaceAll('-', ' ').toUpperCase();
  }

  Future<void> _launchInBrowser(String url_raw) async {
    final Uri url = Uri.parse(url_raw);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: db.collection("movie").doc("d_link").get(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error : ${snapshot.error}"),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text("Document does not exist"),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final imageUrls = data["image_url"] as List<dynamic>;
        final download_urls = data["download_url"];
        return Column(children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "New Movies",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Column(
            children: [
              Container(
                height: 600,
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 30,
                      childAspectRatio: 0.6

                      // Adjust to fit your design
                      ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        _launchInBrowser(download_urls[index]);
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: Color(0xFF292B37),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(255, 104, 88, 21)
                                    .withOpacity(0.5),
                                spreadRadius: 0.7,
                                blurRadius: 6,
                              )
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.network(
                                imageUrls[index],
                                height: 170,
                                width: 190,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 5,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      _extractMovieName(
                                        imageUrls[index],
                                      ),
                                      softWrap: true,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        ]);
      },
    );
  }
}
