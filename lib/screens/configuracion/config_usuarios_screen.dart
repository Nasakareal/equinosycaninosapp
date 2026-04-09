import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/admin_user.dart';
import '../../services/config_users_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';

class ConfigUsuariosScreen extends StatefulWidget {
  const ConfigUsuariosScreen({super.key});

  @override
  State<ConfigUsuariosScreen> createState() => _ConfigUsuariosScreenState();
}

class _ConfigUsuariosScreenState extends State<ConfigUsuariosScreen> {
  final ConfigUsersService _service = ConfigUsersService();

  List<AdminUser> _items = const [];
  List<String> _roles = const [];
  bool _loading = true;
  bool _working = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final users = await _service.index();
      if (!mounted) return;
      setState(() {
        _items = users;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<bool> _ensureRolesLoaded() async {
    if (_roles.isNotEmpty) return true;

    try {
      final roles = await _service.catalogRoles();
      if (!mounted) return false;
      setState(() => _roles = roles.toSet().toList()..sort());
      return _roles.isNotEmpty;
    } catch (e) {
      if (!mounted) return false;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
      return false;
    }
  }

  Future<void> _create() async {
    final ready = await _ensureRolesLoaded();
    if (!ready) {
      _showSnack('No hay roles disponibles para asignar.');
      return;
    }

    final data = await showDialog<_UserFormData>(
      context: context,
      builder: (_) => _UserFormDialog(roles: _roles),
    );

    if (data == null) return;

    setState(() => _working = true);
    try {
      await _service.create(data.toCreatePayload());
      if (!mounted) return;
      _showSnack('Usuario creado correctamente.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _edit(AdminUser item) async {
    final ready = await _ensureRolesLoaded();
    if (!ready) {
      _showSnack('No hay roles disponibles para asignar.');
      return;
    }

    final data = await showDialog<_UserFormData>(
      context: context,
      builder: (_) => _UserFormDialog(roles: _roles, user: item),
    );

    if (data == null) return;

    setState(() => _working = true);
    try {
      await _service.update(item.id, data.toUpdatePayload());
      if (!mounted) return;
      _showSnack('Usuario actualizado correctamente.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _delete(AdminUser item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          'Se eliminara a ${item.name}. Esta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    setState(() => _working = true);
    try {
      await _service.delete(item.id);
      if (!mounted) return;
      _showSnack('Usuario eliminado correctamente.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Glass(
                  radius: 18,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      _HeaderIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuracion de usuarios',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Alta, edicion y eliminacion de cuentas',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_working)
                        const Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      _HeaderIconButton(
                        icon: Icons.refresh_rounded,
                        onTap: _load,
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _create,
                        icon: const Icon(Icons.person_add_alt_1_rounded),
                        label: const Text('Agregar'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Glass(
                    radius: 22,
                    padding: const EdgeInsets.all(12),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                        ? Center(
                            child: Text(
                              _error!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.red,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          )
                        : _items.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin usuarios registrados',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, index) {
                              final item = _items[index];
                              return _UserCard(
                                item: item,
                                onEdit: () => _edit(item),
                                onDelete: () => _delete(item),
                              );
                            },
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

class _UserCard extends StatelessWidget {
  final AdminUser item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _UserCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final roleText = item.roles.isEmpty ? 'Sin rol' : item.roles.join(', ');
    final active = item.estado.toLowerCase() == 'activo';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.creamStroke.withValues(alpha: 0.22),
        ),
        color: AppColors.whiteWarm.withValues(alpha: 0.60),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.email,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: (active ? AppColors.greenDeep : AppColors.red)
                      .withValues(alpha: 0.12),
                  border: Border.all(
                    color: (active ? AppColors.greenDeep : AppColors.red)
                        .withValues(alpha: 0.24),
                  ),
                ),
                child: Text(
                  item.estado.isEmpty ? 'Sin estado' : item.estado,
                  style: TextStyle(
                    color: active ? AppColors.greenDeep : AppColors.red,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _UserChip(
                icon: Icons.admin_panel_settings_rounded,
                text: roleText,
              ),
              _UserChip(
                icon: Icons.apartment_rounded,
                text: item.area?.trim().isNotEmpty == true
                    ? item.area!.trim()
                    : 'Sin area',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Editar'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: const Text('Eliminar'),
                style: TextButton.styleFrom(foregroundColor: AppColors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _UserChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.creamStrong.withValues(alpha: 0.72),
        border: Border.all(
          color: AppColors.creamStroke.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.brownDeep),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.text,
                fontWeight: FontWeight.w800,
                fontSize: 12.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserFormDialog extends StatefulWidget {
  final List<String> roles;
  final AdminUser? user;

  const _UserFormDialog({required this.roles, this.user});

  @override
  State<_UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<_UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _passwordCtrl;
  late final TextEditingController _confirmCtrl;
  late String? _role;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  bool get _editing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final currentRole = widget.user?.primaryRole;
    final normalizedRoles = {
      ...widget.roles,
      if (currentRole != null && currentRole.isNotEmpty) currentRole,
    }.toList()..sort();

    _nameCtrl = TextEditingController(text: widget.user?.name ?? '');
    _emailCtrl = TextEditingController(text: widget.user?.email ?? '');
    _areaCtrl = TextEditingController(text: widget.user?.area ?? '');
    _passwordCtrl = TextEditingController();
    _confirmCtrl = TextEditingController();
    _role = normalizedRoles.contains(currentRole)
        ? currentRole
        : (normalizedRoles.isEmpty ? null : normalizedRoles.first);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _areaCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(
      context,
      _UserFormData(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        area: _areaCtrl.text.trim(),
        role: _role!,
        password: _passwordCtrl.text,
        passwordConfirmation: _confirmCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final roles = {
      ...widget.roles,
      if (widget.user?.primaryRole.trim().isNotEmpty == true)
        widget.user!.primaryRole.trim(),
    }.toList()..sort();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _editing ? 'Editar usuario' : 'Nuevo usuario',
                    style: const TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Captura el nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: (value) {
                      final email = (value ?? '').trim();
                      if (email.isEmpty) return 'Captura el correo';
                      if (!email.contains('@')) return 'Correo invalido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _areaCtrl,
                    decoration: const InputDecoration(labelText: 'Area'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _role,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: roles
                        .map(
                          (role) => DropdownMenuItem<String>(
                            value: role,
                            child: Text(role),
                          ),
                        )
                        .toList(),
                    onChanged: roles.isEmpty
                        ? null
                        : (value) => setState(() => _role = value),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Selecciona un rol';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: _editing
                          ? 'Nueva contrasena (opcional)'
                          : 'Contrasena',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      final pass = value ?? '';
                      if (!_editing && pass.isEmpty) {
                        return 'Captura la contrasena';
                      }
                      if (pass.isNotEmpty && pass.length < 6) {
                        return 'La contrasena debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contrasena',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                    validator: (value) {
                      final pass = _passwordCtrl.text;
                      final confirm = value ?? '';
                      if (!_editing && confirm.isEmpty) {
                        return 'Confirma la contrasena';
                      }
                      if (pass.isNotEmpty || confirm.isNotEmpty) {
                        if (pass != confirm) {
                          return 'Las contrasenas no coinciden';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: roles.isEmpty ? null : _submit,
                        child: Text(
                          _editing ? 'Guardar cambios' : 'Crear usuario',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserFormData {
  final String name;
  final String email;
  final String area;
  final String role;
  final String password;
  final String passwordConfirmation;

  const _UserFormData({
    required this.name,
    required this.email,
    required this.area,
    required this.role,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toCreatePayload() {
    return {
      'name': name,
      'email': email,
      'area': area.isEmpty ? null : area,
      'role': role,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  Map<String, dynamic> toUpdatePayload() {
    return {
      'name': name,
      'email': email,
      'area': area.isEmpty ? null : area,
      'role': role,
      if (password.isNotEmpty) 'password': password,
      if (passwordConfirmation.isNotEmpty)
        'password_confirmation': passwordConfirmation,
    };
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.creamStroke.withValues(alpha: 0.24),
          ),
          color: AppColors.whiteWarm.withValues(alpha: 0.62),
        ),
        child: Icon(icon, color: AppColors.brownDeep),
      ),
    );
  }
}
