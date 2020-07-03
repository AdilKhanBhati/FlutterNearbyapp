import 'package:flutter/material.dart';
import 'package:newapp1/location_service.dart';
import 'package:newapp1/user_location.dart';

import 'package:newapp1/views/page.dart';  
import 'package:provider/provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
      create : (context) => LocationService().locationStream,
      child: MaterialApp(
        title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
            body: view(),
            
          )
      ),
    );
  }
}