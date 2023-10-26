import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Data {
  final int count;
  final List<Album> entries;

  const Data({
    required this.count,
    required this.entries,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      count: json['count'] as int,
      entries: List<Album>.from(json["entries"].map((x) => Album.fromJson(x))),
    );
  }
}

class Album {
  final String API;
  final String Description;
  final String Auth;
  final String Category;

  const Album({
    required this.API,
    required this.Description,
    required this.Auth,
    required this.Category,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      API: json['API'] as String,
      Description: json['Description'] as String,
      Auth: json['Auth'] as String,
      Category: json['Category'] as String,
    );
  }
}

class AddResponse {
  final String msg;
  final Bool success;

  const AddResponse({
    required this.msg,
    required this.success,
  });

  factory AddResponse.fromJson(Map<String, dynamic> json) {
    return AddResponse(
      msg: json['msg'] as String,
      success: json['success'] as Bool
    );
  }
}

Future<Data> fetchAlbum() async {
  final response = await http.get(Uri.parse('https://api.publicapis.org/entries'));
  if (response.statusCode == 200) {
    print(response.body);
    return Data.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load album');
  }
}

Future<AddResponse> addAlbum(String name, String area) async {
  final response = await http.post(
      Uri.parse('https://jsonplaceholder.typicode.com/albums'),
      headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8',},
      body: jsonEncode(<String, String>{'name': name,'areaNmae': area}));
  if (response.statusCode == 200) {
    return AddResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    throw Exception('Failed to load album');
  }
}

class _MyHomePageState extends State<MyHomePage> {

  late Future<Data> futureAlbum;

  late Future<AddResponse> futureAddAlbum;

  @override
  void initState() {
    super.initState();
    futureAlbum = fetchAlbum();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Data Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Fetch Data Example'),
        ),
        body: Center(
          child: FutureBuilder<Data>(
            future: futureAlbum,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  // Let the ListView know how many items it needs to build.
                  itemCount: snapshot.data?.entries.length,
                  // Provide a builder function. This is where the magic happens.
                  // Convert each item into a widget based on the type of item it is.
                  itemBuilder: (context, index) {
                    final item = snapshot.data?.entries[index];

                    return ListTile(
                      title: Text(item!.Category),
                      subtitle: Text(item!.Description),
                    );
                  },
                );
              }
              else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
