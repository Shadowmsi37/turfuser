import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:turfuser/Booking.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String> imageUrls = [];
  String turfName = '';
  String turfDistrict = '';
  String turfRate = '';
  bool valueCricket = false;
  bool valueFootball = false;
  bool valueBasketball = false;
  bool valueBadminton = false;
  bool valueVolleyball = false;
  bool valueTennis = false;
  bool valueWifi = false;
  bool valueParking = false;
  bool valueFirstAid = false;
  bool valueRestroom = false;
  bool valueCCTV = false;
  bool valueCharging = false;

  TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredTurfs = [];

  @override
  void initState() {
    super.initState();
    // Add listener to search controller to update searchQuery
    searchController.addListener(() {
      setState(() {
        searchQuery = searchController.text.toLowerCase();
      });
    });
  }

  void filterTurfs(String query) {
    setState(() {
      filteredTurfs = filteredTurfs.where((doc) {
        String turfName = doc['TurfName'].toString().toLowerCase();
        return turfName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Turf Teams"),
        backgroundColor: Colors.lightGreen,
      ),
      backgroundColor: Colors.lightGreen[200],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Profile and Location
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .where('Email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No profile data available"));
                }

                var userData = snapshot.data!.docs[0];

                return Column(
                  children: [
                    ListTile(
                      title: Text('Location'),
                      subtitle: Row(
                        children: [
                          Icon(Icons.location_pin, color: Colors.red),
                          Text('${userData['District']}'),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                            filterTurfs(searchQuery);
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Search',
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                );
              },
            ),
            // Turf Grid with search query filter
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    "Turf Near Me",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('Admin')
                  .where('TurfName', isGreaterThanOrEqualTo: searchQuery)
                  .where('TurfName', isLessThan: searchQuery + 'z')
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No turf data available"));
                }

                filteredTurfs = snapshot.data!.docs;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredTurfs.length,
                  itemBuilder: (context, index) {
                    var userData = filteredTurfs[index];

                    turfName = userData['TurfName'] ?? '';
                    turfDistrict = userData['TurfDistrict'] ?? '';
                    turfRate = userData['TurfRate'] ?? '';
                    imageUrls = List<String>.from(userData['TurfImages'] ?? []);

                    var sports = userData['Sports'];
                    valueCricket = sports['Cricket'] ?? false;
                    valueFootball = sports['Football'] ?? false;
                    valueBasketball = sports['Basketball'] ?? false;
                    valueBadminton = sports['Badminton'] ?? false;
                    valueVolleyball = sports['Volleyball'] ?? false;
                    valueTennis = sports['Tennis'] ?? false;

                    var facilities = userData['Facilities'];
                    valueWifi = facilities['Wifi'] ?? false;
                    valueParking = facilities['Parking'] ?? false;
                    valueFirstAid = facilities['First Aid'] ?? false;
                    valueRestroom = facilities['Restroom'] ?? false;
                    valueCCTV = facilities['CCTV'] ?? false;
                    valueCharging = facilities['Charging'] ?? false;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Booking(
                              turfName: turfName,
                              turfRate: turfRate,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white, Colors.grey.shade100],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 6)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  autoPlay: true,
                                  enlargeCenterPage: true,
                                  aspectRatio: 4 / 3,
                                  viewportFraction: 1.0,
                                ),
                                items: imageUrls.map<Widget>((imageUrl) {
                                  return Container(
                                    width: double.infinity,
                                    child: Image.network(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              turfName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                            SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.location_on, color: Colors.red, size: 18),
                                SizedBox(width: 5),
                                Text(
                                  turfDistrict,
                                  style: TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Rate per Hour: ₹$turfRate",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
