import 'package:storyapp/data/model/detail_story_response.dart';

class StoriesResponse {
  bool error;
  String message;
  List<Story> listStory;

  StoriesResponse({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory StoriesResponse.fromJson(Map<String, dynamic> json) =>
      StoriesResponse(
        error: json["error"],
        message: json["message"],
        listStory: List<Story>.from(
          json["listStory"].map((x) => Story.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "error": error,
    "message": message,
    "listStory": List<dynamic>.from(listStory.map((x) => x.toJson())),
  };
}
