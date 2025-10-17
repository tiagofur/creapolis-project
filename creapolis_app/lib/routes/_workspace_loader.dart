import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../../features/workspace/data/models/workspace_model.dart';
import '../presentation/screens/workspace/workspace_detail_screen.dart';

class WorkspaceLoader extends StatefulWidget {
  final int workspaceId;
  const WorkspaceLoader({required this.workspaceId});

  @override
  State<WorkspaceLoader> createState() => WorkspaceLoaderState();
}

class WorkspaceLoaderState extends State<WorkspaceLoader> {
  Workspace? _workspace;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWorkspace();
  }

  Future<void> _fetchWorkspace() async {
    final repo = GetIt.I<WorkspaceRepository>();
    final result = await repo.getWorkspace(widget.workspaceId);
    result.fold(
      (failure) => setState(() {
        _error = failure.toString();
        _loading = false;
      }),
      (workspace) => setState(() {
        _workspace = workspace;
        _loading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }
    if (_workspace == null) {
      return const Scaffold(
        body: Center(child: Text('Workspace no encontrado')),
      );
    }
    return WorkspaceDetailScreen(workspace: _workspace!);
  }
}
