import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:storyapp/routes/location_manager.dart';

class MapsOnPickScreen extends StatefulWidget {
  final LatLng? latLng;
  final Function(LatLng latLng) onChooseMap;

  const MapsOnPickScreen({super.key, this.latLng, required this.onChooseMap});

  @override
  State<MapsOnPickScreen> createState() => _MapsPickLocationState();
}

class _MapsPickLocationState extends State<MapsOnPickScreen> {
  late LatLng storyLocation;
  LatLng? _onPickLatLong;
  late GoogleMapController mapController;
  late final Set<Marker> markers = {};
  geo.Placemark? placemark;

  @override
  void initState() {
    storyLocation = LatLng(
      widget.latLng?.latitude ?? -6.8957473,
      widget.latLng?.longitude ?? 107.6337669,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Location')),
      body: Center(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                zoom: 18,
                target: storyLocation,
              ),
              markers: markers,
              mapToolbarEnabled: false,
              myLocationButtonEnabled: false,
              myLocationEnabled: true,
              onMapCreated: (controller) async {
                final info = await geo.placemarkFromCoordinates(
                  storyLocation.latitude,
                  storyLocation.longitude,
                );
                final place = info[0];
                final street = place.street!;
                final address =
                    '${place.subLocality}, '
                    '${place.locality}, '
                    '${place.postalCode}, '
                    '${place.country}';
                setState(() {
                  placemark = place;
                });

                defineMarker(storyLocation, street, address);

                setState(() {
                  mapController = controller;
                });
              },
              onLongPress: (LatLng latLng) => onLongPressGoogleMap(latLng),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton(
                child: const Icon(Icons.my_location),
                onPressed: () => onMyLocationButtonPress(),
              ),
            ),
            if (placemark == null)
              const SizedBox()
            else
              Positioned(
                bottom: 16,
                right: 16,
                left: 16,
                child: PlacemarkWidget(
                  placemark: placemark!,
                  onChoose: () => _onChooseLocation(context),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _onChooseLocation(BuildContext context) async {
    if (_onPickLatLong != null) {
      widget.onChooseMap(_onPickLatLong!);
      context.read<LocationManager>().returnData(_onPickLatLong!);
    }
  }

  void onMyLocationButtonPress() async {
    final Location location = Location();
    late LocationData locationData;

    locationData = await location.getLocation();
    final latLng = LatLng(locationData.latitude!, locationData.longitude!);

    final info = await geo.placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );

    final place = info[0];
    final street = place.street;
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {
      placemark = place;
    });

    defineMarker(latLng, street, address);

    mapController.animateCamera(CameraUpdate.newLatLng(latLng));
  }

  void defineMarker(LatLng latLng, String? street, String? address) {
    final marker = Marker(
      markerId: const MarkerId("source"),
      position: latLng,
      infoWindow: InfoWindow(title: street, snippet: address),
    );

    setState(() {
      markers.clear();
      markers.add(marker);
    });
  }

  void onLongPressGoogleMap(LatLng latLng) async {
    final info = await geo.placemarkFromCoordinates(
      latLng.latitude,
      latLng.longitude,
    );
    final place = info[0];
    final street = place.street!;
    final address =
        '${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';
    setState(() {
      placemark = place;
      _onPickLatLong = latLng;
    });
    defineMarker(latLng, street, address);

    mapController.animateCamera(CameraUpdate.newLatLng(latLng));
  }
}

class PlacemarkWidget extends StatelessWidget {
  final geo.Placemark placemark;
  final VoidCallback onChoose;

  const PlacemarkWidget({
    super.key,
    required this.placemark,
    required this.onChoose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 40),
      constraints: const BoxConstraints(maxWidth: 700),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            blurRadius: 20,
            offset: Offset.zero,
            color: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      placemark.street!,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${placemark.subLocality}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onChoose,
            child: const Text("Select this location."),
          ),
        ],
      ),
    );
  }
}
