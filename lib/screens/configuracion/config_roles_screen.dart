import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../models/admin_role.dart';
import '../../services/config_roles_service.dart';
import '../../widgets/home/app_background.dart';
import '../../widgets/home/glass.dart';

class ConfigRolesScreen extends StatefulWidget {
  const ConfigRolesScreen({super.key});

  @override
  State<ConfigRolesScreen> createState() => _ConfigRolesScreenState();
}

class _ConfigRolesScreenState extends State<ConfigRolesScreen> {
  final ConfigRolesService _service = ConfigRolesService();

  List<AdminRole> _items = const [];
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
      final roles = await _service.index();
      if (!mounted) return;
      setState(() => _items = roles);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _create() async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _RoleNameDialog(),
    );
    if (name == null) return;

    setState(() => _working = true);
    try {
      await _service.create(name);
      if (!mounted) return;
      _showSnack('Rol creado correctamente.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _edit(AdminRole role) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RoleNameDialog(initialValue: role.name),
    );
    if (name == null) return;

    setState(() => _working = true);
    try {
      await _service.update(role.id, name);
      if (!mounted) return;
      _showSnack('Rol actualizado correctamente.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _delete(AdminRole role) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar rol'),
        content: Text(
          'Se eliminara el rol ${role.name}. Esta accion no se puede deshacer.',
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
      await _service.delete(role.id);
      if (!mounted) return;
      _showSnack('Rol eliminado correctamente.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _managePermissions(AdminRole role) async {
    setState(() => _working = true);
    try {
      final payload = await _service.permissions(role.id);
      if (!mounted) return;

      setState(() => _working = false);

      final selected = await showDialog<List<int>>(
        context: context,
        builder: (_) => _RolePermissionsDialog(payload: payload),
      );

      if (selected == null) return;

      setState(() => _working = true);
      await _service.assignPermissions(role.id, selected);
      if (!mounted) return;
      _showSnack('Permisos actualizados correctamente.');
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
                              'Configuracion de roles',
                              style: TextStyle(
                                color: AppColors.text,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Roles, conteo de usuarios y permisos asignados',
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
                        icon: const Icon(Icons.add_rounded),
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
                              'Sin roles registrados',
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
                              return _RoleCard(
                                item: item,
                                onEdit: () => _edit(item),
                                onDelete: () => _delete(item),
                                onPermissions: () => _managePermissions(item),
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

class _RoleCard extends StatelessWidget {
  final AdminRole item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPermissions;

  const _RoleCard({
    required this.item,
    required this.onEdit,
    required this.onDelete,
    required this.onPermissions,
  });

  @override
  Widget build(BuildContext context) {
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
          Text(
            item.name,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _RoleChip(
                icon: Icons.people_alt_rounded,
                text: '${item.usersCount} usuarios',
              ),
              _RoleChip(
                icon: Icons.verified_user_rounded,
                text: '${item.permissionsCount} permisos',
              ),
              _RoleChip(
                icon: Icons.security_rounded,
                text: item.guardName.isEmpty ? 'web' : item.guardName,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: onPermissions,
                icon: const Icon(Icons.tune_rounded),
                label: const Text('Permisos'),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded),
                label: const Text('Editar'),
              ),
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

class _RoleChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RoleChip({required this.icon, required this.text});

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
          Text(
            text,
            style: const TextStyle(
              color: AppColors.text,
              fontWeight: FontWeight.w800,
              fontSize: 12.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleNameDialog extends StatefulWidget {
  final String? initialValue;

  const _RoleNameDialog({this.initialValue});

  @override
  State<_RoleNameDialog> createState() => _RoleNameDialogState();
}

class _RoleNameDialogState extends State<_RoleNameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, _nameCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.initialValue != null;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  editing ? 'Editar rol' : 'Nuevo rol',
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del rol',
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Captura el nombre del rol';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
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
                      onPressed: _submit,
                      child: Text(editing ? 'Guardar cambios' : 'Crear rol'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RolePermissionsDialog extends StatefulWidget {
  final AdminRolePermissionsPayload payload;

  const _RolePermissionsDialog({required this.payload});

  @override
  State<_RolePermissionsDialog> createState() => _RolePermissionsDialogState();
}

class _RolePermissionsDialogState extends State<_RolePermissionsDialog> {
  late final Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.payload.rolePermissionIds.toSet();
  }

  void _toggleAll(AdminPermissionGroup group, bool value) {
    setState(() {
      for (final permission in group.permissions) {
        if (value) {
          _selected.add(permission.id);
        } else {
          _selected.remove(permission.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 840, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Permisos de ${widget.payload.role.name}',
                style: const TextStyle(
                  color: AppColors.text,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Selecciona los permisos que tendra este rol.',
                style: TextStyle(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: widget.payload.groupedPermissions.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay permisos disponibles para asignar.',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: widget.payload.groupedPermissions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, index) {
                          final group =
                              widget.payload.groupedPermissions[index];
                          final total = group.permissions.length;
                          final selectedCount = group.permissions
                              .where(
                                (permission) =>
                                    _selected.contains(permission.id),
                              )
                              .length;

                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppColors.creamStroke.withValues(
                                  alpha: 0.22,
                                ),
                              ),
                              color: AppColors.whiteWarm.withValues(
                                alpha: 0.72,
                              ),
                            ),
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                10,
                                0,
                                10,
                                10,
                              ),
                              title: Text(
                                group.group,
                                style: const TextStyle(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              subtitle: Text(
                                '$selectedCount de $total seleccionados',
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              trailing: Checkbox(
                                value: total > 0 && selectedCount == total,
                                tristate: true,
                                onChanged: (_) =>
                                    _toggleAll(group, selectedCount != total),
                              ),
                              children: group.permissions
                                  .map(
                                    (permission) => CheckboxListTile(
                                      value: _selected.contains(permission.id),
                                      title: Text(
                                        permission.name,
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selected.add(permission.id);
                                          } else {
                                            _selected.remove(permission.id);
                                          }
                                        });
                                      },
                                    ),
                                  )
                                  .toList(),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: () =>
                        Navigator.pop(context, _selected.toList()..sort()),
                    child: const Text('Guardar permisos'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
