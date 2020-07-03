import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../user_location.dart';

class view  extends StatefulWidget {
  @override
  _viewState createState() => _viewState();
}

class _viewState extends State<view> {



   Completer<GoogleMapController>_controller = Completer();

    Marker marker;
    Circle circle;
    List<NearbyPlace> nearbyPlaces = List();
          String apikey = "YOUR API KEY";
          String atm = "atm";
          String hospital = "hospital";

             LatLng latLng = LatLng(37.42796133580664,-122.085749655962);
              bool hasSearchTerm = false;
                final Set<Marker> markers = Set();
    
    static final CameraPosition _initialPosition = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    );



    void updateMarkerAndCircle(LatLng latlng) {
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
          position: latlng,
          rotation: 0,
          draggable: false,
          zIndex: 8,
          flat: false,
          );
      circle = Circle(
          circleId: CircleId("CurrentPosition"),
          radius: 3,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
    });
  }

  Future<void> _goToCurrentLocation() async {
      final GoogleMapController controller = await _controller.future;
      
      var userLocation = Provider.of<UserLocation>(context);
      print('Location: Lat${userLocation.latitude}, Long: ${userLocation.longitude}');
      CameraPosition _currentLocation = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(userLocation.latitude,userLocation.longitude),
        tilt: 59.440717697143555,
        zoom: 10.151926040649414);
      controller.animateCamera(CameraUpdate.newCameraPosition(_currentLocation));
        LatLng latlng = LatLng(userLocation.latitude, userLocation.longitude);
      updateMarkerAndCircle(latlng);
    }






  Future<List<NearbyPlace>> _getUsers(String type) async {
              var userLocation = Provider.of<UserLocation>(context);
              try{
               var data =  await http.get("https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=$apikey"+
              "&location=${userLocation.latitude},${userLocation.longitude}"+
              "&radius=10000&types=$type");
              var jsonData = json.decode(data.body);
              this.nearbyPlaces.clear();
              for (Map<String, dynamic> item in jsonData['results']) {
                      final nearbyPlace = NearbyPlace()
                                ..name = item['name']
                                ..icon = item['icon']
                                ..latLng = LatLng(item['geometry']['location']['lat'], item['geometry']['location']['lng']);
                                
                                
                                this.nearbyPlaces.add(nearbyPlace);
                                                                    }
          print(nearbyPlaces.length);
            nearbyPlaces.forEach((x)
            {
              setMarker(x);

            });
         }
              catch(e){
                      print(e);
                   }
    return nearbyPlaces;
}

void setMarker(NearbyPlace nearbyPlace)
{
    setState(() {
      
      markers.add(Marker(markerId: MarkerId(nearbyPlace.name), position: nearbyPlace.latLng));
    });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
            body: Stack(
                children: <Widget>[
                  googleMap(context),
                  currentLocation(),
                  currentNearByAtm(),
                  currentNearByHospitals()


                ],

            )   

    )
      
    ;
  }



Widget googleMap(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: GoogleMap(
        mapType: MapType.hybrid,
        initialCameraPosition:  _initialPosition,
        markers: markers ,
        circles: Set.of((circle != null) ? [circle] : []),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        
      ),
      
    
    );
  }


  Widget currentLocation(){
    
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
            icon: Text("go to current location", overflow: TextOverflow.ellipsis,
  style: TextStyle(fontWeight: FontWeight.bold),),color:Color(0xff6200ee),
            onPressed: _goToCurrentLocation
          ),
    );
  }



  Widget currentNearByAtm(){
    
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
            icon: Text("atm", overflow: TextOverflow.ellipsis,
  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30.0),),
            onPressed: () {
              showBottomSheet(context: context, 
              builder: (builder){
                return Container(
                      margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
          child: FutureBuilder(
            future: _getUsers(atm),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              print(snapshot.data);
              if(snapshot.data == null){
                return Container(
                  child: Center(
                    child: Text("Loading...")
                  )
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) { 
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          snapshot.data[index].icon
                        ),
                      ),
                      title: Text(snapshot.data[index].name),
                      
                       onTap: ()async{
                         final GoogleMapController controller = await _controller.future;
                        CameraPosition _currentLocation = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(snapshot.data[index].latLng.latitude,snapshot.data[index].latLng.longitude),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
        controller.animateCamera(CameraUpdate.newCameraPosition(_currentLocation));
                        updateMarkerAndCircle(snapshot.data[index].latLng);

                      },
                      
                      
                    );
                  },
                );
              }
            },
          ),

                  
                );
              });
            }
          ),
    );
  }
 Widget currentNearByHospitals(){
    
    return Align(
      alignment: Alignment.centerRight,
      child: IconButton(
            icon: Text("Hospitals", overflow: TextOverflow.ellipsis,
  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30.0),),
            onPressed: () {
              showBottomSheet(context: context, 
              builder: (builder){
                return Container(
                      margin: EdgeInsets.symmetric(vertical: 20.0),
        height: 150.0,
          child: FutureBuilder(
            future: _getUsers(hospital),
            builder: (BuildContext context, AsyncSnapshot snapshot){
              print(snapshot.data);
              if(snapshot.data == null){
                return Container(
                  child: Center(
                    child: Text("Loading...")
                  )
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) { 
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          snapshot.data[index].icon
                        ),
                      ),
                      title: Text(snapshot.data[index].name),
                      
                       onTap: ()async{
                         final GoogleMapController controller = await _controller.future;
                        CameraPosition _currentLocation = CameraPosition(
        bearing: 192.8334901395799,
        target: LatLng(snapshot.data[index].latLng.latitude,snapshot.data[index].latLng.longitude),
        tilt: 59.440717697143555,
        zoom: 19.151926040649414);
        controller.animateCamera(CameraUpdate.newCameraPosition(_currentLocation));
                        updateMarkerAndCircle(snapshot.data[index].latLng);

                      },
                      
                      
                    );
                  },
                );
              }
            },
          ),

                  
                );
              });
            }
          ),
    );
  }





}


class NearbyPlace {

    String name;
    String icon;
    LatLng latLng;

}