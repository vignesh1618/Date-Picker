import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // Add pannunga
import 'display_page.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  
  String currentTime = DateFormat('hh:mm a').format(DateTime.now());
  DateTime? _selectedDate; 

  Future<void> _saveDataOnly() async {
    if (_selectedDate == null) {
      _showError("Select Date!");
      return;
    }
    if (_amountController.text.isEmpty) {
      _showError("Enter Amount!");
      return;
    }
    if (_purposeController.text.isEmpty) {
      _showError("Write Purpose!");
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('transactions').add({
        'amount': _amountController.text,
        'purpose': _purposeController.text,
        'date': "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
        'time': currentTime,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data Saved Successfully"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        
        _amountController.clear();
        _purposeController.clear();
        
        setState(() {
          _selectedDate = null; 
          currentTime = DateFormat('hh:mm a').format(DateTime.now()); 
        });
      }
    } catch (e) {
      _showError("Error: ${e.toString()}");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Add Transaction", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2874F0),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, size: 30, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DisplayDataPage()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.blue),
                  title: const Text("Current Time"),
                  trailing: Text(currentTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 15),
              
              ListTile(
                title: Text(_selectedDate == null 
                    ? "Select Date" 
                    : "Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                trailing: const Icon(Icons.calendar_today, color: Colors.blue),
                tileColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.grey, width: 0.5)),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              const SizedBox(height: 15),
              
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number, 
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: "Amount",
                  prefixText: "₹ ",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _purposeController,
                decoration: const InputDecoration(
                  labelText: "Purpose",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              
              ElevatedButton(
                onPressed: _saveDataOnly, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("SUBMIT",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}