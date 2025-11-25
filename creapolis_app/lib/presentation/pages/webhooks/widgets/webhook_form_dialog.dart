import 'package:flutter/material.dart';

import '../../../../domain/entities/webhook.dart';

/// Form dialog for creating/editing a webhook
class WebhookFormDialog extends StatefulWidget {
  final int workspaceId;
  final Webhook? webhook;

  const WebhookFormDialog({super.key, required this.workspaceId, this.webhook});

  @override
  State<WebhookFormDialog> createState() => _WebhookFormDialogState();
}

class _WebhookFormDialogState extends State<WebhookFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _urlController;
  late Set<String> _selectedEvents;
  late Map<String, String> _headers;

  bool get isEditing => widget.webhook != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.webhook?.name ?? '');
    _urlController = TextEditingController(text: widget.webhook?.url ?? '');
    _selectedEvents = Set.from(widget.webhook?.events ?? []);
    _headers = Map.from(widget.webhook?.headers ?? {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.webhook, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      isEditing ? 'Edit Webhook' : 'Create Webhook',
                      style: theme.textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name field
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Webhook Name',
                            hintText: 'Enter a descriptive name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // URL field
                        TextFormField(
                          controller: _urlController,
                          decoration: const InputDecoration(
                            labelText: 'Endpoint URL',
                            hintText: 'https://your-server.com/webhook',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.url,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a URL';
                            }
                            final uri = Uri.tryParse(value);
                            if (uri == null || !uri.hasScheme) {
                              return 'Please enter a valid URL';
                            }
                            if (uri.scheme != 'http' && uri.scheme != 'https') {
                              return 'URL must use HTTP or HTTPS';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Events section
                        Text(
                          'Events to Subscribe',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select the events that will trigger this webhook.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Event categories
                        ...WebhookEvent.groupedEvents.entries.map(
                          (entry) => _buildEventCategory(
                            context,
                            entry.key,
                            entry.value,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Headers section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Custom Headers (Optional)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _addHeader,
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Add Header'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ..._headers.entries.map(
                          (entry) =>
                              _buildHeaderRow(context, entry.key, entry.value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _selectedEvents.isEmpty ? null : _submit,
                      child: Text(isEditing ? 'Update' : 'Create'),
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

  Widget _buildEventCategory(
    BuildContext context,
    String category,
    List<WebhookEvent> events,
  ) {
    final theme = Theme.of(context);
    final allSelected = events.every((e) => _selectedEvents.contains(e.value));
    final someSelected = events.any((e) => _selectedEvents.contains(e.value));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header with select all
          InkWell(
            onTap: () {
              setState(() {
                if (allSelected) {
                  for (final event in events) {
                    _selectedEvents.remove(event.value);
                  }
                } else {
                  for (final event in events) {
                    _selectedEvents.add(event.value);
                  }
                }
              });
            },
            child: Row(
              children: [
                Checkbox(
                  value: allSelected ? true : (someSelected ? null : false),
                  tristate: true,
                  onChanged: (value) {
                    setState(() {
                      if (value == true || value == null) {
                        for (final event in events) {
                          _selectedEvents.add(event.value);
                        }
                      } else {
                        for (final event in events) {
                          _selectedEvents.remove(event.value);
                        }
                      }
                    });
                  },
                ),
                Text(
                  category,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Event checkboxes
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Wrap(
              spacing: 0,
              children: events.map((event) {
                return SizedBox(
                  width: 250,
                  child: CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      event.displayName,
                      style: theme.textTheme.bodySmall,
                    ),
                    value: _selectedEvents.contains(event.value),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          _selectedEvents.add(event.value);
                        } else {
                          _selectedEvents.remove(event.value);
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, String key, String value) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                key,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Text(':'),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 18),
            onPressed: () => _editHeader(key, value),
          ),
          IconButton(
            icon: Icon(Icons.delete, size: 18, color: theme.colorScheme.error),
            onPressed: () {
              setState(() => _headers.remove(key));
            },
          ),
        ],
      ),
    );
  }

  void _addHeader() async {
    final result = await _showHeaderDialog(context);
    if (result != null) {
      setState(() {
        _headers[result['key']!] = result['value']!;
      });
    }
  }

  void _editHeader(String key, String value) async {
    final result = await _showHeaderDialog(context, key: key, value: value);
    if (result != null) {
      setState(() {
        _headers.remove(key);
        _headers[result['key']!] = result['value']!;
      });
    }
  }

  Future<Map<String, String>?> _showHeaderDialog(
    BuildContext context, {
    String? key,
    String? value,
  }) async {
    final keyController = TextEditingController(text: key);
    final valueController = TextEditingController(text: value);
    final formKey = GlobalKey<FormState>();

    return showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(key == null ? 'Add Header' : 'Edit Header'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'Header Name',
                  hintText: 'X-Custom-Header',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter header name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: valueController,
                decoration: const InputDecoration(labelText: 'Header Value'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter header value' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'key': keyController.text,
                  'value': valueController.text,
                });
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedEvents.isNotEmpty) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'url': _urlController.text.trim(),
        'events': _selectedEvents.toList(),
        'headers': _headers.isEmpty ? null : _headers,
      });
    } else if (_selectedEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one event')),
      );
    }
  }
}
