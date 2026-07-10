import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/constants/app_constants.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import 'profile_page.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider);
    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.mediumImpact();
      ref.read(userProfileProvider.notifier).updateProfile(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _phoneController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: const CustomAppBar(title: 'Edit Profile'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceM),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        
                        // Avatar Edit Block
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Hero(
                              tag: 'profile_avatar',
                              child: Material(
                                type: MaterialType.transparency,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? AppColors.surfaceDark : Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 54,
                                    backgroundColor: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primaryLight,
                                    child: Text(
                                      _nameController.text.isNotEmpty 
                                          ? _nameController.text.split(' ').map((n) => n.isNotEmpty ? n[0] : '').join()
                                          : 'S',
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        color: isDark ? Colors.white : AppColors.primary,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? AppColors.surfaceDark : Colors.white,
                                  width: 2.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ).animate().scale(
                              duration: 400.ms,
                              delay: 300.ms,
                              curve: Curves.easeOutBack,
                            ),
                          ],
                        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                        const SizedBox(height: 36),

                        // Form Inputs
                        CustomTextField(
                          controller: _nameController,
                          hintText: 'Enter full name',
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Name is required';
                            }
                            return null;
                          },
                        ).animate().fadeIn(duration: 450.ms, delay: 100.ms).slideY(
                          begin: 0.1,
                          end: 0,
                          curve: Curves.easeOutQuad,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _emailController,
                          hintText: 'Enter email address',
                          labelText: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val.trim())) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ).animate().fadeIn(duration: 450.ms, delay: 150.ms).slideY(
                          begin: 0.1,
                          end: 0,
                          curve: Curves.easeOutQuad,
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _phoneController,
                          hintText: 'Enter mobile number',
                          labelText: 'Mobile Number',
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_iphone_rounded, color: AppColors.primary),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Mobile number is required';
                            }
                            return null;
                          },
                        ).animate().fadeIn(duration: 450.ms, delay: 200.ms).slideY(
                          begin: 0.1,
                          end: 0,
                          curve: Curves.easeOutQuad,
                        ),
                      ],
                    ),
                  ),
                ),

                // Save button
                PrimaryButton(
                  text: 'Save Changes',
                  onPressed: _save,
                ).animate().fadeIn(duration: 500.ms, delay: 250.ms).slideY(
                  begin: 0.2,
                  end: 0,
                  curve: Curves.easeOutQuad,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
