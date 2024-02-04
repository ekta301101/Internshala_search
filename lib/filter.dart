import 'package:flutter/material.dart';
import 'main.dart';

class FilterPage extends StatefulWidget {
  final Future<List<Internship>> allInternships;

  FilterPage({required this.allInternships});

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  String selectedProfile = '';
  String selectedCity = '';
  String selectedDuration = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter Options'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOptions(
                'Select Profile',
                ['Marketing', 'Data Science Intern'],
                selectedProfile,
                updateProfile),
            _buildOptions('Select City', ['Work from Home', 'Bangalore'],
                selectedCity, updateCity),
            _buildOptions(
                'Select Duration',
                ['1 month', '2 months', '3 months'],
                selectedDuration,
                updateDuration),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Apply filters and update the internships list
                applyFilters();
              },
              child: Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(String label, List<String> options, String selectedValue,
      void Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Column(
          children: options.map((option) {
            return ListTile(
              title: Text(option),
              leading: Radio<String>(
                value: option,
                groupValue: selectedValue,
                onChanged: (value) {
                  onChanged(value!);
                },
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }

  void updateProfile(String value) {
    setState(() {
      selectedProfile = value;
    });
  }

  void updateCity(String value) {
    setState(() {
      selectedCity = value;
    });
  }

  void updateDuration(String value) {
    setState(() {
      selectedDuration = value;
    });
  }

  void applyFilters() {
    // Check if any filter is applied
    if (selectedProfile.isNotEmpty ||
        selectedCity.isNotEmpty ||
        selectedDuration.isNotEmpty) {
      // Get the list of all internships
      widget.allInternships.then((allInternships) {
        // Assuming you have a list of all internships, let's call it allInternships
        List<Internship> filteredInternships = allInternships;

        // Apply filters based on selectedProfile
        if (selectedProfile.isNotEmpty) {
          filteredInternships = filteredInternships
              .where((internship) => internship.title == selectedProfile)
              .toList();
        }

        // Apply filters based on selectedCity
        if (selectedCity.isNotEmpty) {
          filteredInternships = filteredInternships
              .where((internship) =>
                  internship.locationNames.contains(selectedCity))
              .toList();
        }

        // Return the filtered internships to the calling page (SearchPage)
        Navigator.pop(context, filteredInternships);
      });
    } else {
      // No filters applied, return null
      Navigator.pop(context, null);
    }
  }
}
