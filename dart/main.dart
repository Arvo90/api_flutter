import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'post.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'HTTP Package Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const HomeWidget(),
      );
}

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  late Future<List<Employee>> futureEmployees;

  @override
  void initState() {
    super.initState();
    futureEmployees = fetchEmployees();
  }

  Future<List<Employee>> fetchEmployees() async {
    final String url = 'https://dummy.restapiexample.com/api/v1/employees';
    final int maxRetries = 5;
    int retryCount = 0;
    Duration retryDelay = Duration(seconds: 1);

    while (retryCount < maxRetries) {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON.
        List<dynamic> data = json.decode(response.body)['data'];
        List<Employee> employees = data.map((json) => Employee.fromJson(json)).toList();
        return employees;
      } else if (response.statusCode == 429) {
        // If the server returns a 429 Too Many Requests response, wait and retry.
        retryCount++;
        await Future.delayed(retryDelay);
        retryDelay *= 2; // Exponential backoff
      } else {
        // If the server returns an error response, throw an exception.
        throw Exception('Failed to load employees');
      }
    }

    throw Exception('Exceeded maximum number of retries');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HTTP Package Example'),
      ),
      body: Center(
        child: FutureBuilder<List<Employee>>(
          future: futureEmployees,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Employee employee = snapshot.data![index];
                        return ListTile(
                          title: Text(employee.employeeName),
                          subtitle: Text(employee.employeeSalary),
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('${snapshot.error}'),
              );
            }

            // By default, show a loading spinner.
            return CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to another page or perform any action here
          // For example, navigate to a new screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AnotherScreen()),
          );
        },
        child: Icon(Icons.arrow_forward),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class Employee {
  final String id;
  final String employeeName;
  final String employeeSalary;
  final String employeeAge;
  final String profileImage;

  Employee({
    required this.id,
    required this.employeeName,
    required this.employeeSalary,
    required this.employeeAge,
    required this.profileImage,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'].toString(), // Ensuring ID is a string
      employeeName: json['employee_name'],
      employeeSalary: json['employee_salary'].toString(), // Ensuring salary is a string
      employeeAge: json['employee_age'].toString(), // Ensuring age is a string
      profileImage: json['profile_image'],
    );
  }
}

// Example of another screen you might navigate to

