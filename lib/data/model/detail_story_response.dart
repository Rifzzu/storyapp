import 'package:json_annotation/json_annotation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:storyapp/data/model/story_response.dart';

part 'detail_story_response.freezed.dart';
part 'detail_story_response.g.dart';

@freezed
class DetailStoryResponse with _$DetailStoryResponse {
  const factory DetailStoryResponse({
    required bool error,
    required String message,
    required Story story,
  }) = _DetailStoryResponse;

  factory DetailStoryResponse.fromJson(Map<String, dynamic> json) =>
      _$DetailStoryResponseFromJson(json);
}
