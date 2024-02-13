import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> _data = [];
  List<dynamic> _filteredData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      final response = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/abhirgi/Census/main/ICD_orgi.json'));

      if (response.statusCode == 200) {
        setState(() {
          _data = json.decode(response.body);
          _filteredData = _data;
          _isLoading =
              false; // Set loading state to false after data is fetched
        });
      } else {
        print('Failed to load data');
        setState(() {
          _isLoading =
              false; // Set loading state to false if data loading fails
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false; // Set loading state to false if an error occurs
      });
    }
  }

  void _filterData(String query) {
    setState(() {
      _filteredData = _data
          .where((item) =>
              item['Code'].toString().contains(query) ||
              item['MCCD Description'].toString().contains(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          color: Colors.black,
        ),
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('ICD-10 WHO Version', style: TextStyle(color: Colors.blueAccent,),)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.6, // Set width to 60% of the screen width
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.grey[900], // Dark grey background color
                  borderRadius: BorderRadius.circular(10.0), // Rounded corners
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.blueAccent), // Search icon
                    SizedBox(width: 8.0), // Add spacing between icon and text field
                    Expanded(
                      child: TextField(
                        style: TextStyle(color: Colors.white), // Text color
                        decoration: InputDecoration(
                          hintText: 'Search keyword', // Placeholder text
                          hintStyle: TextStyle(color: Colors.grey[400]), // Hint text color
                          border: InputBorder.none, // Hide border
                        ),
                        onChanged: _filterData,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      children: _filteredData.map((item) {
                        return Padding(
                          padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.02), // 20% padding from the left
                          child: ListTile(
                            title: Text(
                              '${item['MCCD Description']}',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              '${item['Code']}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
