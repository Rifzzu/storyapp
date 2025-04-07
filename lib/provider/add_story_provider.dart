import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:storyapp/data/api/api_service.dart';
import 'package:storyapp/data/model/base_response.dart';

class AddStoryProvider extends ChangeNotifier {
  final ApiService apiService;

  AddStoryProvider(this.apiService);

  bool isUploading = false;
  String message = "";
  BaseResponse? uploadResponse;
  String? imagePath;
  XFile? imageFile;

  void setImagePath(String? value) {
    imagePath = value;
    notifyListeners();
  }

  void setImageFile(XFile? value) {
    imageFile = value;
    notifyListeners();
  }

  Future<void> addStory(
    List<int> bytes,
    String fileName,
    String description,
  ) async {
    try {
      message = "";
      uploadResponse = null;
      isUploading = true;
      notifyListeners();

      uploadResponse = await apiService.addStory(bytes, fileName, description);
      message = uploadResponse?.message ?? "success";
      isUploading = false;
      notifyListeners();
    } catch (e) {
      isUploading = false;
      message = "An error occurred: ${e.toString()}";
      notifyListeners();
    }
  }

  Future<List<int>> compressImage(List<int> bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;

    final img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;

    int compressQuality = 100;
    int length = imageLength;
    List<int> newByte = [];
    do {
      compressQuality -= 10;
      newByte = img.encodeJpg(image, quality: compressQuality);
      length = newByte.length;
    } while (length > 1000000);
    return newByte;
  }
}
