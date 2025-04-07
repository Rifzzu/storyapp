import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:storyapp/provider/add_story_provider.dart';
import 'package:storyapp/routes/page_manager.dart';
import 'package:storyapp/common.dart';

class AddStoryScreen extends StatefulWidget {
  final Function onPost;

  const AddStoryScreen({super.key, required this.onPost});
  @override
  State<AddStoryScreen> createState() => _AddStoryScreenState();
}

class _AddStoryScreenState extends State<AddStoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

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
                    ElevatedButton(
                      onPressed: () => _onGalleryView(),
                      child: Text(AppLocalizations.of(context)!.galleryBtn),
                    ),
                    ElevatedButton(
                      onPressed: () => _onCameraView(),
                      child: Text(AppLocalizations.of(context)!.cameraBtn),
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
              ElevatedButton(
                onPressed: () {
                  _onUpload();
                },
                child: Text(AppLocalizations.of(context)!.uploadBtn),
              ),
            ],
          ),
        ),
      ),
    );
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

  _onUpload() async {
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
      final fileName = imageFile.name;
      final bytes = await imageFile.readAsBytes();
      final newBytes = await addStoryProvider.compressImage(bytes);
      await addStoryProvider.addStory(newBytes, fileName, description);

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
}
