import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turfuser/Home.dart';

class BookingStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail == null) {
      return Center(child: Text("User not logged in", style: TextStyle(fontSize: 18, color: Colors.white)));
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
        }, icon: Icon(CupertinoIcons.back)),
        title: Text("Your Bookings"),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue,
              Colors.blue,
              Colors.purple,
              Colors.deepPurple.shade700,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Bookings')
              .where('UserId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 16, color: Colors.white)));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No bookings found.', style: TextStyle(fontSize: 18, color: Colors.white)));
            }

            var bookings = snapshot.data!.docs;

            return ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                var booking = bookings[index];
                var status = booking['Status'];
                Color statusColor;

                print("Booking Status: $status");

                switch (status) {
                  case 'Approved':
                    statusColor = Colors.green;
                    break;
                  case 'Declined':
                    statusColor = Colors.red;
                    break;
                  case 'Pending':
                    statusColor = Colors.blue;
                    break;
                  default:
                    statusColor = Colors.black;
                }

                return Card(
                  margin: EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      booking['TurfName'],
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date: ${booking['StartDate'].toDate()} at ${booking['StartTime']}',
                          style: TextStyle(fontSize: 16),
                        ),
                        if (status == 'Declined')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Refund will be initiated soon.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    trailing: Text(
                      'Status: $status',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    isThreeLine: true,
                    contentPadding: EdgeInsets.all(15),
                    onTap: () {},
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
