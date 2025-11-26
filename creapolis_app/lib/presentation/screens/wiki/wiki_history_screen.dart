import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/services/wiki_service.dart';
import '../../../domain/entities/wiki_document_version.dart';
import '../../../injection.dart';
import '../../widgets/feedback/feedback_widgets.dart';
import '../../widgets/loading/skeleton_list.dart';

class WikiHistoryScreen extends StatefulWidget {
  final int documentId;
  final String documentTitle;

  const WikiHistoryScreen({
    super.key,
    required this.documentId,
    required this.documentTitle,
  });

  @override
  State<WikiHistoryScreen> createState() => _WikiHistoryScreenState();
}

class _WikiHistoryScreenState extends State<WikiHistoryScreen> {
  final WikiService _wikiService = getIt<WikiService>();
  List<WikiDocumentVersion> _versions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    setState(() {
      _isLoading = true;
    });
    _versions = await _wikiService.getWikiDocumentVersions(widget.documentId);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.documentTitle} - History'),
      ),
      body: _isLoading
          ? SkeletonList(itemCount: 5)
          : (_versions.isEmpty
              ? _buildEmptyState(context)
              : _buildVersionsList()),
    );
  }

  Widget _buildVersionsList() {
    return RefreshIndicator(
      onRefresh: _loadVersions,
      child: ListView.builder(
        itemCount: _versions.length,
        itemBuilder: (context, index) {
          final version = _versions[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Version ${version.versionNumber}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text('Edited by: ${version.editorName}'),
                  Text(
                    'Edited at: ${DateFormat('MMM dd, yyyy - HH:mm').format(version.editedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    version.content.substring(0, (version.content.length > 100 ? 100 : version.content.length)) + '...', // Show a snippet
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement view full version content
                        context.showInfo('View full content of version ${version.versionNumber} (TODO)');
                      },
                      child: const Text('View Details'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Version History Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('No previous versions for this document.'),
        ],
      ),
    );
  }
}
