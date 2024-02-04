import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchApiDelegate extends SearchDelegate {
  Timer? _debounceTimer;
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return Material(
      color: Colors.white,
      child: FutureBuilder(
        future: fetchData(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('country not found'.toUpperCase()));
          } else {
            List<String> matchQuery = List<String>.from(snapshot.data ?? []);

            return Material(
              color: Colors.white,
              child: ListView.builder(
                itemCount: matchQuery.length,
                itemBuilder: (context, index) {
                  var result = matchQuery[index];
                  return InkWell(
                    onTap: () {
                      //
                    },
                    child: ListTile(
                      title: Text(result),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  Future<List<String>> fetchData(String query) async {
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {});
    if (query.isNotEmpty) {
      var header = {
        'Content-Type': 'application/x-www-form-urlencoded',
      };
      var response = await http.post(
        Uri.parse('https://countriesnow.space/api/v0.1/countries/cities'),
        body: {
          'country': query,
        },
        headers: header,
      );
      List<String> data = [];
      var res = jsonDecode(response.body);
      for (int index = 0; index < res['data'].length; index++) {
        data.add(res['data'][index]);
      }
      return data;
    }
    return [];
  }
}
