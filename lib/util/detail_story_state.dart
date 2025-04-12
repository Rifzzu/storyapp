import 'package:storyapp/data/model/story_response.dart';

sealed class DetailStoryState {}

class DetailNoneState extends DetailStoryState {}

class DetailLoadingState extends DetailStoryState {}

class DetailErrorState extends DetailStoryState {
  final String error;
  DetailErrorState(this.error);
}

class DetailLoadedState extends DetailStoryState {
  final Story data;
  DetailLoadedState(this.data);
}
