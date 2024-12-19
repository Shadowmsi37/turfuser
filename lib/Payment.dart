import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:turfuser/BookingStatus.dart';

class Payment extends StatefulWidget {
  final int totalAmount;
  final String turfName;
  final DateTime startDate;
  final TimeOfDay startTime;
  final TextEditingController hours;

  const Payment({
    super.key,
    required this.totalAmount,
    required this.turfName,
    required this.startDate,
    required this.startTime,
    required this.hours,
  });

  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  bool validateCardNumber(String value) {
    return value.length == 16 && value.contains(RegExp(r'^\d+$'));
  }

  bool validateExpiryDate(String value) {
    return RegExp(r'^(0[1-9]|1[0-2])\/\d{2}$').hasMatch(value);
  }

  bool validateCVV(String value) {
    return value.length == 3 && value.contains(RegExp(r'^\d+$'));
  }

  void handlePayment() async {




    if (_formKey.currentState!.validate()) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("User not logged in")));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Payment Successful")));

      FirebaseFirestore.instance.collection('Bookings').add({
        'TurfName': widget.turfName,
        'TotalAmount': widget.totalAmount,
        'StartDate': widget.startDate,
        'StartTime': widget.startTime.format(context),
        'RequiredHours': widget.hours.text,
        'BookingDate': DateTime.now(),
        'Payment': 'Success',
        'Status': 'Pending',
        'UserId': userId,
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BookingStatus()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(CupertinoIcons.back),
        ),
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
              ),
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Payment for ${widget.turfName}',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text("Total Amount: ₹${widget.totalAmount}"),
                  SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _cardNumberController,
                          decoration: InputDecoration(
                            labelText: 'Credit Card Number',
                            labelStyle: TextStyle(color: Colors.cyan),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.cyan),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.cyan.shade700),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a card number';
                            } else if (!validateCardNumber(value)) {
                              return 'Invalid card number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _expiryDateController,
                          decoration: InputDecoration(
                            labelText: 'Expiry Date (MM/YY)',
                            labelStyle: TextStyle(color: Colors.cyan),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.cyan),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.cyan.shade700),
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                          maxLength: 5,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter expiry date';
                            } else if (!validateExpiryDate(value)) {
                              return 'Invalid expiry date';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _cvvController,
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            labelStyle: TextStyle(color: Colors.cyan),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.cyan),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(color: Colors.cyan.shade700),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter CVV';
                            } else if (!validateCVV(value)) {
                              return 'Invalid CVV';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.black),
                              shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                            ),
                            onPressed: handlePayment,
                            child: Text(
                              'Pay ₹${widget.totalAmount}',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
