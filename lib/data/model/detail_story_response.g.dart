// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'detail_story_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DetailStoryResponseImpl _$$DetailStoryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$DetailStoryResponseImpl(
  error: json['error'] as bool,
  message: json['message'] as String,
  story: Story.fromJson(json['story'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$DetailStoryResponseImplToJson(
  _$DetailStoryResponseImpl instance,
) => <String, dynamic>{
  'error': instance.error,
  'message': instance.message,
  'story': instance.story,
};
