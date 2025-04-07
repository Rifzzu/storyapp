import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/common.dart';
import 'package:storyapp/component/message_widget.dart';
import 'package:storyapp/provider/story_provider.dart';
import 'package:storyapp/screen/detail/body_detail_widget.dart';
import 'package:storyapp/util/detail_story_state.dart';

class DetailScreen extends StatefulWidget {
  final String storyId;

  const DetailScreen({super.key, required this.storyId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<StoryProvider>().getDetailStory(widget.storyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail Story')),
      body: Consumer<StoryProvider>(
        builder: (context, value, child) {
          return switch (value.detailState) {
            DetailLoadingState() => const Center(
              child: CircularProgressIndicator(),
            ),
            DetailLoadedState(data: var storyDetail) => BodyDetailWidget(
              story: storyDetail,
            ),
            DetailErrorState() => Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: MessageWidget(
                  title: AppLocalizations.of(context)!.messageWidgetTitle,
                  subtitle: AppLocalizations.of(context)!.messageWidgetSubtitle,
                ),
              ),
            ),
            _ => const SizedBox(),
          };
        },
      ),
    );
  }
}
