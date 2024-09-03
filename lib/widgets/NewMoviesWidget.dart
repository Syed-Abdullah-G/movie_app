import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  late double width_childaspect;

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

  Future<void> _launchInBrowser(String urlRaw) async {
    final Uri url = Uri.parse(urlRaw);
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  void setWidth() {
    final width = MediaQuery.of(context).size.width;
    if (width > 450) {
      setState(() {
        width_childaspect = 0.73;
      });
    } else {
      setState(() {
        width_childaspect = 0.67;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureData = _fetchData();
    
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    setWidth();
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
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: const Color(0xFF292B37),
              borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              const Icon(
                Icons.search,
                color: Colors.white54,
              ),
              const SizedBox(
                width: 3,
              ),
              Expanded(
                child: TextField(
                  onChanged: onQueryChanged,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Search",
                      hintStyle: TextStyle(color: Colors.white54)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        FutureBuilder(
          future: _futureData,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error : ${snapshot.error}"),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: Text("Document does not exist"),
              );
            }

            return Column(children: [
              const Padding(
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
                height: MediaQuery.of(context).size.height * 1,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 20,
                      childAspectRatio: width_childaspect
                      
                      ),
                  itemCount: filteredImageUrl.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        _launchInBrowser(filteredDownloadUrl[index]);
                      },
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                            color: const Color(0xFF292B37),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 104, 88, 21)
                                    .withOpacity(0.5),
                                spreadRadius: 0.7,
                                blurRadius: 6,
                              )
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                              child: Image.network(
                                filteredImageUrl[index],
                                 height: width_childaspect == 0.73 ? 0 : 
                                    MediaQuery.of(context).size.height * 0.21,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
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
                                        filteredImageUrl[index],
                                      ),
                                      softWrap: true,
                                      style: const TextStyle(
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
            ]);
          },
        )
      ]),
    );
  }
}
