import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../shared/providers/products_provider.dart';

class AddressListPage extends ConsumerWidget {
  const AddressListPage({super.key});

  void _showAddressDialog(BuildContext context, WidgetRef ref, {Address? addressToEdit}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: addressToEdit?.name ?? '');
    final addressLineController = TextEditingController(text: addressToEdit?.addressLine ?? '');
    final cityController = TextEditingController(text: addressToEdit?.city ?? '');
    final phoneController = TextEditingController(text: addressToEdit?.phone ?? '');
    bool isDefault = addressToEdit?.isDefault ?? false;
    bool isLocating = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppColors.surfaceDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusXL)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: AppConstants.spaceL,
                right: AppConstants.spaceL,
                top: AppConstants.spaceL,
                bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spaceL,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addressToEdit == null ? 'Add New Address' : 'Edit Address',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      if (addressToEdit == null) ...[
                        // Zomato-style GPS Fetch Button
                        InkWell(
                          onTap: isLocating
                              ? null
                              : () {
                                  setSheetState(() {
                                    isLocating = true;
                                  });

                                  // Simulate high accuracy GPS location fetch
                                  Future.delayed(const Duration(milliseconds: 1200), () {
                                    if (context.mounted) {
                                      setSheetState(() {
                                        isLocating = false;
                                        nameController.text = 'Rashid Khan';
                                        addressLineController.text = 'Flat 402, Block B, Sector 62';
                                        cityController.text = 'Noida, Uttar Pradesh - 201301';
                                        phoneController.text = '+91 98765 43210';
                                      });

                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 16),
                                              SizedBox(width: 8),
                                              Text('Current location auto-filled!'),
                                            ],
                                          ),
                                          duration: Duration(seconds: 2),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  });
                                },
                          borderRadius: BorderRadius.circular(AppConstants.radiusM),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isLocating
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                        ),
                                      )
                                    : const Icon(Icons.my_location_rounded, color: AppColors.primary, size: 18),
                                const SizedBox(width: 10),
                                Text(
                                  isLocating ? 'Locating Your Address...' : 'Use Current GPS Location',
                                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      CustomTextField(
                        controller: nameController,
                        hintText: 'Enter recipient name',
                        labelText: 'Recipient Name',
                        validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: addressLineController,
                        hintText: 'Enter flat number, street name',
                        labelText: 'Address Line',
                        validator: (val) => val == null || val.isEmpty ? 'Address is required' : null,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: cityController,
                        hintText: 'Enter city, state & zip',
                        labelText: 'City & Zip Code',
                        validator: (val) => val == null || val.isEmpty ? 'City details are required' : null,
                      ),
                      const SizedBox(height: 12),

                      CustomTextField(
                        controller: phoneController,
                        hintText: 'Enter phone number',
                        labelText: 'Phone Number',
                        keyboardType: TextInputType.phone,
                        validator: (val) => val == null || val.isEmpty ? 'Phone is required' : null,
                      ),
                      const SizedBox(height: 8),

                      SwitchListTile(
                        title: const Text('Set as Default Address', style: TextStyle(fontSize: 14)),
                        value: isDefault,
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          setSheetState(() {
                            isDefault = val;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      PrimaryButton(
                        text: addressToEdit == null ? 'Add Address' : 'Save Changes',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            final address = Address(
                              id: addressToEdit?.id ?? 'a${DateTime.now().millisecondsSinceEpoch}',
                              name: nameController.text.trim(),
                              addressLine: addressLineController.text.trim(),
                              city: cityController.text.trim(),
                              phone: phoneController.text.trim(),
                              isDefault: isDefault,
                            );

                            if (addressToEdit == null) {
                              ref.read(addressListProvider.notifier).addAddress(address);
                            } else {
                              ref.read(addressListProvider.notifier).editAddress(address);
                            }

                            if (isDefault) {
                              ref.read(selectedAddressProvider.notifier).state = address;
                            }

                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final addresses = ref.watch(addressListProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: const CustomAppBar(title: 'My Addresses'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: addresses.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_off_rounded, size: 64, color: AppColors.textSecondaryLight),
                          const SizedBox(height: 16),
                          Text(
                            'No Saved Addresses',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text('Save delivery locations to checkout faster.'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(AppConstants.spaceM),
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        final isSelected = selectedAddress?.id == address.id;

                        return GestureDetector(
                          onTap: () {
                            ref.read(selectedAddressProvider.notifier).state = address;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Active delivery set to ${address.name}.'),
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.surfaceDark : Colors.white,
                              borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              border: Border.all(
                                color: isSelected 
                                    ? AppColors.primary 
                                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: AppConstants.lowShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title Line Name & Select indicators
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          address.name,
                                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        if (address.isDefault) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryLight.withOpacity(isDark ? 0.2 : 0.8),
                                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                                            ),
                                            child: const Text(
                                              'Default',
                                              style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    Icon(
                                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_off_rounded,
                                      color: isSelected ? AppColors.primary : AppColors.textMutedLight,
                                      size: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Address line
                                Text(
                                  address.addressLine,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                Text(
                                  address.city,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address.phone,
                                  style: theme.textTheme.bodySmall,
                                ),

                                const Divider(height: 24),

                                // Action Buttons (Edit & Delete)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                                      label: const Text('Edit', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                                      onPressed: () => _showAddressDialog(context, ref, addressToEdit: address),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                                      label: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                                      onPressed: () {
                                        ref.read(addressListProvider.notifier).deleteAddress(address.id);
                                        if (isSelected) {
                                          ref.read(selectedAddressProvider.notifier).state = null;
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            
            // Bottom Add Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceM),
              child: PrimaryButton(
                text: 'Add New Address',
                onPressed: () => context.push('/add-address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
