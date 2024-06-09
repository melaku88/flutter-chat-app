import 'package:cwmm/pages/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FrontPage extends StatelessWidget {
  const FrontPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color.fromARGB(255, 16, 106, 151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black,
          toolbarHeight: 0.0,
        ),
        body: Container(
          padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 0.0),
          child: ListView(
            children: [
              Center(
                child: Image.asset('images/people.png', fit: BoxFit.fill,)
              ),
              SizedBox(height: 40.0,),
              Center(
                child: Column(
                  children: [
                    Text('Join Now', style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w600, color: Colors.black38),),
                    Text('&', style: TextStyle(fontSize: 70.0, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 17, 102, 142)),),
                    Text('Chat With Your', style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w600, color: Colors.black38),),
                    Text('Bests!', style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w600, color: Colors.black38),),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginPage()));
                      },
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(top: 30.0, bottom: 20.0),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 134, 212, 249),
                          borderRadius: BorderRadius.circular(50.0)
                        ),
                        child: Icon(Icons.arrow_forward_ios_outlined)
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}