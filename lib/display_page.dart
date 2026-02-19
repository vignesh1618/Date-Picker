import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

class DisplayDataPage extends StatefulWidget {
  const DisplayDataPage({super.key});

  @override
  State<DisplayDataPage> createState() => _DisplayDataPageState();
}

class _DisplayDataPageState extends State<DisplayDataPage> {
  Future<void> _deleteItem(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('transactions').doc(docId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Item Deleted"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }
  _editItem(String docId, String currentAmount, String currentPurpose) {
    TextEditingController amountEdit = TextEditingController(text: currentAmount);
    TextEditingController purposeEdit = TextEditingController(text: currentPurpose);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Entry"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: amountEdit, decoration: const InputDecoration(labelText: "Amount"), keyboardType: TextInputType.number),
            TextField(controller: purposeEdit, decoration: const InputDecoration(labelText: "Purpose")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('transactions').doc(docId).update({
                'amount': amountEdit.text,
                'purpose': purposeEdit.text,
              });
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Transactions"),
        backgroundColor: const Color(0xFF2874F0),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .orderBy('timestamp', descending: true) 
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong!"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No data found!"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var doc = snapshot.data!.docs[index];
              var data = doc.data() as Map<String, dynamic>;
              String docId = doc.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.cloud_done, color: Colors.blue),
                  title: Text("₹${data['amount']}", 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
                  subtitle: Text("${data['purpose']}\nDate: ${data['date']} | Time: ${data['time'] ?? ''}"),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editItem(docId, data['amount'], data['purpose']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(docId),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context),
        backgroundColor: const Color(0xFF2874F0),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}