import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/wiki_service.dart';
import '../../../domain/entities/wiki_document.dart';
import '../../../injection.dart';
import '../../providers/workspace_context.dart';
import '../../widgets/feedback/feedback_widgets.dart';
import '../../widgets/loading/skeleton_list.dart';

class WikiListScreen extends StatefulWidget {
  const WikiListScreen({super.key});

  @override
  State<WikiListScreen> createState() => _WikiListScreenState();
}

class _WikiListScreenState extends State<WikiListScreen> {
  final WikiService _wikiService = getIt<WikiService>();
  List<WikiDocument> _documents = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
    });
    final workspaceContext = context.read<WorkspaceContext>();
    final activeWorkspaceId = workspaceContext.activeWorkspace?.id;

    if (activeWorkspaceId != null) {
      _documents = await _wikiService.getWikiDocuments(
        workspaceId: activeWorkspaceId,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
    } else {
      _documents = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspaceContext = context.watch<WorkspaceContext>();
    final hasActiveWorkspace = workspaceContext.hasActiveWorkspace;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiki Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WikiEditorScreen()),
              );
              if (result == true) {
                _loadDocuments();
              }
            },
        ],
      ),
      body: _isLoading
          ? SkeletonList(itemCount: 5)
          : hasActiveWorkspace
              ? (_documents.isEmpty
                  ? _buildEmptyState(context)
                  : _buildDocumentList())
              : _buildNoWorkspaceState(context),
    );
  }

  Widget _buildDocumentList() {
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          final document = _documents[index];
          return ListTile(
            title: Text(document.title),
            subtitle: Text(document.tags.join(', ')),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WikiEditorScreen(document: document),
                ),
              );
              if (result == true) {
                _loadDocuments();
              }
            },
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
          const Icon(Icons.description, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No Wiki Documents Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          const Text('Create your first wiki document.'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const WikiEditorScreen()),
              );
              if (result == true) {
                _loadDocuments();
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Document'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoWorkspaceState(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspaces_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No Active Workspace',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Please select an active workspace to view wiki documents.'),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Wiki Documents'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search by title or content...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          onSubmitted: (value) {
            Navigator.pop(context);
            _loadDocuments();
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _searchQuery = '';
              });
              _loadDocuments();
            },
            child: const Text('Clear Search'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _loadDocuments();
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
