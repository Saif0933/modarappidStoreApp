import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../shared/providers/products_provider.dart';
import '../../data/services/ola_maps_service.dart';

class AddAddressPage extends ConsumerStatefulWidget {
  const AddAddressPage({super.key});

  @override
  ConsumerState<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends ConsumerState<AddAddressPage> {
  GoogleMapController? _mapController;
  // Default to Bengaluru (Indiranagar / Domlur area matching screenshot)
  LatLng _mapCenter = const LatLng(12.9698, 77.6415);

  bool _isLocating = false;

  final _formKey = GlobalKey<FormState>();

  // Text Controllers matching the screenshot exactly
  final _searchController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController(text: 'Bengaluru');
  final _stateController = TextEditingController(text: 'Karnataka');
  final _pincodeController = TextEditingController();
  final _instructionsController = TextEditingController();

  // Address Type (Home, Work, Other)
  String _selectedAddressType = 'Home';

  // Autocomplete suggestions
  List<OlaPlacePrediction> _placeSuggestions = [];
  bool _isSearchingPlaces = false;
  Timer? _searchDebounce;

  static const List<String> _commonCities = [
    'Bengaluru',
    'Mumbai',
    'Delhi',
    'Hyderabad',
    'Chennai',
    'Kolkata',
    'Pune',
    'Ahmedabad',
    'Jaipur',
    'Noida',
    'Gurugram',
    'Lucknow',
    'Chandigarh',
    'Indore',
    'Kochi',
    'Coimbatore',
    'Bhopal',
    'Nagpur',
    'Surat',
    'Mysuru',
  ];

  static const List<String> _indianStates = [
    'Karnataka',
    'Maharashtra',
    'Delhi',
    'Tamil Nadu',
    'Telangana',
    'Uttar Pradesh',
    'Gujarat',
    'West Bengal',
    'Rajasthan',
    'Kerala',
    'Haryana',
    'Madhya Pradesh',
    'Punjab',
    'Bihar',
    'Odisha',
    'Andhra Pradesh',
    'Assam',
    'Goa',
    'Himachal Pradesh',
    'Uttarakhand',
    'Jharkhand',
    'Chhattisgarh',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCurrentGPSLocation(isInitial: true);
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _mapController?.dispose();
    _searchController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  /// High-accuracy GPS location fetch using Geolocator
  Future<void> _fetchCurrentGPSLocation({bool isInitial = false}) async {
    if (!mounted) return;
    setState(() => _isLocating = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!isInitial && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.location_off_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Expanded(child: Text('Location services are turned off. Please turn on GPS.')),
                ],
              ),
              backgroundColor: Colors.deepOrange,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => Geolocator.openLocationSettings(),
              ),
            ),
          );
        }
        setState(() => _isLocating = false);
        if (isInitial) _fetchAddressFromOlaMaps(_mapCenter);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (!isInitial && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location permission denied. Please allow location access.'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          setState(() => _isLocating = false);
          if (isInitial) _fetchAddressFromOlaMaps(_mapCenter);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (!isInitial && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location permissions are permanently denied. Please enable in Settings.'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Settings',
                textColor: Colors.white,
                onPressed: () => Geolocator.openAppSettings(),
              ),
            ),
          );
        }
        setState(() => _isLocating = false);
        if (isInitial) _fetchAddressFromOlaMaps(_mapCenter);
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 8),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        final currentLatLng = LatLng(position.latitude, position.longitude);

        if (mounted) {
          setState(() {
            _mapCenter = currentLatLng;
            _isLocating = false;
          });

          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: currentLatLng, zoom: 16.5),
            ),
          );

          await _fetchAddressFromOlaMaps(currentLatLng);
        }
      } else {
        setState(() => _isLocating = false);
        if (isInitial) _fetchAddressFromOlaMaps(_mapCenter);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLocating = false);
        if (!isInitial) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to fetch GPS location: $e'),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  /// Calls Ola Maps reverse geocoding and auto-fills fields
  Future<void> _fetchAddressFromOlaMaps(LatLng target) async {
    final result = await OlaMapsService.reverseGeocode(
      latitude: target.latitude,
      longitude: target.longitude,
    );

    if (!mounted) return;
    setState(() {
      // Auto-fill fields from detected location
      if (result.addressLine1.isNotEmpty) {
        _addressLine1Controller.text = result.addressLine1;
      }
      if (result.locality.isNotEmpty || result.addressLine2.isNotEmpty) {
        _addressLine2Controller.text = result.locality.isNotEmpty ? result.locality : result.addressLine2;
      }
      if (result.city.isNotEmpty) {
        _cityController.text = result.city;
      }
      if (result.state.isNotEmpty) {
        _stateController.text = result.state;
      }
      if (result.pincode.isNotEmpty) {
        _pincodeController.text = result.pincode;
      }
    });
  }

  /// Search places with Ola Maps Autocomplete API (Debounced)
  void _onSearchQueryChanged(String query) {
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _placeSuggestions = [];
        _isSearchingPlaces = false;
      });
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (!mounted) return;
      setState(() => _isSearchingPlaces = true);

      final suggestions = await OlaMapsService.searchPlaces(query);

      if (mounted) {
        setState(() {
          _placeSuggestions = suggestions;
          _isSearchingPlaces = false;
        });
      }
    });
  }

  /// User selects a place prediction from search dropdown
  void _selectPlaceSuggestion(OlaPlacePrediction prediction) {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    setState(() => _placeSuggestions = []);

    if (prediction.latitude != null && prediction.longitude != null) {
      final target = LatLng(prediction.latitude!, prediction.longitude!);
      setState(() => _mapCenter = target);
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 16.5),
        ),
      );
      _fetchAddressFromOlaMaps(target);
    } else {
      _addressLine2Controller.text = prediction.description;
      _fetchAddressFromOlaMaps(_mapCenter);
    }
  }

  /// Saves the address
  void _saveAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.mediumImpact();

      final line1 = _addressLine1Controller.text.trim();
      final line2 = _addressLine2Controller.text.trim();
      final fullAddress = line2.isNotEmpty ? '$line1, $line2' : line1;
      final cityPart = '${_cityController.text.trim()}, ${_stateController.text.trim()}${_pincodeController.text.trim().isNotEmpty ? " - ${_pincodeController.text.trim()}" : ""}';
      final instructions = _instructionsController.text.trim();

      final address = Address(
        id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Delivery ($_selectedAddressType)',
        addressLine: instructions.isNotEmpty ? '$fullAddress ($instructions)' : fullAddress,
        city: cityPart,
        phone: '+91 98765 43210',
        isDefault: true,
      );

      ref.read(addressListProvider.notifier).addAddress(address);
      ref.read(selectedAddressProvider.notifier).state = address;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(child: Text('Address saved successfully!')),
            ],
          ),
          backgroundColor: Color(0xFF108A56),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    }
  }

  /// Selection modal for City / State
  void _showSelectionDialog({
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String filter = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = options
                .where((e) => e.toLowerCase().contains(filter.toLowerCase()))
                .toList();
            return Container(
              height: MediaQuery.of(context).size.height * 0.55,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      onChanged: (val) => setModalState(() => filter = val),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                        hintText: 'Search or enter custom...',
                        hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filtered.length + (filter.trim().isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (filter.trim().isNotEmpty && index == 0) {
                          return ListTile(
                            leading: const Icon(Icons.add_circle_outline, color: Color(0xFF108A56)),
                            title: Text('Use "$filter"', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF108A56))),
                            onTap: () {
                              onSelected(filter.trim());
                              Navigator.pop(ctx);
                            },
                          );
                        }
                        final item = filtered[filter.trim().isNotEmpty ? index - 1 : index];
                        final isSelected = item.toLowerCase() == currentValue.toLowerCase();
                        return ListTile(
                          dense: true,
                          title: Text(
                            item,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? const Color(0xFF108A56) : const Color(0xFF1E293B),
                            ),
                          ),
                          trailing: isSelected ? const Icon(Icons.check, color: Color(0xFF108A56), size: 18) : null,
                          onTap: () {
                            onSelected(item);
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Add Delivery Address',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTabletOrDesktop = constraints.maxWidth >= 800;

            if (isTabletOrDesktop) {
              // Side-by-side on wide screens / tablets
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Map
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildMapSection(height: 600),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column: Form Card
                        Expanded(
                          flex: 6,
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Form(
                              key: _formKey,
                              child: _buildAddressDetailsSheet(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Mobile Layout (Exact same as image!)
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  children: [
                    _buildMapSection(height: 330),
                    Transform.translate(
                      offset: const Offset(0, -20),
                      child: _buildAddressDetailsSheet(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Interactive Google Map with Pill Search, Pin with Blue Halo, and Controls
  Widget _buildMapSection({required double height}) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _mapCenter,
              zoom: 13.5,
            ),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
            },
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) => _mapCenter = position.target,
            onCameraIdle: () => _fetchAddressFromOlaMaps(_mapCenter),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
          ),

          // Map Center Pin: Blue halo + Center blue dot + Red Pin directly on top!
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -18),
                  child: const Icon(
                    Icons.location_on,
                    color: Color(0xFFE53935),
                    size: 42,
                    shadows: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Search Bar on Map
          Positioned(
            top: 14,
            left: 16,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSearchBar(),
                if (_placeSuggestions.isNotEmpty || _isSearchingPlaces)
                  _buildSuggestionsDropdown(),
              ],
            ),
          ),

          // Floating My Location Button (Top Right)
          Positioned(
            top: 76,
            right: 16,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 3,
              shadowColor: Colors.black26,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isLocating ? null : _fetchCurrentGPSLocation,
                child: Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  child: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF108A56)),
                        )
                      : const Icon(Icons.my_location_rounded, size: 20, color: Color(0xFF1E293B)),
                ),
              ),
            ),
          ),

          // Floating Zoom Controls (Middle/Bottom Right)
          Positioned(
            top: 130,
            right: 16,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              elevation: 3,
              shadowColor: Colors.black26,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(Icons.add, size: 20, color: Color(0xFF1E293B)),
                    ),
                  ),
                  Container(
                    width: 38,
                    height: 1,
                    color: const Color(0xFFE2E8F0),
                  ),
                  InkWell(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                    onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(Icons.remove, size: 20, color: Color(0xFF1E293B)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Floating Pill Search Bar
  Widget _buildSearchBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchQueryChanged,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
                hintText: 'Search for your address',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
              onPressed: () {
                _searchController.clear();
                setState(() => _placeSuggestions = []);
              },
            ),
        ],
      ),
    );
  }

  /// Ola Maps Autocomplete Suggestions Dropdown
  Widget _buildSuggestionsDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _isSearchingPlaces
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF108A56)),
                    ),
                    SizedBox(width: 10),
                    Text('Searching places...', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _placeSuggestions.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
              itemBuilder: (context, index) {
                final item = _placeSuggestions[index];
                return ListTile(
                  dense: true,
                  leading: const Icon(Icons.location_on_rounded, color: Color(0xFF108A56), size: 18),
                  title: Text(
                    item.mainText,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                  ),
                  subtitle: Text(
                    item.secondaryText.isNotEmpty ? item.secondaryText : item.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  trailing: const Icon(Icons.north_west_rounded, size: 14, color: Colors.grey),
                  onTap: () => _selectPlaceSuggestion(item),
                );
              },
            ),
    );
  }

  /// Address Details Card matching screenshot exactly
  Widget _buildAddressDetailsSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Address Details title
          const Text(
            'Address Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          // 1. House / Flat / Building No. *
          _buildFieldLabel('House / Flat / Building No.', isRequired: true),
          const SizedBox(height: 6),
          _buildTextInput(
            controller: _addressLine1Controller,
            hintText: 'e.g. 101, ABC Apartments',
            icon: Icons.home_rounded,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter house/flat no' : null,
          ),
          const SizedBox(height: 14),

          // 2. Area / Street / Landmark *
          _buildFieldLabel('Area / Street / Landmark', isRequired: true),
          const SizedBox(height: 6),
          _buildTextInput(
            controller: _addressLine2Controller,
            hintText: 'e.g. 12th Main Road, Near Phoenix Mall',
            icon: Icons.location_on_rounded,
            validator: (val) => val == null || val.trim().isEmpty ? 'Please enter area/landmark' : null,
          ),
          const SizedBox(height: 14),

          // 3. Row: City * & State *
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('City', isRequired: true),
                    const SizedBox(height: 6),
                    _buildDropdownInput(
                      controller: _cityController,
                      hintText: 'City',
                      icon: Icons.apartment_rounded,
                      onTap: () => _showSelectionDialog(
                        title: 'Select City',
                        currentValue: _cityController.text,
                        options: _commonCities,
                        onSelected: (val) => setState(() => _cityController.text = val),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('State', isRequired: true),
                    const SizedBox(height: 6),
                    _buildDropdownInput(
                      controller: _stateController,
                      hintText: 'State',
                      icon: Icons.map_outlined,
                      onTap: () => _showSelectionDialog(
                        title: 'Select State',
                        currentValue: _stateController.text,
                        options: _indianStates,
                        onSelected: (val) => setState(() => _stateController.text = val),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 4. Row: Pincode * & Address Type
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Pincode', isRequired: true),
                    const SizedBox(height: 6),
                    _buildTextInput(
                      controller: _pincodeController,
                      hintText: 'e.g. 560001',
                      icon: Icons.apps_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel('Address Type', isRequired: false),
                    const SizedBox(height: 6),
                    _buildAddressTypeDropdown(),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 5. Additional Instructions (Optional)
          _buildAdditionalInstructionsCard(),
          const SizedBox(height: 22),

          // 6. Save Address Button (Emerald Green)
          _buildSaveButton(),
        ],
      ),
    );
  }

  /// Field Label with optional red asterisk
  Widget _buildFieldLabel(String label, {required bool isRequired}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
              fontFamily: 'Inter',
            ),
          ),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE53935),
              ),
            ),
        ],
      ),
    );
  }

  /// Text Input Field with leading icon
  Widget _buildTextInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, size: 20, color: const Color(0xFF475569)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              validator: validator,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  /// Dropdown Input for City / State
  Widget _buildDropdownInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, size: 20, color: const Color(0xFF475569)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                hintText: hintText,
                hintStyle: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                errorStyle: const TextStyle(height: 0, fontSize: 0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF475569), size: 20),
            onPressed: onTap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  /// Address Type Dropdown (Home, Work, Other)
  Widget _buildAddressTypeDropdown() {
    IconData typeIcon = Icons.home_outlined;
    if (_selectedAddressType == 'Work') typeIcon = Icons.work_outline_rounded;
    if (_selectedAddressType == 'Other') typeIcon = Icons.location_on_outlined;

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Select Address Type',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 8),
                    for (final type in ['Home', 'Work', 'Other'])
                      ListTile(
                        leading: Icon(
                          type == 'Home'
                              ? Icons.home_rounded
                              : type == 'Work'
                                  ? Icons.work_rounded
                                  : Icons.location_on_rounded,
                          color: _selectedAddressType == type ? const Color(0xFF108A56) : const Color(0xFF475569),
                        ),
                        title: Text(
                          type,
                          style: TextStyle(
                            fontWeight: _selectedAddressType == type ? FontWeight.bold : FontWeight.w500,
                            color: _selectedAddressType == type ? const Color(0xFF108A56) : const Color(0xFF1E293B),
                          ),
                        ),
                        trailing: _selectedAddressType == type
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF108A56), size: 20)
                            : null,
                        onTap: () {
                          setState(() => _selectedAddressType = type);
                          Navigator.pop(ctx);
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            Icon(typeIcon, size: 20, color: const Color(0xFF475569)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedAddressType,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF475569), size: 20),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  /// Additional Instructions Card matching screenshot
  Widget _buildAdditionalInstructionsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.feed_outlined, size: 20, color: Color(0xFF475569)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Additional Instructions (Optional)',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: _instructionsController,
                  maxLines: 2,
                  minLines: 1,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(top: 4, bottom: 4),
                    hintText: 'e.g. Near the security gate, 3rd floor, etc.',
                    hintStyle: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Save Address Button in Emerald Green matching screenshot
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _saveAddress,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF108A56),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Save Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
