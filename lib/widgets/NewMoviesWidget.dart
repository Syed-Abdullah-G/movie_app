import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

final db = FirebaseFirestore.instance;

class NewMoviesWidget extends StatefulWidget {
  const NewMoviesWidget({super.key});

  @override
  State<NewMoviesWidget> createState() => _NewMoviesWidgetState();
}

class _NewMoviesWidgetState extends State<NewMoviesWidget> {
  String query = "";
  List imageUrl = [];
  List downloadUrl = [];
  List<dynamic> filteredImageUrl = [];
  List<dynamic> filteredDownloadUrl = [];
  Future<Map<String, dynamic>?>? _futureData;

  Future<Map<String, dynamic>?> _fetchData() async {
    try {
      final docRef = db.collection("movie").doc("d_link");
      //fetch the document
      DocumentSnapshot doc = await docRef.get();
      //check if the document exists
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          imageUrl = data["image_url"];
          downloadUrl = data["download_link"];
          filteredImageUrl = imageUrl;
          filteredDownloadUrl = downloadUrl;
        });
        return data;
      } else {
        print("Document does not exist");
        return null;
      }
    } catch (e) {
      print("Error fetching data: $e");
      return null;
    }
  }

  void onQueryChanged(String newQuery) {
    setState(() {
      query = newQuery;

      if (query.isEmpty) {
        filteredImageUrl = imageUrl;
        filteredDownloadUrl = downloadUrl;
      } else {
        filteredImageUrl = [];
        filteredDownloadUrl = [];

        for (int i = 0; i < imageUrl.length; i++) {
          if (_extractMovieName(imageUrl[i])
              .toLowerCase()
              .contains(query.toLowerCase())) {
            filteredImageUrl.add(imageUrl[i]);
            filteredDownloadUrl.add(downloadUrl[i]);
          }
        }
      }
    });
  }

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
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureData = _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //dismiss the keyboard when tapping anywhere outside the text field
        FocusScope.of(context).unfocus();
      },
    
        child: Column(children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Color(0xFF292B37),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: Colors.white54,
                ),
                SizedBox(
                  width: 3,
                ),
                Expanded(
                  child: TextField(
                    onChanged: onQueryChanged,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search",
                        hintStyle: TextStyle(color: Colors.white54)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FutureBuilder(
            future: _futureData,
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
              if (!snapshot.hasData) {
                return Center(
                  child: Text("Document does not exist"),
                );
              }
        
              //final data = snapshot.data!.data() as Map<String, dynamic>;
              //final imageUrls = data["image_url"] as List<dynamic>;
              //final download_urls = data["download_url"];
        
              //if (filteredImageUrl.isEmpty){
              //filteredImageUrl = List<String>.from(imageUrls);
              //filteredDownloadUrl = List<String>.from(download_urls);
              //}
        
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
                    height: MediaQuery.of(context).size.height * 0.65,
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.55
        
                            // Adjust to fit your design
                            ),
                        itemCount: filteredImageUrl.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              _launchInBrowser(filteredDownloadUrl[index]);
                            },
                            child: Container(
                              margin: EdgeInsets.all(2),
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
                                      filteredImageUrl[index],
                                      height: MediaQuery.of(context).size.height *
                                          0.21,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 5,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Text(
                                            _extractMovieName(
                                              filteredImageUrl[index],
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
          )
        ]),
      
    );
  }
}
