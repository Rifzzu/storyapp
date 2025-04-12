import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:storyapp/data/model/base_response.dart';
import 'package:storyapp/data/model/detail_story_response.dart';
import 'package:storyapp/data/model/stories_response.dart';

class ApiService {
  static const String _baseUrl = 'https://story-api.dicoding.dev/v1';

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl/register");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to register, ${responseData['message']}');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl/login");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login, ${responseData['message']}');
    }
  }

  Future<StoriesResponse> getStories([int page = 1, int size = 10]) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');
    final url = Uri.parse("$_baseUrl/stories?page=$page&size=$size&location=0");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return StoriesResponse.fromJson(responseData);
    } else {
      throw Exception(
        'Failed to fetch stories, ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<DetailStoryResponse> getDetailStory(String storyId) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');
    final url = Uri.parse("$_baseUrl/stories/$storyId");
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      return DetailStoryResponse.fromJson(responseData);
    } else {
      throw Exception(
        'Failed to fetch detail story, ${response.statusCode}: ${response.body}',
      );
    }
  }

  Future<BaseResponse> addStory(
    List<int> bytes,
    String fileName,
    String description, {
    double? lat,
    double? lon,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString('token');
    final uri = Uri.parse("$_baseUrl/stories");

    var request = http.MultipartRequest('POST', uri);

    final multiPartFile = http.MultipartFile.fromBytes(
      "photo",
      bytes,
      filename: fileName,
    );

    if (lat != null && lon != null) {
      request.fields['lat'] = lat.toString();
      request.fields['lon'] = lon.toString();
    }

    final Map<String, String> fields = {"description": description};
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      "Content-type": "multipart/form-data",
    };

    request.files.add(multiPartFile);
    request.fields.addAll(fields);
    request.headers.addAll(headers);

    try {
      final http.StreamedResponse streamedResponse = await request.send();
      final int statusCode = streamedResponse.statusCode;
      final Uint8List responseList = await streamedResponse.stream.toBytes();
      final String responseData = String.fromCharCodes(responseList);

      if (statusCode == 201) {
        final Map<String, dynamic> parsedJson = jsonDecode(responseData);
        final BaseResponse uploadResponse = BaseResponse.fromJson(parsedJson);
        return uploadResponse;
      } else {
        final responseMap = jsonDecode(responseData) as Map<String, dynamic>;
        final String errorMessage = responseMap['message'] ?? 'Upload failed';
        throw Exception('Error : $errorMessage');
      }
    } catch (e) {
      throw Exception("Failed to upload story: $e");
    }
  }
}
