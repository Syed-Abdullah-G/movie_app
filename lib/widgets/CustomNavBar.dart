import 'package:flutter/material.dart';
import 'package:movie_app/pages/Category.dart';
import 'package:movie_app/pages/HomePage.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Color(0xFF292B37),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        )
      ),

      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
     InkWell(
      onTap: (){
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => HomePage())
        );
      },
      child: Icon(Icons.home, size: 35,color: Colors.white,),
     ),
     InkWell(
      onTap: (){

        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => CategoryPage())
        );
      
      },
      child: Icon(Icons.category, size: 35,color: Colors.white,),
     ),
     InkWell(
      onTap: (){},
      child: Icon(Icons.favorite, size: 35,color: Colors.white,),
     ),
     InkWell(
      onTap: (){},
      child: Icon(Icons.person, size: 35,color: Colors.white,),
     )
        ],
      ),
    );
  }
}