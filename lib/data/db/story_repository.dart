import 'package:storyapp/data/api/api_service.dart';
import 'package:storyapp/data/model/detail_story_response.dart';
import 'package:storyapp/data/model/stories_response.dart';

class StoryRepository {
  final ApiService apiService;

  StoryRepository({required this.apiService});

  Future<StoriesResponse> getStories(int? pageItems, int sizeItem) async {
    return await apiService.getStories(pageItems!, sizeItem);
  }

  Future<DetailStoryResponse> getDetailStory(String storyId) async {
    return await apiService.getDetailStory(storyId);
  }
}
