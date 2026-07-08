import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/providers/products_provider.dart';

class AddAddressPage extends ConsumerStatefulWidget {
  const AddAddressPage({super.key});

  @override
  ConsumerState<AddAddressPage> createState() => _AddAddressPageState();
}

class _AddAddressPageState extends ConsumerState<AddAddressPage> {
  GoogleMapController? _mapController;
  LatLng _mapCenter = const LatLng(28.6130, 77.4100); // Default coordinate: Noida Sector 62
  bool _isLocating = false;
  bool _isReverseGeocoding = false;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Saif Khan');
  final _phoneController = TextEditingController(text: '+91 98765 43210');
  final _addressLine1Controller = TextEditingController(text: '123, Green Park Society');
  final _addressLine2Controller = TextEditingController(text: 'Near City Mall, Main Road, Sector 7');
  final _cityController = TextEditingController(text: 'Lucknow');
  final _stateController = TextEditingController(text: 'Uttar Pradesh');
  final _pincodeController = TextEditingController(text: '226010');
  final _countryController = TextEditingController(text: 'India');
  bool _isDefault = true;

  // Custom premium orange theme colors to match the Zomato/delivery design
  static const Color orangePrimary = Color(0xFFFF5E36);
  static const Color peachBackground = Color(0xFFFFEFEA);

  void _simulateReverseGeocode(LatLng target) {
    setState(() {
      _isReverseGeocoding = true;
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _isReverseGeocoding = false;
        final latRounded = double.parse(target.latitude.toStringAsFixed(4));
        final lngRounded = double.parse(target.longitude.toStringAsFixed(4));
        
        if (latRounded == 28.6130 && lngRounded == 77.4100) {
          _addressLine1Controller.text = '123, Green Park Society';
          _addressLine2Controller.text = 'Near City Mall, Main Road, Sector 7';
          _cityController.text = 'Lucknow';
          _stateController.text = 'Uttar Pradesh';
          _pincodeController.text = '226010';
        } else {
          _addressLine1Controller.text = 'Plot No. ${((latRounded * 100) % 99).toInt() + 1}, Sector 7';
          _addressLine2Controller.text = 'Green Park Extension';
        }
      });
    });
  }

  Future<void> _fetchCurrentGPSLocation() async {
    setState(() {
      _isLocating = true;
    });

    try {
      // 1. Check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled on your device. Please enable GPS.';
      }

      // 2. Check and request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Location permission denied by user.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Location permissions are permanently denied. Please enable them in app settings.';
      }

      // 3. Fetch device's current high accuracy GPS location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _isLocating = false;
        _mapCenter = currentLatLng;
        _nameController.text = 'Saif Khan';
        _phoneController.text = '+91 98765 43210';
      });

      // Move camera to user's real position on map
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: currentLatLng, zoom: 16.5),
        ),
      );

      _simulateReverseGeocode(currentLatLng);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text('GPS Localized! Position: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() {
        _isLocating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(e.toString())),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Address',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Add a delivery address to start ordering',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Highly Rounded Search Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search for area, street or landmark',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      icon: Icon(Icons.search_rounded, color: Colors.grey.shade500, size: 20),
                      suffixIcon: Icon(Icons.my_location_rounded, color: Colors.grey.shade500, size: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Google Map Card Container
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _mapCenter,
                            zoom: 15.0,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          onCameraMove: (position) {
                            _mapCenter = position.target;
                          },
                          onCameraIdle: () {
                            _simulateReverseGeocode(_mapCenter);
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          mapType: MapType.normal,
                        ),

                        // Center Map Locator indicator pin with tooltip card
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Light blue pulse circle
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // Blue coordinate marker dot
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              // Orange Pin icon offsetted
                              Padding(
                                padding: const EdgeInsets.only(bottom: 32.0),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: orangePrimary,
                                  size: 38,
                                  shadows: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Float tooltip address value
                        Positioned(
                          top: 16,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              '${_addressLine1Controller.text}, ${_cityController.text}',
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ),

                        // Zoom Controls Overlay on right side
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _fetchCurrentGPSLocation,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: AppConstants.lowShadow,
                                  ),
                                  child: Icon(Icons.gps_fixed_rounded, size: 16, color: isDark ? Colors.white : Colors.black87),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: AppConstants.lowShadow,
                                ),
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.add, size: 16),
                                      onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const Divider(height: 1, indent: 4, endIndent: 4),
                                    IconButton(
                                      icon: const Icon(Icons.remove, size: 16),
                                      onPressed: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 3. Use Current Location detection bar
                GestureDetector(
                  onTap: _isLocating ? null : _fetchCurrentGPSLocation,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: peachBackground,
                            shape: BoxShape.circle,
                          ),
                          child: _isLocating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(orangePrimary),
                                  ),
                                )
                              : const Icon(
                                  Icons.location_on_outlined,
                                  color: orangePrimary,
                                  size: 20,
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Use current location',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Detect my location automatically',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white70 : Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Form Fields Grid
                // Row 1: Full Name & Mobile Number (Split row)
                Row(
                  children: [
                    _buildInputCard(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildInputCard(
                      label: 'Mobile Number',
                      controller: _phoneController,
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 2: Address Line 1
                Row(
                  children: [
                    _buildInputCard(
                      label: 'Address Line 1',
                      controller: _addressLine1Controller,
                      icon: Icons.home_outlined,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 3: Address Line 2 (Optional)
                Row(
                  children: [
                    _buildInputCard(
                      label: 'Address Line 2 (Optional)',
                      controller: _addressLine2Controller,
                      icon: Icons.description_outlined,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 4: City & State (Split row)
                Row(
                  children: [
                    _buildInputCard(
                      label: 'City',
                      controller: _cityController,
                      icon: Icons.apartment_outlined,
                      isDropdown: true,
                      isDark: isDark,
                      onTap: () {},
                    ),
                    const SizedBox(width: 12),
                    _buildInputCard(
                      label: 'State',
                      controller: _stateController,
                      icon: Icons.map_outlined,
                      isDropdown: true,
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Row 5: Pincode & Country (Split row)
                Row(
                  children: [
                    _buildInputCard(
                      label: 'Pincode',
                      controller: _pincodeController,
                      icon: Icons.pin_drop_outlined,
                      keyboardType: TextInputType.number,
                      isDark: isDark,
                    ),
                    const SizedBox(width: 12),
                    _buildInputCard(
                      label: 'Country',
                      controller: _countryController,
                      icon: Icons.language_outlined,
                      isDropdown: true,
                      isDark: isDark,
                      onTap: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 5. Set default switch card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: peachBackground,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star_outline_rounded,
                          color: orangePrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Set as default address',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'This address will be used by default at checkout',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.white70 : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isDefault,
                        activeColor: orangePrimary,
                        activeTrackColor: orangePrimary.withOpacity(0.3),
                        onChanged: (val) {
                          setState(() {
                            _isDefault = val;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 6. Save Address Action Button
                ElevatedButton.icon(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _addressLine1Controller.text.isNotEmpty) {
                      final address = Address(
                        id: 'a${DateTime.now().millisecondsSinceEpoch}',
                        name: _nameController.text.trim(),
                        addressLine: _addressLine1Controller.text.trim(),
                        city: '${_cityController.text.trim()}, ${_stateController.text.trim()} - ${_pincodeController.text.trim()}',
                        phone: _phoneController.text.trim(),
                        isDefault: _isDefault,
                      );

                      ref.read(addressListProvider.notifier).addAddress(address);

                      if (_isDefault) {
                        ref.read(selectedAddressProvider.notifier).state = address;
                      }

                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
                  label: const Text(
                    'Save Address',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orangePrimary,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Unified Custom Input Card builder matching the provided UI layout
  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool isDropdown = false,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: peachBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: orangePrimary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white70 : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    isDropdown
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.text,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 16,
                                color: isDark ? Colors.white70 : Colors.grey.shade600,
                              ),
                            ],
                          )
                        : SizedBox(
                            height: 24,
                            child: TextField(
                              controller: controller,
                              keyboardType: keyboardType,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
