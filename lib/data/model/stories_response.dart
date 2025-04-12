import 'package:json_annotation/json_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:storyapp/data/model/story_response.dart';

part 'stories_response.freezed.dart';
part 'stories_response.g.dart';

@freezed
class StoriesResponse with _$StoriesResponse {
  const factory StoriesResponse({
    required bool error,
    required String message,
    required List<Story> listStory,
  }) = _StoriesResponse;

  factory StoriesResponse.fromJson(Map<String, dynamic> json) =>
      _$StoriesResponseFromJson(json);
}
