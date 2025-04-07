import 'package:flutter/material.dart';
import 'package:storyapp/data/db/story_repository.dart';
import 'package:storyapp/data/model/detail_story_response.dart';
import 'package:storyapp/util/detail_story_state.dart';
import 'package:storyapp/util/stories_state.dart';

class StoryProvider extends ChangeNotifier {
  final StoryRepository storyRepository;

  StoryProvider({required this.storyRepository});

  StoriesState _storyState = NoneState();
  StoriesState get storyState => _storyState;

  DetailStoryState _detailState = DetailNoneState();
  DetailStoryState get detailState => _detailState;

  List<Story> _loadedStories = [];
  List<Story> get loadedStories => _loadedStories;

  int? pageItems = 1;
  int sizeItems = 10;

  Future<void> getStories({bool reset = false}) async {
    try {
      if (reset) {
        _loadedStories = [];
        pageItems = 1;
        _storyState = LoadingState();
        notifyListeners();
      }

      if (pageItems == 1) {
        _storyState = LoadingState();
        notifyListeners();
      }

      final stories = await storyRepository.getStories(pageItems!, sizeItems);

      if (stories.error) {
        _storyState = ErrorState(stories.message);
      } else {
        if (pageItems == 1) {
          _loadedStories = List.from(stories.listStory);
        } else {
          _loadedStories = List.from(_loadedStories)..addAll(stories.listStory);
        }

        if (stories.listStory.length < sizeItems) {
          pageItems = null;
        } else {
          pageItems = pageItems! + 1;
        }

        _storyState = LoadedState(_loadedStories);
        notifyListeners();
      }
    } on Exception catch (e) {
      _storyState = ErrorState(e.toString());
    } finally {
      notifyListeners();
    }
  }

  Future<void> getDetailStory(String id) async {
    try {
      _detailState = DetailLoadingState();
      notifyListeners();

      final detail = await storyRepository.getDetailStory(id);

      if (detail.error) {
        _detailState = DetailErrorState(detail.message);
      } else {
        _detailState = DetailLoadedState(detail.story);
      }
    } on Exception catch (e) {
      _detailState = DetailErrorState(e.toString());
    } finally {
      notifyListeners();
    }
  }
}
