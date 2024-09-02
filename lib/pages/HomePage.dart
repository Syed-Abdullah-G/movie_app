import 'package:flutter/material.dart';
import 'package:movie_app/widgets/NewMoviesWidget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 50, left: 10,right: 10,bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Download Movies",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Tamil Movies",
                    style: TextStyle(
                      color: Colors.white54,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      
       
         NewMoviesWidget()
        
      ],
    ));
  }
}
