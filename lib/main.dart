import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Monitoring Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Health Monitoring Dashboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController bloodPressureController = TextEditingController();
  final TextEditingController glucoseController = TextEditingController();

  void addData() async {
    // Example URL for your backend API
    final response = await http.post(
      Uri.parse(
          'http://localhost:18080/add'), // Change this URL based on your C++ backend setup.
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, int>{
        'heartRate': int.parse(heartRateController.text),
        'bloodPressure': int.parse(bloodPressureController.text),
        'glucoseLevel': int.parse(glucoseController.text),
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Data added successfully!')));
      heartRateController.clear();
      bloodPressureController.clear();
      glucoseController.clear();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add data!')));
    }
  }

  Future<List<dynamic>> fetchRecords() async {
    final response =
        await http.get(Uri.parse('http://localhost:18080/records'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['records'];
    } else {
      throw Exception('Failed to load records');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: heartRateController,
              decoration: InputDecoration(labelText: 'Heart Rate'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: bloodPressureController,
              decoration: InputDecoration(labelText: 'Blood Pressure'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: glucoseController,
              decoration: InputDecoration(labelText: 'Glucose Level'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addData,
              child: Text('Add Data'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: fetchRecords(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error fetching records'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No records found'));
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var record = snapshot.data![index];
                      return ListTile(
                        title: Text('Heart Rate: ${record['heartRate']}'),
                        subtitle: Text(
                            'Blood Pressure: ${record['bloodPressure']}, Glucose Level: ${record['glucoseLevel']}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
