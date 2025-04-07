import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storyapp/component/expandable_text_row.dart';

class ListStoriesItem extends StatelessWidget {
  final String name;
  final String desc;
  final String photoUrl;
  final DateTime dateTimeCreated;
  final Function() onTapped;

  const ListStoriesItem({
    super.key,
    required this.name,
    required this.desc,
    required this.photoUrl,
    required this.dateTimeCreated,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTapped();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage(photoUrl),
                ),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              photoUrl,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpandableTextRow(name: name, desc: desc),
                Text(
                  _timeAgo(dateTimeCreated),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    Duration diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return "${diff.inSeconds}s ago";
    if (diff.inMinutes < 60) return "${diff.inMinutes}m ago";
    if (diff.inHours < 24) return "${diff.inHours}h ago";
    return DateFormat('MMM d, yyyy').format(date);
  }
}
