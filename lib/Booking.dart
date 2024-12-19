import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:turfuser/Payment.dart';

class Booking extends StatefulWidget {
  final String turfName;
  final String turfRate;

  const Booking({super.key, required this.turfName, required this.turfRate});

  @override
  State<Booking> createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  DateTime? _startDate;
  TimeOfDay? _startTime;
  final TextEditingController _hoursController = TextEditingController();

  void _selectStartDate(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );

      if (pickedTime != null) {
        setState(() {
          _startDate = pickedDate;
          _startTime = pickedTime;
        });
      }
    }
  }

  void _calculateTotalAmount() {
    if (_hoursController.text.isNotEmpty && _startDate != null && _startTime != null) {
      int hours = int.parse(_hoursController.text);
      int totalAmount = hours * int.parse(widget.turfRate);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Payment(
            totalAmount: totalAmount,
            turfName: widget.turfName,
            startDate: _startDate!,
            startTime: _startTime!,
            hours: _hoursController,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a valid start date and enter hours')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String formattedStartDate = _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : 'Not selected';
    String formattedStartTime = _startTime != null ? _startTime!.format(context) : 'Not selected';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Book ${widget.turfName}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
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
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Text(
                        "Start Date: $formattedStartDate",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Start Time: $formattedStartTime",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _selectStartDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      minimumSize: Size(150, 50),
                    ),
                    child: Text(
                      "Select Start Date & Time",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        "Enter Hours: ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: _hoursController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Hours',
                          ),
                        ),
                      ),
                    ],
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
                      onPressed: _calculateTotalAmount,
                      child: Text(
                        'Confirm Booking',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
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
