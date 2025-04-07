import 'package:storyapp/data/model/detail_story_response.dart';

sealed class StoriesState {}

class NoneState extends StoriesState {}

class LoadingState extends StoriesState {}

class ErrorState extends StoriesState {
  final String error;

  ErrorState(this.error);
}

class LoadedState extends StoriesState {
  final List<Story> data;

  LoadedState(this.data);
}
