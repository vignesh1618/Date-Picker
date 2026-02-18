import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'display_page.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveAndNavigate() async {
    if (_selectedDate == null || _amountController.text.isEmpty || _purposeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ella field-aiyum fill pannunga!")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('date', "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}");
    await prefs.setString('amount', _amountController.text);
    await prefs.setString('purpose', _purposeController.text);

    Navigator.push(context, MaterialPageRoute(builder: (context) => const DisplayDataPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Transaction"), backgroundColor: const Color(0xFF2874F0)),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              title: Text(_selectedDate == null ? "Select Date" : "Date: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Amount", filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(labelText: "Purpose", filled: true, fillColor: Colors.white, border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _saveAndNavigate,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, minimumSize: const Size(double.infinity, 50)),
              child: const Text("SUBMIT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}