import 'package:flutter/material.dart';
import '../../../domain/entities/project_role.dart';

/// Widget to display permissions in a visual matrix format
class PermissionsMatrix extends StatelessWidget {
  final List<ProjectPermission> permissions;
  final bool readOnly;
  final Function(String resource, String action, bool granted)? onPermissionChanged;

  const PermissionsMatrix({
    super.key,
    required this.permissions,
    this.readOnly = true,
    this.onPermissionChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Group permissions by resource
    final Map<String, Map<String, bool>> permissionMap = {};

    for (final resource in PermissionResource.all) {
      permissionMap[resource] = {};
      for (final action in PermissionAction.all) {
        permissionMap[resource]![action] = false;
      }
    }

    // Fill in existing permissions
    for (final permission in permissions) {
      if (permissionMap.containsKey(permission.resource)) {
        permissionMap[permission.resource]![permission.action] =
            permission.granted;
      }
    }

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            Theme.of(context).primaryColor.withValues(alpha: 0.1),
          ),
          columns: [
            const DataColumn(
              label: Text(
                'Recurso',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...PermissionAction.all.map((action) {
              return DataColumn(
                label: Text(
                  PermissionAction.getDisplayName(action),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
          ],
          rows: PermissionResource.all.map((resource) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    PermissionResource.getDisplayName(resource),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                ...PermissionAction.all.map((action) {
                  final hasPermission = permissionMap[resource]![action]!;
                  return DataCell(
                    readOnly
                        ? Icon(
                            hasPermission
                                ? Icons.check_circle
                                : Icons.cancel,
                            color: hasPermission ? Colors.green : Colors.grey,
                          )
                        : Checkbox(
                            value: hasPermission,
                            onChanged: (value) {
                              onPermissionChanged?.call(
                                resource,
                                action,
                                value ?? false,
                              );
                            },
                          ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Widget to display a summary of permissions
class PermissionsSummary extends StatelessWidget {
  final List<ProjectPermission> permissions;

  const PermissionsSummary({
    super.key,
    required this.permissions,
  });

  @override
  Widget build(BuildContext context) {
    final groupedPermissions = <String, List<ProjectPermission>>{};

    for (final permission in permissions) {
      if (!groupedPermissions.containsKey(permission.resource)) {
        groupedPermissions[permission.resource] = [];
      }
      if (permission.granted) {
        groupedPermissions[permission.resource]!.add(permission);
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: groupedPermissions.entries.map((entry) {
        return Chip(
          avatar: CircleAvatar(
            backgroundColor: Colors.blue[700],
            child: Text(
              entry.value.length.toString(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          label: Text(PermissionResource.getDisplayName(entry.key)),
          backgroundColor: Colors.blue[50],
        );
      }).toList(),
    );
  }
}

/// Widget to display a single permission badge
class PermissionBadge extends StatelessWidget {
  final String resource;
  final String action;
  final bool granted;

  const PermissionBadge({
    super.key,
    required this.resource,
    required this.action,
    this.granted = true,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        granted ? Icons.check_circle : Icons.cancel,
        color: granted ? Colors.green : Colors.red,
        size: 18,
      ),
      label: Text(
        '${PermissionResource.getDisplayName(resource)} - ${PermissionAction.getDisplayName(action)}',
      ),
      backgroundColor: granted ? Colors.green[50] : Colors.red[50],
    );
  }
}



