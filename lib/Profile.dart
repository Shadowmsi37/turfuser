import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turfuser/Login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  TextEditingController Name = TextEditingController();
  TextEditingController Age = TextEditingController();
  TextEditingController District = TextEditingController();
  final CollectionReference user = FirebaseFirestore.instance.collection("User");
  final FirebaseStorage storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  late String currentUserId;
  String? profileImage;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  Future fetchDetails() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('Email', isEqualTo: FirebaseAuth.instance.currentUser!.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userData = querySnapshot.docs[0];
        setState(() {
          currentUserId = userData.id;
          Name.text = userData['Name'];
          Age.text = userData['Age'];
          District.text = userData['District'];
          profileImage = userData['ProfilePicture'];
        });
      }
    } catch (e) {
      print('Error:$e');
    }
  }

  Future<void> changeProfilePicture() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      try {
        String fileName = pickedFile.name;
        Reference storageRef = storage.ref().child("Profile_Pictures/$currentUserId/$fileName");
        await storageRef.putFile(File(pickedFile.path));
        String downloadUrl = await storageRef.getDownloadURL();

        FirebaseFirestore.instance
            .collection('User')
            .doc(currentUserId)
            .update({'ProfilePicture': downloadUrl}).then((_) {
          setState(() {
            profileImage = downloadUrl;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Profile picture updated successfully'),
            backgroundColor: Colors.green,
          ));
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error updating profile picture: $error'),
            backgroundColor: Colors.red,
          ));
        });
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  void deleteAccount() async {
    try {
      await FirebaseFirestore.instance.collection('User').doc(currentUserId).delete();
      await FirebaseAuth.instance.currentUser!.delete();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Account deleted successfully'),
        backgroundColor: Colors.green,
      ));
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
      ));
    }
  }
  Future signout() async {
    await FirebaseAuth.instance.signOut();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blue,
      content: Text(
        'Signout successfully',
        style: TextStyle(color: Colors.black),
      ),
      action: SnackBarAction(
          label: 'Cancel', textColor: Colors.black, onPressed: () {}),
    ));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Login(),
      ),
    );
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();
    preferences.setBool('islogged',false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: profileImage == null
                    ? AssetImage('lib/Images/Default.png')
                    : NetworkImage(profileImage!) as ImageProvider,
                radius: 60,
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  backgroundColor: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: changeProfilePicture,
                child: Text(
                  'Change Profile Picture',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
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

                return ExpansionTile(
                  title: Text(
                    'My Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightGreen),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${userData['Name']}', style: TextStyle(fontSize: 16, color: Colors.black87)),
                          SizedBox(height: 8),
                          Text('Age: ${userData['Age']}', style: TextStyle(fontSize: 16, color: Colors.black87)),
                          SizedBox(height: 8),
                          Text('District: ${userData['District']}', style: TextStyle(fontSize: 16, color: Colors.black87)),
                          SizedBox(height: 8),
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.lightGreen,
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Update Data'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          TextField(
                                            controller: Name,
                                            decoration: InputDecoration(
                                              labelText: 'Name',
                                              labelStyle: TextStyle(color: Colors.lightGreen),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.lightGreen),
                                              ),
                                            ),
                                          ),
                                          TextField(
                                            controller: Age,
                                            decoration: InputDecoration(
                                              labelText: 'Age',
                                              labelStyle: TextStyle(color: Colors.lightGreen),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.lightGreen),
                                              ),
                                            ),
                                          ),
                                          TextField(
                                            controller: District,
                                            decoration: InputDecoration(
                                              labelText: 'District',
                                              labelStyle: TextStyle(color: Colors.lightGreen),
                                              focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(color: Colors.lightGreen),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.lightGreen,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () {
                                            FirebaseFirestore.instance.collection('User').doc(userData.id).update({
                                              'Name': Name.text,
                                              'Age': Age.text,
                                              'District': District.text,
                                            }).then((_) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text('Profile updated successfully!'),
                                                backgroundColor: Colors.green,
                                              ));
                                            }).catchError((e) {
                                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                                content: Text('Error: $e'),
                                                backgroundColor: Colors.red,
                                              ));
                                            });
                                            Navigator.pop(context);
                                          },
                                          child: Text('Update'),
                                        ),
                                      ),
                                      Center(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(30),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Text('Edit Profile'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: 20),
            ExpansionTile(
              title: Text(
                'Account Options',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.lightGreen),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ExpansionTile(
                        title: Text(
                          'Contact Us',
                          style: TextStyle(fontSize: 16),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Phone Number: +917025890421'),
                                Text('Email Address: ronysunil@gmail.com'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          onPressed: deleteAccount,
                          child: Text('Delete Account'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  signout();
                },
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
