import 'package:flutter/material.dart';
import 'package:gaurav_app/weather_screen.dart';

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
    
          constraints: const BoxConstraints.expand(),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/start 2.png"),
                      fit: BoxFit.cover),
                ),
    
                child: Container(
                  alignment: Alignment.bottomCenter,
    
                  child: InkWell(
    
                    onTap: () {
                      Navigator.pushReplacement(context, 
                      MaterialPageRoute(builder: (context) => WeatherScreen()),
                      );
                      
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        margin: EdgeInsets.only(bottom: 10),
                        width: 180,
                        padding: EdgeInsetsDirectional.all(7),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(15.0),
                          color: Color.fromARGB(255, 194, 173, 250)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                        
                            Text(
                                'GET STARTED',
                                style: TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24),
                              )
                            
                          ],
                        ),
                      ),
                    ) ,
                  ),
                ),
    
         ),
    );
    



  
  }
}