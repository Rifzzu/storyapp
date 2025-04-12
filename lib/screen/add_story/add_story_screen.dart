import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import 'package:storyapp/provider/add_story_provider.dart';
import 'package:storyapp/routes/location_manager.dart';
import 'package:storyapp/routes/page_manager.dart';
import 'package:storyapp/common.dart';

class AddStoryScreen extends StatefulWidget {
  final Function onPost;
  final Function(LatLng latLng) onChooseLocation;

  const AddStoryScreen({
    super.key,
    required this.onPost,
    required this.onChooseLocation,
  });
  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  double? latLocation;
  double? lonLocation;
  String? _locationOption;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.titleAppBarAddStory),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 300,
                width: 300,
                child:
                    context.watch<AddStoryProvider>().imagePath == null
                        ? const Align(
                          alignment: Alignment.center,
                          child: Icon(Icons.image, size: 100),
                        )
                        : _showImage(),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _onGalleryView(),
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(AppLocalizations.of(context)!.galleryBtn),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _onCameraView(),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(AppLocalizations.of(context)!.cameraBtn),
                    ),
                  ],
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.addCaptionForm,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return AppLocalizations.of(context)!.noDescription;
                      } else {
                        return null;
                      }
                    },
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _currentLocation();
                    },
                    icon: const Icon(Icons.my_location_outlined),
                    label: const Text('Current location'),
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(
                        color:
                            _locationOption == "currentLocation"
                                ? Colors.green
                                : Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      _locationFromMap(context);
                    },
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Choose on map'),
                    style: ElevatedButton.styleFrom(
                      side: BorderSide(
                        color:
                            _locationOption == "mapLocation"
                                ? Colors.green
                                : Theme.of(context).colorScheme.surface,
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _onUpload();
                },
                icon: const Icon(Icons.upload),
                label: Text(AppLocalizations.of(context)!.uploadBtn),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _currentLocation() async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selected current location, please wait...")),
      );
    }

    final latLon = await _initLocation();

    if (latLon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to get current location.")),
      );
      return;
    }

    setState(() {
      latLocation = latLon.latitude;
      lonLocation = latLon.longitude;
      _locationOption = "currentLocation";
    });
  }

  void _locationFromMap(BuildContext context) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Selected location from maps, please wait...")),
      );
    }

    final latLon = await _initLocation();

    if (latLon == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to get location from maps.")),
        );
      }
      return;
    }

    widget.onChooseLocation(LatLng(latLon.latitude, latLon.longitude));

    final result = await context.read<LocationManager>().waitForResult();

    setState(() {
      latLocation = result.latitude;
      lonLocation = result.longitude;
      _locationOption = "mapLocation";
    });
  }

  Future<void> _onUpload() async {
    final ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(
      context,
    );
    final addStoryProvider = context.read<AddStoryProvider>();
    final imagePath = addStoryProvider.imagePath;
    final imageFile = addStoryProvider.imageFile;
    final description = _descriptionController.text.trim();

    if (imagePath == null || imageFile == null) {
      scaffoldMessengerState.showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noImageSelected)),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      await Future.delayed(const Duration(seconds: 1));

      final fileName = imageFile.name;
      final bytes = await imageFile.readAsBytes();
      final newBytes = await addStoryProvider.compressImage(bytes);
      await addStoryProvider.addStory(
        newBytes,
        fileName,
        description,
        lat: latLocation,
        lon: lonLocation,
      );

      if (addStoryProvider.uploadResponse != null) {
        addStoryProvider.setImageFile(null);
        addStoryProvider.setImagePath(null);

        scaffoldMessengerState.showSnackBar(
          SnackBar(content: Text(addStoryProvider.message)),
        );
        context.read<PageManager>().returnData(true);
        widget.onPost();
      }
      return;
    }
  }

  Future<LatLng?> _initLocation() async {
    final Location location = Location();
    late bool serviceEnabled;
    late PermissionStatus permissionGranted;
    late LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print("Location services is not available");
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print("Location permission is denied");
        return null;
      }
    }

    locationData = await location.getLocation();
    final latLng = LatLng(locationData.latitude!, locationData.longitude!);
    return latLng;
  }

  _onGalleryView() async {
    final provider = context.read<AddStoryProvider>();

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    if (isMacOS || isLinux) return;

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCameraView() async {
    final provider = context.read<AddStoryProvider>();

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  Widget _showImage() {
    final imagePath = context.read<AddStoryProvider>().imagePath;
    return kIsWeb
        ? Image.network(imagePath.toString(), fit: BoxFit.contain)
        : Image.file(File(imagePath.toString()), fit: BoxFit.contain);
  }
}
