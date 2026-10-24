import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/providers/products_provider.dart';

class AddressListPage extends ConsumerStatefulWidget {
  const AddressListPage({super.key});

  @override
  ConsumerState<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends ConsumerState<AddressListPage> {
  // Show Edit Address Dialog / Modal Bottom Sheet
  void _showEditAddressDialog(BuildContext context, Address address) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: address.name);
    final recipientController =
        TextEditingController(text: address.recipientName);
    final addressLineController =
        TextEditingController(text: address.addressLine);
    final cityController = TextEditingController(text: address.city);
    final phoneController = TextEditingController(text: address.phone);
    bool isDefault = address.isDefault;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE4E4E7),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Edit Address',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF18181B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildModalTextField(
                            controller: nameController,
                            label: 'Address Type (e.g. Home, Work, Other)',
                            hint: 'Home',
                          ),
                          const SizedBox(height: 12),
                          _buildModalTextField(
                            controller: recipientController,
                            label: 'Recipient Name',
                            hint: 'Saif Khan',
                          ),
                          const SizedBox(height: 12),
                          _buildModalTextField(
                            controller: addressLineController,
                            label: 'House / Flat / Street Name',
                            hint: 'Indira Nagar, House No. 123',
                          ),
                          const SizedBox(height: 12),
                          _buildModalTextField(
                            controller: cityController,
                            label: 'City, State & Pincode',
                            hint: 'Lucknow, Uttar Pradesh - 226016',
                          ),
                          const SizedBox(height: 12),
                          _buildModalTextField(
                            controller: phoneController,
                            label: 'Phone Number',
                            hint: '+91 98765 43210',
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(
                                value: isDefault,
                                activeColor: const Color(0xFFE61858),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (v) {
                                  setModalState(() {
                                    isDefault = v ?? false;
                                  });
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  'Set as default address',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF18181B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE61858),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                if (formKey.currentState?.validate() ?? true) {
                                  final updated = address.copyWith(
                                    name: nameController.text.trim(),
                                    recipientName:
                                        recipientController.text.trim(),
                                    addressLine:
                                        addressLineController.text.trim(),
                                    city: cityController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    isDefault: isDefault,
                                  );

                                  ref
                                      .read(addressListProvider.notifier)
                                      .editAddress(updated);
                                  if (isDefault) {
                                    ref
                                        .read(
                                            addressListProvider.notifier)
                                        .setDefaultAddress(updated.id);
                                    ref
                                        .read(
                                            selectedAddressProvider.notifier)
                                        .state = updated;
                                  }

                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Address updated successfully!'),
                                      backgroundColor: Color(0xFF10B981),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Delete confirmation dialog
  void _confirmDeleteAddress(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Delete Address?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF18181B),
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${address.name}" from your saved addresses?',
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF52525B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(0xFF71717A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(addressListProvider.notifier)
                  .deleteAddress(address.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${address.name} address removed'),
                  backgroundColor: const Color(0xFF18181B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE61858),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add from Map sheet
  void _openMapPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E4E7),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0F5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFDE8EF),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 32,
                      color: Color(0xFFE61858),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Select Location from Map',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF18181B),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pinpoint your precise delivery location on the map for 30-minute delivery.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF71717A),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.my_location_rounded,
                        color: Colors.white, size: 18),
                    label: const Text(
                      'Use Current GPS Location',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE61858),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.push('/add-address');
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFFE4E4E7),
              width: 1.0,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.centerLeft,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF18181B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFA1A1AA),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF18181B),
            size: 22,
          ),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          'My Addresses',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF18181B),
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          InkWell(
            onTap: () => _openMapPicker(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.location_on,
                    color: Color(0xFFE61858),
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Add from Map',
                    style: TextStyle(
                      color: Color(0xFFE61858),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 550),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Express Delivery Banner ("Add your address")
                  _buildTopDeliveryBanner(context),

                  const SizedBox(height: 16),

                  // 2. Address Cards List
                  if (addresses.isEmpty)
                    _buildEmptyAddressesState(context)
                  else
                    ...addresses.map(
                      (address) => _buildAddressCard(context, address),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 550),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.push('/add-address'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE61858),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Add New Address',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Top Banner ("Add your address" - 30 minutes delivery) ---
  Widget _buildTopDeliveryBanner(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/add-address'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF1F6),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF1F6),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 18,
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE61858).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const Icon(
                      Icons.location_on_rounded,
                      size: 28,
                      color: Color(0xFFE61858),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Add your address',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFE61858),
                      letterSpacing: -0.2,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Get your order delivered in 30 minutes',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFFE61858),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // --- Individual Address Card ---
  Widget _buildAddressCard(BuildContext context, Address address) {
    final isWork = address.name.toLowerCase().contains('work');
    final isOther = address.name.toLowerCase().contains('other');

    // Visual styles matching the exact screenshot icons & colors
    final Color iconBoxColor;
    final Color iconColor;
    final IconData cardIcon;

    if (isWork) {
      iconBoxColor = const Color(0xFFEBF5FD);
      iconColor = const Color(0xFF0284C7);
      cardIcon = Icons.business_center_outlined;
    } else if (isOther) {
      iconBoxColor = const Color(0xFFF3E8FF);
      iconColor = const Color(0xFF9333EA);
      cardIcon = Icons.location_on_outlined;
    } else {
      // Home / Parents Home
      iconBoxColor = const Color(0xFFFEEFF5);
      iconColor = const Color(0xFFE61858);
      cardIcon = Icons.home_outlined;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF1F1F4),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: address.isDefault
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  ref
                      .read(addressListProvider.notifier)
                      .setDefaultAddress(address.id);
                  ref
                      .read(selectedAddressProvider.notifier)
                      .state = address.copyWith(isDefault: true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Default address set to ${address.name}'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left icon box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBoxColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      cardIcon,
                      color: iconColor,
                      size: 22,
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Details on the right
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Title + Badge on left, Edit + Delete on right
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title and Default Badge
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    address.name,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF18181B),
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                  if (address.isDefault) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFCE7F3),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Default',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFE61858),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 6),

                          // Edit & Delete Actions
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Edit Action
                                InkWell(
                                  onTap: () =>
                                      _showEditAddressDialog(context, address),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.edit_outlined,
                                          size: 15,
                                          color: Color(0xFF18181B),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Edit',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF18181B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Delete Action
                                InkWell(
                                  onTap: () =>
                                      _confirmDeleteAddress(context, address),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 4,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(
                                          Icons.delete_outline_rounded,
                                          size: 16,
                                          color: Color(0xFF18181B),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Delete',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF18181B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // Address lines
                      Text(
                        address.addressLine,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF52525B),
                          height: 1.35,
                        ),
                      ),
                      Text(
                        address.city,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF52525B),
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Contact info: Name | Phone
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${address.recipientName}  |  ${address.phone}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF52525B),
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Bottom Radio Selection Row ("Default address" or "Set as default")
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: InkWell(
                          onTap: address.isDefault
                              ? null
                              : () {
                                  HapticFeedback.lightImpact();
                                  ref
                                      .read(addressListProvider.notifier)
                                      .setDefaultAddress(address.id);
                                  ref
                                      .read(selectedAddressProvider.notifier)
                                      .state = address.copyWith(isDefault: true);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Default address set to ${address.name}'),
                                      duration: const Duration(seconds: 1),
                                      backgroundColor: const Color(0xFF10B981),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (address.isDefault) ...[
                                  // Active Selected Pink Radio
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFE61858),
                                        width: 2.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE61858),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Default address',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFFE61858),
                                    ),
                                  ),
                                ] else ...[
                                  // Unselected Gray Radio
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFFD4D4D8),
                                        width: 1.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Set as default',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF71717A),
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
      ),
    );
  }

  // Empty state if all addresses deleted
  Widget _buildEmptyAddressesState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: const [
            Icon(
              Icons.location_off_rounded,
              size: 56,
              color: Color(0xFFD4D4D8),
            ),
            SizedBox(height: 14),
            Text(
              'No Saved Addresses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF18181B),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Add your delivery addresses to enjoy 30-minute delivery.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF71717A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
