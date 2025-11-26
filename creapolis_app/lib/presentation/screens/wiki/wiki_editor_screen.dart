import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:provider/provider.dart';
import '../../../data/services/wiki_service.dart';
import '../../../domain/entities/wiki_document.dart';
import '../../../injection.dart';
import '../../providers/workspace_context.dart';
import '../../widgets/feedback/feedback_widgets.dart';

class WikiEditorScreen extends StatefulWidget {
  final WikiDocument? document;

  const WikiEditorScreen({super.key, this.document});

  @override
  State<WikiEditorScreen> createState() => _WikiEditorScreenState();
}

class _WikiEditorScreenState extends State<WikiEditorScreen> {
  final WikiService _wikiService = getIt<WikiService>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController(); // For simplicity, comma-separated tags

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.document != null) {
      _titleController.text = widget.document!.title;
      _contentController.text = widget.document!.content;
      _tagsController.text = widget.document!.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveDocument() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      context.showError('Title and content cannot be empty.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspace = workspaceContext.activeWorkspace;
    final currentUser = workspaceContext.currentUser;

    if (activeWorkspace == null || currentUser == null) {
      context.showError('Active workspace or user not found.');
      setState(() {
        _isSaving = false;
      });
      return;
    }

    final tags = _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    if (widget.document == null) {
      // Create new document
      await _wikiService.createDocument(
        documentData: {
          'title': _titleController.text,
          'slug': _titleController.text.toLowerCase().replaceAll(' ', '-'), // Basic slug generation
          'content': _contentController.text,
          'workspaceId': activeWorkspace.id,
          'authorId': currentUser.id,
          'tags': tags,
        },
      );
      context.showSuccess('Document created successfully!');
    } else {
      // Update existing document
      await _wikiService.updateDocument(
        documentId: widget.document!.id,
        updateData: {
          'title': _titleController.text,
          'slug': _titleController.text.toLowerCase().replaceAll(' ', '-'),
          'content': _contentController.text,
          'tags': tags,
        },
        editorId: currentUser.id,
      );
      context.showSuccess('Document updated successfully!');
    }

    setState(() {
      _isSaving = false;
    });
    Navigator.of(context).pop(true); // Pop with true to indicate success
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document == null ? 'Create Wiki Document' : 'Edit Wiki Document'),
        actions: [
          IconButton(
            icon: _isSaving ? const CircularProgressIndicator() : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveDocument,
          ),
          if (widget.document != null)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => WikiHistoryScreen(
                      documentId: widget.document!.id,
                      documentTitle: widget.document!.title,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                labelText: 'Tags (comma-separated)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _contentController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      decoration: const InputDecoration(
                        labelText: 'Content (Markdown)',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: MarkdownPlus(data: _contentController.text),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
