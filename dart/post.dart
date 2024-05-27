import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnotherScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Post and View API Example',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: PostAndViewApiScreen(),
      );
}

class PostAndViewApiScreen extends StatefulWidget {
  @override
  _PostAndViewApiScreenState createState() => _PostAndViewApiScreenState();
}

class _PostAndViewApiScreenState extends State<PostAndViewApiScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    final String apiUrl = 'http://localhost:3000/posts'; // Replace with your mock server URL

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      // Data fetched successfully
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _posts = data.map((json) => Post.fromJson(json)).toList();
      });
    } else {
      // Failed to fetch data
      print('Failed to fetch data');
    }
  }

  Future<void> _postData(String title, String body) async {
    final String apiUrl = ' https://jsonplaceholder.typicode.com/comments'; // Replace with your mock server URL

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': title,
        'body': body,
      }),
    );

    if (response.statusCode == 201) {
      // Data posted successfully
      print('Data posted successfully');
      _titleController.clear();
      _bodyController.clear();
      _fetchPosts(); // Refresh the posts list
    } else {
      // Failed to post data
      print('Failed to post data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post and View API Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(labelText: 'Body'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String title = _titleController.text;
                String body = _bodyController.text;
                _postData(title, body);
              },
              child: Text('Post Data'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_posts[index].title),
                    subtitle: Text(_posts[index].body),
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

class Post {
  final String id;
  final String title;
  final String body;

  Post({
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'].toString(),
      title: json['title'],
      body: json['body'],
    );
  }
}
