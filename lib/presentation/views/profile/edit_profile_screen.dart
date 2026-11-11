import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Pantalla para la edición de perfil del estudiante/usuario (RF1).
///
/// Permite actualizar el nombre para mostrar y seleccionar o cambiar
/// el avatar de usuario con persistencia en Firestore y SecureStorage.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _avatarUrlController;

  // Colección de avatares estilo Politécnico / Estudiante para selección rápida
  final List<String> _presetAvatars = [
    'https://api.dicebear.com/7.x/bottts/png?seed=escom1',
    'https://api.dicebear.com/7.x/bottts/png?seed=ipn2',
    'https://api.dicebear.com/7.x/bottts/png?seed=huelum3',
    'https://api.dicebear.com/7.x/bottts/png?seed=burroblanco',
    'https://api.dicebear.com/7.x/bottts/png?seed=ingeniero',
  ];

  late String _selectedAvatar;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authViewModelProvider).user;
    _nameController = TextEditingController(text: user?.nombre ?? '');
    _selectedAvatar = user?.avatarUrl.isNotEmpty == true
        ? user!.avatarUrl
        : _presetAvatars.first;
    _avatarUrlController = TextEditingController(text: _selectedAvatar);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final success = await ref.read(authViewModelProvider.notifier).updateProfile(
          nombre: _nameController.text.trim(),
          avatarUrl: _avatarUrlController.text.trim().isNotEmpty
              ? _avatarUrlController.text.trim()
              : _selectedAvatar,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado exitosamente.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(authViewModelProvider).errorMessage ??
          'Error al actualizar el perfil.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vista previa del Avatar
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary, width: 3),
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                        child: ClipOval(
                          child: _selectedAvatar.isNotEmpty
                              ? Image.network(
                                  _selectedAvatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.person,
                                    size: 54,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 54,
                                  color: AppColors.primary,
                                ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Selector de avatares predeterminados
                Text(
                  'Elige un avatar institucional:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _presetAvatars.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final url = _presetAvatars[index];
                      final isSelected = url == _selectedAvatar;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = url;
                            _avatarUrlController.text = url;
                          });
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? AppColors.primary : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Campo Nombre Completo
                TextFormField(
                  controller: _nameController,
                  enabled: !isLoading,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: AppStrings.fullName,
                    prefixIcon: Icon(Icons.person_outline),
                    helperText: 'Visible en tus pedidos y entregas',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppStrings.requiredField;
                    }
                    if (value.trim().length < 3) {
                      return AppStrings.nameTooShort;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo URL de imagen personalizada (opcional)
                TextFormField(
                  controller: _avatarUrlController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'URL de Avatar personalizada (opcional)',
                    prefixIcon: Icon(Icons.link_outlined),
                  ),
                  onChanged: (val) {
                    if (val.trim().isNotEmpty) {
                      setState(() {
                        _selectedAvatar = val.trim();
                      });
                    }
                  },
                ),
                const SizedBox(height: 36),

                // Botón Guardar Cambios
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveProfile,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Guardar Cambios',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
