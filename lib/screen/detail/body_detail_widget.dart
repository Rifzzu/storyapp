import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storyapp/data/model/detail_story_response.dart';

class BodyDetailWidget extends StatelessWidget {
  final Story story;

  const BodyDetailWidget({super.key, required this.story});

  @override
  Widget build(BuildContext context) {
    String createdAtString = story.createdAt.toString();
    DateTime createdAt = DateTime.parse(createdAtString).toLocal();
    String formattedDate = DateFormat(
      'MMMM d, yyyy - hh:mm a',
    ).format(createdAt);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Hero(
              tag: story.id,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  story.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Center(child: Icon(Icons.error));
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(story.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(
                  story.description,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                Text(
                  'Created at: $formattedDate',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
