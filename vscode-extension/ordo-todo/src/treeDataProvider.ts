import * as vscode from 'vscode';
import api from './api';

export class CreapolisTreeDataProvider implements vscode.TreeDataProvider<TreeItem> {
  private _onDidChangeTreeData: vscode.EventEmitter<TreeItem | undefined | null | void> = new vscode.EventEmitter<TreeItem | undefined | null | void>();
  readonly onDidChangeTreeData: vscode.Event<TreeItem | undefined | null | void> = this._onDidChangeTreeData.event;

  constructor() {}

  refresh(): void {
    this._onDidChangeTreeData.fire();
  }

  getTreeItem(element: TreeItem): vscode.TreeItem {
    return element;
  }

  async getChildren(element?: TreeItem): Promise<TreeItem[]> {
    if (element) {
      if (element.contextValue === 'project') {
        try {
          const response = await api.get(`/projects/${element.id}/tasks`);
          const tasks = response.data;
          return tasks.map((task: any) => new TaskItem(task.title, vscode.TreeItemCollapsibleState.None, task.id));
        } catch (error) {
          vscode.window.showErrorMessage(`Failed to fetch tasks for project ${element.label}.`);
          return [];
        }
      }
      return [];
    } else {
      // Fetch projects
      try {
        const response = await api.get('/projects');
        const projects = response.data;
        return projects.map((project: any) => new ProjectItem(project.name, vscode.TreeItemCollapsibleState.Collapsed, project.id));
      } catch (error) {
        vscode.window.showErrorMessage('Failed to fetch projects. Are you logged in?');
        return [];
      }
    }
  }

  getParent?(element: TreeItem): vscode.ProviderResult<TreeItem> {
    return null;
  }
}

export class TreeItem extends vscode.TreeItem {
  constructor(
    public readonly label: string,
    public readonly collapsibleState: vscode.TreeItemCollapsibleState,
    public readonly id?: any,
  ) {
    super(label, collapsibleState);
  }
}

export class ProjectItem extends TreeItem {
    constructor(
        public readonly label: string,
        public readonly collapsibleState: vscode.TreeItemCollapsibleState,
        public readonly id: any,
    ) {
        super(label, collapsibleState);
    }

    contextValue = 'project';
}

export class TaskItem extends TreeItem {
    constructor(
        public readonly label: string,
        public readonly collapsibleState: vscode.TreeItemCollapsibleState,
        public readonly id: any,
    ) {
        super(label, collapsibleState);
    }

    contextValue = 'task';
}
