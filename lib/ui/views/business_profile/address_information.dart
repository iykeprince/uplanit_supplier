import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:search_map_place/search_map_place.dart';
import 'package:uplanit_supplier/core/models/address_response.dart';
import 'package:uplanit_supplier/core/models/country.dart';
import 'package:uplanit_supplier/core/utils/constants.dart';
import 'package:uplanit_supplier/core/utils/helpers.dart';
import 'package:uplanit_supplier/core/utils/locator.dart';
import 'package:uplanit_supplier/ui/shared/custom_colors.dart';
import 'package:uplanit_supplier/ui/views/business_profile/viewmodels/address_model.dart';
import 'package:uplanit_supplier/ui/widgets/custom_textfield.dart';
import 'package:uplanit_supplier/core/models/base_profile.dart';

import 'widgets/round_edit_button.dart';

class AddressInformationView extends StatefulWidget {
  final bool isEditMode;

  AddressInformationView({
    Key key,
    this.isEditMode,
  }) : super(key: key);

  @override
  _AddressInformationViewState createState() => _AddressInformationViewState();
}

class _AddressInformationViewState extends State<AddressInformationView> {
  static const LatLng center = const LatLng(51.568747, 0.420410);

  Location location = new Location();
  bool _serviceEnabled = false;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  Completer<GoogleMapController> _controller = Completer();

  Set<Marker> _markers = HashSet<Marker>();
  Set<Circle> _circles = HashSet<Circle>();
  Set<Polygon> _polygons = HashSet<Polygon>();
  List<LatLng> _polygonLatLngs = List<LatLng>();
  double radius;

  void _checkLocationPermission() async {
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    _locationData = await location.getLocation();
  }

  AddressModel addressModel = locator<AddressModel>();
  bool _dispose = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    print('initstate called Address');
    _checkLocationPermission();
    if (addressModel.baseAddress != null) {
      addressModel.googleController.moveCamera(
        CameraUpdate.newLatLng(
          LatLng(
            addressModel.baseAddress.location.y,
            addressModel.baseAddress.location.x,
          ),
        ),
      );
      if (addressModel.baseAddress.showMarker.toLowerCase() == 'true') {
        addressModel.setShowMarker(
            addressModel.baseAddress.showMarker.toLowerCase() == 'true'
                ? true
                : false);

        addressModel.setMarker(
          LatLng(
            addressModel.baseAddress.location.y,
            addressModel.baseAddress.location.x,
          ),
        );
      } else {
        addressModel.setCircles(
          LatLng(
            addressModel.baseAddress.location.y,
            addressModel.baseAddress.location.x,
          ),
        );

        if (addressModel.baseDeliveryBounds != null) {
          //Bounds
          double north = addressModel.baseAddress.location.y + 0.09;
          double south = addressModel.baseAddress.location.y - 0.09;
          double east = addressModel.baseAddress.location.x + 0.09;
          double west = addressModel.baseAddress.location.x - 0.09;
          List<LatLng> points = List<LatLng>();
          points.add(LatLng(north, east));
          points.add(LatLng(south, west));

          addressModel.setPolygon(points);
          // --Bounds
        }
      }
    }
  }

  dispose() {
    _dispose = true;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    return ChangeNotifierProvider(
      create: (_) => locator<AddressModel>(),
      child: Consumer<AddressModel>(builder: (context, model, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 8,
                bottom: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Address',
                    style: GoogleFonts.workSans(
                      fontSize: 16.0,
                      color: Color(0xFF757575),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  model.isEditMode
                      ? Row(
                          children: [
                            RaisedButton(
                              color: CustomColor.primaryColor,
                              onPressed: () async {
                                CustomHelper.dismissKeyboard(context);
                                model.setLoading(true);

                                AddressResponse addressResponse =
                                    await model.updateAddress();
                                if (addressResponse == null) {
                                  print('address response: $addressResponse');
                                  model.setLoading(false);
                                  return;
                                }

                                // model.setAddress(baseProfile.address);
                                // model.setDeliveryBounds(
                                //     baseProfile.deliveryBounds);
                                model.setLoading(false);
                                model.toggleMode();
                              },
                              child: Row(
                                children: [
                                  model.loading
                                      ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Update',
                                          style: GoogleFonts.workSans(
                                            color: Colors.white,
                                            fontSize: 12.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                ],
                              ),
                            ),
                            RaisedButton(
                              onPressed: model.toggleMode,
                              child: Container(
                                color: Colors.grey.shade300,
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  'Back',
                                  style: GoogleFonts.workSans(
                                    color: Colors.black,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : RoundEditButton(
                          onTap: () {
                            model.toggleMode();
                            model.fetchCountries();
                          },
                        ),
                ],
              ),
            ),
            Divider(
              thickness: 2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 8,
                bottom: 4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      model.errorMessage != null
                          ? Text(
                              model.errorMessage,
                              style: GoogleFonts.workSans(
                                fontSize: 16.0,
                                color: CustomColor.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Container(),
                      Text(
                        'Address',
                        style: GoogleFonts.workSans(
                          fontSize: 16.0,
                          color: CustomColor.uplanitBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      !model.isEditMode
                          ? Text(
                              '${model.baseAddress == null ? 'No Address' : model.baseAddress.street}',
                              style: GoogleFonts.workSans(
                                fontSize: 14.0,
                                color: Color(0xFF757575),
                                fontWeight: FontWeight.normal,
                              ),
                            )
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              child: !_dispose
                                  ? _searchPlaceWidget()
                                  : Container(),
                            ),
                    ],
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              'Apt, Suite',
                              style: GoogleFonts.workSans(
                                fontSize: 14.0,
                                color: CustomColor.uplanitBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            !model.isEditMode
                                ? Text(
                                    model.baseAddress != null
                                        ? model.baseAddress.number
                                        : 'No Apt, suite',
                                    style: GoogleFonts.workSans(
                                      fontSize: 14.0,
                                      color: Color(0xFF757575),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Container(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    height: 24,
                                    child: CustomTextField(
                                      controller: model.numberController,
                                      value: model.numberController.text,
                                      color: Colors.black,
                                      keyboardType: TextInputType.text,
                                      fontSize: 14,
                                    ),
                                  ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              'Post Code',
                              style: GoogleFonts.workSans(
                                fontSize: 14.0,
                                color: CustomColor.uplanitBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            !model.isEditMode
                                ? Text(
                                    model.baseAddress != null
                                        ? model.baseAddress.postCode
                                        : 'No postCode',
                                    style: GoogleFonts.workSans(
                                      fontSize: 14.0,
                                      color: Color(0xFF757575),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Container(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    height: 40,
                                    child: CustomTextField(
                                      controller: model.postCodeController,
                                      value: model.postCodeController.text,
                                      color: Colors.black,
                                      keyboardType: TextInputType.text,
                                      fontSize: 14,
                                    ),
                                  ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              'Country',
                              style: GoogleFonts.workSans(
                                fontSize: 14.0,
                                color: CustomColor.uplanitBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            !model.isEditMode
                                ? Text(
                                    model.baseAddress != null &&
                                            model.baseAddress.country != null
                                        ? model.baseAddress.country.name
                                        : '',
                                    style: GoogleFonts.workSans(
                                      fontSize: 14.0,
                                      color: Color(0xFF757575),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Container(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    height: 60,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        DropdownButton(
                                          value: model.country,
                                          items: model.countries.length > 0
                                              ? _buildDropdownMenuItem(
                                                  model.countries)
                                              : [],
                                          onChanged: (value) {
                                            model.setCountryValue(value);
                                          },
                                        ),
                                        model.isCountryLoading
                                            ? LinearProgressIndicator()
                                            : Container(),
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              'Street',
                              style: GoogleFonts.workSans(
                                fontSize: 16.0,
                                color: CustomColor.uplanitBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            !model.isEditMode
                                ? Text(
                                    model.baseAddress != null
                                        ? model.baseAddress.street
                                        : 'No street',
                                    style: GoogleFonts.workSans(
                                      fontSize: 14.0,
                                      color: Color(0xFF757575),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Container(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    height: 24,
                                    child: CustomTextField(
                                      value: model.streetController.text,
                                      controller: model.streetController,
                                      color: Colors.black,
                                      keyboardType: TextInputType.text,
                                      fontSize: 14,
                                    ),
                                  ),
                            SizedBox(
                              height: 16,
                            ),
                            Text(
                              'City',
                              style: GoogleFonts.workSans(
                                fontSize: 14.0,
                                color: CustomColor.uplanitBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            !model.isEditMode
                                ? Text(
                                    model.baseAddress != null
                                        ? model.baseAddress.city
                                        : 'No city',
                                    style: GoogleFonts.workSans(
                                      fontSize: 14.0,
                                      color: Color(0xFF757575),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Container(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    height: 40,
                                    child: CustomTextField(
                                      controller: model.cityController,
                                      value: model.cityController.text,
                                      color: Colors.black,
                                      keyboardType: TextInputType.text,
                                      fontSize: 14,
                                    ),
                                  ),
                            SizedBox(height: 16),
                            Text(
                              'Show Marker',
                              style: GoogleFonts.workSans(
                                fontSize: 14.0,
                                color: CustomColor.uplanitBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            !model.isEditMode
                                ? Text(
                                    model.baseAddress != null
                                        ? model.baseAddress.showMarker
                                        : '',
                                    style: GoogleFonts.workSans(
                                      fontSize: 14.0,
                                      color: Color(0xFF757575),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  )
                                : Container(
                                    width:
                                        MediaQuery.of(context).size.width * .5,
                                    height: 40,
                                    child: _buildRadioButton(),
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 200,
                    child: InkWell(
                      child: GoogleMap(
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                          controller.moveCamera(CameraUpdate.newLatLng(center));
                          model.setLatLng(center.latitude, center.longitude);
                          model.setGoogleMapController(controller);

                          if (model.baseDeliveryBounds != null) {
                            print(
                                'base deliveryBounds available ${model.baseAddress.location.y}, ${model.baseAddress.location.x}');
                            model.setMarker(LatLng(model.baseAddress.location.y,
                                model.baseAddress.location.x));

                            print(
                                'north bound: ${model.baseDeliveryBounds.north}');
                            print(
                                'south bound: ${model.baseDeliveryBounds.south}');
                            print(
                                'east bound: ${model.baseDeliveryBounds.east}');
                            print(
                                'west bound: ${model.baseDeliveryBounds.west}');
                            _polygonLatLngs.add(LatLng(
                                model.baseDeliveryBounds.north,
                                model.baseDeliveryBounds.west));
                            _polygonLatLngs.add(
                              LatLng(model.baseDeliveryBounds.north,
                                  model.baseDeliveryBounds.east),
                            );
                            _polygonLatLngs.add(
                              LatLng(model.baseDeliveryBounds.south,
                                  model.baseDeliveryBounds.east),
                            );
                            _polygonLatLngs.add(LatLng(
                                model.baseDeliveryBounds.south,
                                model.baseDeliveryBounds.west));
                            model.setPolygon(_polygonLatLngs);
                          }
                        },
                        initialCameraPosition: CameraPosition(
                          target: center,
                          zoom: 16.0,
                        ),
                        mapType: MapType.normal,
                        markers: model.markers,
                        circles: model.circles,
                        polygons: model.polygons,
                        myLocationEnabled: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  List<DropdownMenuItem> _buildDropdownMenuItem(List<Country> countries) {
    List<DropdownMenuItem> _dropdownMenuItemList = [];
    countries.forEach(
      (country) {
        _dropdownMenuItemList.add(
          DropdownMenuItem(
            child: Text(country.name,
                style: GoogleFonts.workSans(
                  fontSize: 13,
                )),
            value: country,
          ),
        );
      },
    );
    return _dropdownMenuItemList;
  }

  _buildRadioButton() {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      Text('Yes'),
      Radio(
        value: true,
        groupValue: addressModel.showMarker,
        activeColor: CustomColor.primaryColor,
        onChanged: onRadioChanged,
      ),
      Text('No'),
      Radio(
        value: false,
        groupValue: addressModel.showMarker,
        activeColor: CustomColor.primaryColor,
        onChanged: onRadioChanged,
      ),
    ]);
  }

  onRadioChanged(bool value) {
    print('radio value onchanged: $value');
    addressModel.setShowMarker(value);
    double lat = addressModel.lat;
    double lng = addressModel.lng;
    print('lat: $lat/lng: $lng');
    if (value) {
      //show marker, hide circle
      addressModel.setMarker(LatLng(lat, lng));
      addressModel.circles.clear();
    } else {
      //hide marker, show circle
      addressModel.setCircles(LatLng(lat, lng));
      addressModel.markers.clear();
    }
  }

  _searchPlaceWidget() {
    return SearchMapPlaceWidget(
      apiKey: GOOGLE_MAP_API_KEY,

      language: 'en',
      // The position used to give better recomendations. In this case we are using the user position
      location: center,
      radius: 30000,
      onSelected: (Place place) async {
        Geolocation geolocation = await place.geolocation;
        if (geolocation == null) return;
        // Will animate the GoogleMap camera, taking us to the selected position with an appropriate zoom

        print('geolocation: ${geolocation.coordinates}');
        LatLng coordinate = geolocation.coordinates;

        List<geo.Placemark> placemarks = await geo.placemarkFromCoordinates(
          coordinate.latitude,
          coordinate.longitude,
        );
        if (placemarks != null && placemarks.length > 0) {
          geo.Placemark placemark = placemarks[0];

          addressModel.setFields(placemark);
          addressModel.setLatLng(
            coordinate.latitude,
            coordinate.longitude,
          );

          addressModel.googleController.moveCamera(
            CameraUpdate.newLatLng(
              LatLng(
                coordinate.latitude,
                coordinate.longitude,
              ),
            ),
          );

          if (addressModel.showMarker != null && addressModel.showMarker)
            addressModel.setMarker(
              LatLng(
                coordinate.latitude,
                coordinate.longitude,
              ),
            );
          else
            addressModel.setCircles(
              LatLng(
                coordinate.latitude,
                coordinate.longitude,
              ),
            );
          //Bounds
          double north = coordinate.latitude + 0.09;
          double south = coordinate.latitude - 0.09;
          double east = coordinate.longitude + 0.09;
          double west = coordinate.longitude - 0.09;
          List<LatLng> points = List<LatLng>();
          points.add(LatLng(north, east));
          points.add(LatLng(south, west));

          addressModel.setPolygon(points);
          // --Bounds
        }
      },
    );
  }
}
