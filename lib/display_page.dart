import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DisplayDataPage extends StatefulWidget {
  const DisplayDataPage({super.key});

  @override
  State<DisplayDataPage> createState() => _DisplayDataPageState();
}

class _DisplayDataPageState extends State<DisplayDataPage> {
  String date = "";
  String amount = "";
  String purpose = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      date = prefs.getString('date') ?? "No Date";
      amount = prefs.getString('amount') ?? "0";
      purpose = prefs.getString('purpose') ?? "No Purpose";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stored Data")),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Date: $date", style: const TextStyle(fontSize: 18)),
                const Divider(),
                Text("Amount: ₹$amount", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                const Divider(),
                Text("Purpose: $purpose", style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}