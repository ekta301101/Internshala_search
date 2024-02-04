import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'filter.dart';

void main() {
  runApp(SearchApp());
}

class SearchApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<List<Internship>> internships;

  @override
  void initState() {
    super.initState();
    internships = getInternships();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Internships'),
      ),
      drawer: Drawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                // Navigate to the filter page and pass the list of all internships
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FilterPage(allInternships: internships)),
                ).then((filteredInternships) {
                  // Handle the filtered internships returned from FilterPage
                  if (filteredInternships != null) {
                    setState(() {
                      internships = Future.value(filteredInternships);
                    });
                  }
                });
              },
              child: Text(
                'Filter Options',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: internships,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return MyCard(internship: snapshot.data![index]);
                    },
                  );
                } else {
                  return Center(
                    child: Text('No data available'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MyCard extends StatelessWidget {
  final Internship internship;

  MyCard({required this.internship});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 380.0,
        height: 230.0,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Actively Hiring',
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.0),
                Text(
                  internship.title,
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.0),
                Text(
                  internship.locationNames.join(", "),
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 12.0),
                Text(
                  '${internship.stipend.salary} ${internship.stipend.currency}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      // Add your navigation logic here
                    },
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<List<Internship>> getInternships() async {
  final response = await InternshipApi.fetchInternships();

  try {
    if (response != null) {
      final internshipList = internshipListFromJson(response);
      return internshipList;
    } else {
      throw Exception('Failed to fetch data');
    }
  } catch (e) {
    print(e);
    throw Exception('Failed to fetch data');
  }
}

class InternshipApi {
  static Future<String> fetchInternships() async {
    // Simulate fetching data from an API
    final response = await Future.delayed(Duration(seconds: 2), () {
      return http.Response(
        json.encode({
          "success": true,
          "internships_meta": [
            {
              "title": "Marketing",
              "company_name": "Careers360",
              "location_names": ["Work from Home"],
              "starts_in": "Starts Immediately",
              "duration": "2 months",
              "stipend": {
                "salary": "15,000 lump sum + incentives",
                "currency": "INR"
              }
            },
            {
              "title": "Crowd Funding",
              "company_name": "InAmigos Foundation",
              "location_names": ["Work from Home"],
              "starts_in": "Starts Immediately",
              "duration": "3 weeks",
              "stipend": {"salary": "Unpaid", "currency": ""}
            },
            {
              "title": "Data Science Intern",
              "company_name": "Data Insights Co",
              "location_names": ["Bangalore", "Remote"],
              "starts_in": "Starts Immediately",
              "duration": "6 months",
              "stipend": {"salary": "5000-12000", "currency": "INR"}
            }
          ]
        }),
        200,
      );
    });

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to fetch data');
    }
  }
}

List<Internship> internshipListFromJson(String str) {
  final parsed = json.decode(str)['internships_meta'];
  return List<Internship>.from(parsed.map((x) => Internship.fromJson(x)));
}

class Internship {
  final String title;
  final String companyName;
  final List<String> locationNames;
  final Stipend stipend;

  Internship({
    required this.title,
    required this.companyName,
    required this.locationNames,
    required this.stipend,
  });

  factory Internship.fromJson(Map<String, dynamic> json) {
    return Internship(
      title: json["title"],
      companyName: json["company_name"],
      locationNames: List<String>.from(json["location_names"].map((x) => x)),
      stipend: Stipend.fromJson(json["stipend"]),
    );
  }
}

class Stipend {
  final String salary;
  final String currency;

  Stipend({
    required this.salary,
    required this.currency,
  });

  factory Stipend.fromJson(Map<String, dynamic> json) {
    return Stipend(
      salary: json["salary"],
      currency: json["currency"],
    );
  }
}
