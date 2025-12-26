import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user.dart' as auth;
import '../blocs/profile_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/error_messages.dart';

class EditProfilePage extends StatefulWidget {
  final auth.User user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.user.displayName ?? '',
    );
    _emailController = TextEditingController(text: widget.user.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedUser = widget.user.copyWith(
      name: _nameController.text.trim(),
    );

    context.read<ProfileBloc>().add(
      ProfileUpdateRequested(profile: updatedUser),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ErrorMessages.profileUpdatedSuccess),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.of(context).pop(true);
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hata: ${state.message}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileUpdating;

        return Scaffold(
          appBar: AppBar(
            title: const Text(ErrorMessages.editProfileTitle),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              children: [
                // Profile Avatar
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.2,
                        ),
                        child: Text(
                          widget.user.name.isNotEmpty
                              ? widget.user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: ErrorMessages.nameLabel,
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return ErrorMessages.nameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Field (Read-only)
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: ErrorMessages.emailLabel,
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                    helperText: ErrorMessages.emailCannotChange,
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 16),

                // Role Info (Read-only)
                Card(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                ErrorMessages.accountTypeLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getRoleText(widget.user.role),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                        child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            ErrorMessages.saveChangesLabel,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel Button
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text(ErrorMessages.cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getRoleText(auth.UserRole role) {
    switch (role) {
      case auth.UserRole.user:
        return ErrorMessages.roleUser;
      case auth.UserRole.owner:
        return ErrorMessages.roleOwner;
      case auth.UserRole.admin:
        return ErrorMessages.roleAdmin;
      case auth.UserRole.pendingOwner:
        return ErrorMessages.rolePendingOwner;
    }
  }
}
