import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/component/flag_icon_widget.dart';
import 'package:storyapp/component/message_widget.dart';
import 'package:storyapp/component/list_stories_item.dart';
import 'package:storyapp/provider/auth_provider.dart';
import 'package:storyapp/provider/story_provider.dart';
import 'package:storyapp/provider/theme_provider.dart';
import 'package:storyapp/routes/page_manager.dart';
import 'package:storyapp/util/stories_state.dart';
import 'package:storyapp/common.dart';

class HomeScreen extends StatefulWidget {
  final Function() onLogout;
  final Function(String) onDetail;
  final Function() onAddStory;

  const HomeScreen({
    super.key,
    required this.onLogout,
    required this.onDetail,
    required this.onAddStory,
  });
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    final storiesProvider = context.read<StoryProvider>();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        storiesProvider.getStories();
      }
    });

    Future.microtask(() async => storiesProvider.getStories());
  }

  Future<void> _refreshStories(BuildContext context) async {
    await context.read<StoryProvider>().getStories(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleAppBar),
        actions: [
          FlagIconWidget(),
          IconButton(
            onPressed: () async {
              final themeProvider = context.read<ThemeProvider>();
              await themeProvider.toggleTheme();
            },
            icon: Icon(_themeModeIcon()),
          ),
          IconButton(
            onPressed: () async {
              final result = await context.read<AuthProvider>().logout();
              if (result) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.snackBarLogoutSuccess,
                    ),
                  ),
                );
                widget.onLogout();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.snackBarLogoutFailure,
                    ),
                  ),
                );
              }
            },
            icon:
                context.watch<AuthProvider>().isLoadingLogout
                    ? const CircularProgressIndicator()
                    : const Icon(Icons.logout),
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: _homeState(refreshStories: () => _refreshStories(context)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final pageManager = context.read<PageManager>();
          widget.onAddStory();
          final onRefresh = await pageManager.waitForResult();
          if (onRefresh) {
            _refreshKey.currentState?.show();
          }
        },
        label: Text(AppLocalizations.of(context)!.fabTitle),
        icon: Icon(Icons.add_a_photo_outlined),
      ),
    );
  }

  IconData _themeModeIcon() {
    final themeProvider = context.read<ThemeProvider>();
    return themeProvider.themeMode == ThemeMode.dark
        ? Icons.dark_mode
        : Icons.light_mode;
  }

  _homeState({required Future<void> Function() refreshStories}) {
    return Consumer<StoryProvider>(
      builder: (context, value, _) {
        return RefreshIndicator(
          key: _refreshKey,
          onRefresh: refreshStories,
          child: switch (value.storyState) {
            LoadingState() => const Center(child: CircularProgressIndicator()),
            LoadedState(data: var _) => ListView.builder(
              controller: _scrollController,
              itemCount:
                  value.loadedStories.length +
                  (value.pageItems != null ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == value.loadedStories.length &&
                    value.pageItems != null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final stories = value.loadedStories[index];
                return ListStoriesItem(
                  name: stories.name,
                  desc: stories.description,
                  photoUrl: stories.photoUrl,
                  dateTimeCreated: stories.createdAt,
                  onTapped: () => widget.onDetail(stories.id),
                );
              },
            ),
            ErrorState() => Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    MessageWidget(
                      title: AppLocalizations.of(context)!.messageWidgetTitle,
                      subtitle:
                          AppLocalizations.of(context)!.messageWidgetSubtitle,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _refreshStories(context);
                      },
                      child: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            ),
            _ => const SizedBox(),
          },
        );
      },
    );
  }
}
