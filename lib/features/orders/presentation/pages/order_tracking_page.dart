import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../shared/providers/products_provider.dart';

class OrderTrackingPage extends ConsumerStatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  ConsumerState<OrderTrackingPage> createState() => _OrderTrackingPageState();
}

class _OrderTrackingPageState extends ConsumerState<OrderTrackingPage> {
  GoogleMapController? _mapController;
  int _stepIndex = 0;
  Timer? _timer;
  bool _isLocating = false;

  // Real coordinate path representing the route from boutique warehouse to the user's location
  final List<LatLng> _routeCoordinates = const [
    LatLng(28.6280, 77.3790), // Milestone 0: Warehouse, Sector 5 Noida
    LatLng(28.6210, 77.3820), // Milestone 1: Transit Hub, Sector 62
    LatLng(28.6180, 77.3910), // Milestone 2: Express Highway, Noida
    LatLng(28.6150, 77.4010), // Milestone 3: Near High Street Entrance
    LatLng(28.6130, 77.4100), // Milestone 4: Destination Point, Noida
  ];

  final List<TrackingMilestone> _milestones = [
    TrackingMilestone(
      name: 'Boutique Warehouse, Sector 5',
      distance: '5.2 km',
      timeRemaining: '25 mins',
      statusDescription: 'Order packaged and ready at the dispatch base.',
    ),
    TrackingMilestone(
      name: 'Transit Hub, Crossing Loop',
      distance: '3.8 km',
      timeRemaining: '18 mins',
      styleName: 'Passing Sector 62 Crossing',
      statusDescription: 'Dispatched from hub. Heading towards the main road.',
    ),
    TrackingMilestone(
      name: 'Passing Express Flyover Gate',
      distance: '2.4 km',
      timeRemaining: '10 mins',
      styleName: 'Expressway Near Sector 63',
      statusDescription: 'Rider is driving smoothly on the flyover belt.',
    ),
    TrackingMilestone(
      name: 'Near High Street Main Entrance',
      distance: '0.8 km',
      timeRemaining: '4 mins',
      styleName: 'Entering High Street Sector',
      statusDescription: 'Rider has entered the neighborhood and is nearby.',
    ),
    TrackingMilestone(
      name: 'Arrived at Destination Address', // dynamically overridden using actual selectedAddress
      distance: '0.0 km',
      timeRemaining: 'Arrived',
      styleName: 'Arrived at Your Doorstep',
      statusDescription: 'Delivery successfully completed and verified.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Simulate real-time tracking position changes and move camera every 8 seconds
    _timer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          _stepIndex = (_stepIndex + 1) % _routeCoordinates.length;
        });
        _animateCameraToRider();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _animateCameraToRider() {
    if (_mapController != null && _stepIndex < _routeCoordinates.length) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(_routeCoordinates[_stepIndex]),
      );
    }
  }

  void _zoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomOut());
  }

  void _fetchCurrentLocation() {
    setState(() {
      _isLocating = true;
    });

    // Simulate GPS positioning retrieval delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLocating = false;
          _stepIndex = 3; // Snap map rider close to the user
        });
        _animateCameraToRider();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'GPS Localized! Centered Google Maps on Noida Sector 62.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Fetch user's actual selected address from Riverpod
    final selectedAddress = ref.watch(selectedAddressProvider);
    final destinationLabel = selectedAddress != null 
        ? '${selectedAddress.addressLine}, ${selectedAddress.city}' 
        : '128 High Street, Noida';

    // Override the final milestone name dynamically
    _milestones.last = TrackingMilestone(
      name: 'Arrived at $destinationLabel',
      distance: '0.0 km',
      timeRemaining: 'Arrived',
      styleName: 'Arrived at Your Doorstep',
      statusDescription: 'Delivery successfully completed and verified.',
    );

    final currentMilestone = _milestones[_stepIndex];

    // Dynamically adjust step details according to the current GPS progress point
    final List<TrackingStep> steps = [
      TrackingStep(
        title: 'Order Confirmed',
        description: 'Your fashion order was received.',
        time: '10:30 AM',
        isCompleted: true,
      ),
      TrackingStep(
        title: 'Preparing Order',
        description: 'Verify boutique packaging and tags.',
        time: '11:15 AM',
        isCompleted: _stepIndex >= 1,
        isCurrent: _stepIndex == 0,
      ),
      TrackingStep(
        title: 'Out for Delivery',
        description: _stepIndex == 4 
            ? 'Delivered by Courier Alex Johnson.' 
            : 'Rider Alex is on the way with your clothing.',
        time: '12:00 PM',
        isCompleted: _stepIndex >= 4,
        isCurrent: _stepIndex >= 1 && _stepIndex < 4,
      ),
      TrackingStep(
        title: 'Delivered',
        description: 'Secure delivery handoff verified.',
        time: _stepIndex == 4 ? '12:25 PM' : '--:--',
        isCompleted: _stepIndex == 4,
        isCurrent: false,
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: const CustomAppBar(title: 'Track Order'),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Live Google Maps Widget Container
              Container(
                height: 250,
                margin: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  boxShadow: AppConstants.mediumShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Official Google Maps Widget integration
                      GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _routeCoordinates[_stepIndex],
                          zoom: 13.5,
                        ),
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        markers: {
                          // Rider Marker
                          Marker(
                            markerId: const MarkerId('rider'),
                            position: _routeCoordinates[_stepIndex],
                            infoWindow: InfoWindow(
                              title: 'Alex Johnson (Rider)',
                              snippet: 'Distance remaining: ${currentMilestone.distance}',
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                          ),
                          // Destination Marker
                          Marker(
                            markerId: const MarkerId('destination'),
                            position: _routeCoordinates.last,
                            infoWindow: InfoWindow(
                              title: 'Delivery Destination',
                              snippet: destinationLabel,
                            ),
                            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                          ),
                        },
                        polylines: {
                          // Planned Route Polyline
                          Polyline(
                            polylineId: const PolylineId('planned_route'),
                            points: _routeCoordinates,
                            color: Colors.blue.withOpacity(0.5),
                            width: 6,
                          ),
                          // Traveled Route Polyline (Highlighted Green)
                          Polyline(
                            polylineId: const PolylineId('traveled_route'),
                            points: _routeCoordinates.sublist(0, _stepIndex + 1),
                            color: AppColors.primary,
                            width: 6,
                          ),
                        },
                        zoomControlsEnabled: false,
                        myLocationButtonEnabled: false,
                        mapType: MapType.normal,
                      ),

                      // Custom Map Zoom scale overlay
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Column(
                          children: [
                            _buildMapControl(Icons.add, _zoomIn, isDark),
                            const SizedBox(height: 8),
                            _buildMapControl(Icons.remove, _zoomOut, isDark),
                          ],
                        ),
                      ),

                      // GPS Target Locater Button ("Locate Me")
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: _isLocating ? null : _fetchCurrentLocation,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: AppConstants.lowShadow,
                            ),
                            child: _isLocating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                    ),
                                  )
                                : const Icon(Icons.my_location_rounded, size: 18, color: AppColors.primary),
                          ),
                        ),
                      ),

                      // Delivery Estimate Info Tag
                      Positioned(
                        bottom: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.bgDark.withOpacity(0.85) : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            boxShadow: AppConstants.lowShadow,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.flash_on_rounded, color: AppColors.accent, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                _stepIndex == 4 ? 'Status: Arrived' : 'Time Left: ${currentMilestone.timeRemaining}',
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Real-Time Location Tracking Info Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  boxShadow: AppConstants.lowShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CURRENT GPS LOCATION',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentMilestone.name,
                                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTrackingStat('Distance Left', currentMilestone.distance, theme),
                        _buildTrackingStat('Time Left', currentMilestone.timeRemaining, theme),
                        _buildTrackingStat('GPS Status', _stepIndex == 4 ? 'Arrived' : 'In Transit', theme),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. Courier Boy Details
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                padding: const EdgeInsets.all(AppConstants.spaceM),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                  boxShadow: AppConstants.lowShadow,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alex Johnson',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppColors.warning, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '4.8 (1.2k Ratings)',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        _buildRoundButton(Icons.call_rounded, isDark, () {}),
                        const SizedBox(width: 8),
                        _buildRoundButton(Icons.message_rounded, isDark, () {}),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Timeline Progress Steps
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceM),
                child: Text(
                  'Delivery Status',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXL),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    final isLast = index == steps.length - 1;
                    
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: step.isCompleted || step.isCurrent 
                                    ? AppColors.primary 
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                shape: BoxShape.circle,
                                border: step.isCurrent 
                                    ? Border.all(color: AppColors.primaryLight, width: 4)
                                    : null,
                              ),
                              child: step.isCompleted 
                                  ? const Icon(Icons.check, size: 12, color: Colors.white) 
                                  : null,
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 50,
                                color: step.isCompleted 
                                    ? AppColors.primary 
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: step.isCurrent || step.isCompleted
                                      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                                      : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.description,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          step.time,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: step.isCompleted ? AppColors.primary : null,
                            fontWeight: step.isCompleted ? FontWeight.bold : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark.withOpacity(0.9) : Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: AppConstants.lowShadow,
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
    );
  }

  Widget _buildTrackingStat(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildRoundButton(IconData icon, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.borderDark : AppColors.primaryLight.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
    );
  }
}

class TrackingMilestone {
  final String name;
  final String distance;
  final String timeRemaining;
  final String? styleName;
  final String statusDescription;

  TrackingMilestone({
    required this.name,
    required this.distance,
    required this.timeRemaining,
    this.styleName,
    required this.statusDescription,
  });
}

class TrackingStep {
  final String title;
  final String description;
  final String time;
  final bool isCompleted;
  final bool isCurrent;

  TrackingStep({
    required this.title,
    required this.description,
    required this.time,
    this.isCompleted = false,
    this.isCurrent = false,
  });
}
