import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/common.dart';
import 'package:storyapp/component/message_widget.dart';
import 'package:storyapp/data/model/story_response.dart';
import 'package:storyapp/provider/story_provider.dart';
import 'package:storyapp/util/detail_story_state.dart';

class DetailScreen extends StatefulWidget {
  final String storyId;
  final Function(LatLng latLng) toStoryMap;

  const DetailScreen({
    super.key,
    required this.storyId,
    required this.toStoryMap,
  });

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
            DetailLoadedState(data: var storyDetail) => _bodyDetailWidget(
              storyDetail,
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

  Widget _bodyDetailWidget(Story story) {
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

          if (story.lat != null && story.lon != null) _mapsWidget(story),
        ],
      ),
    );
  }

  Container _mapsWidget(Story story) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.map_outlined),
              Text(
                " Story Location",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(story.lat!, story.lon!),
                  zoom: 10,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('storyMarker'),
                    position: LatLng(story.lat!, story.lon!),
                    infoWindow: const InfoWindow(title: 'Story Location'),
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                myLocationButtonEnabled: false,
                myLocationEnabled: true,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              if (story.lat != null && story.lon != null) {
                widget.toStoryMap(LatLng(story.lat!, story.lon!));
              }
              return;
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            child: Text("View Story Location", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
