import * as vscode from 'vscode';
import api, { setAuthToken } from './api';
import { CreapolisTreeDataProvider, ProjectItem, TaskItem } from './treeDataProvider';

const CREAPOLIS_TOKEN_KEY = 'creapolis_token';

let timer: NodeJS.Timeout | undefined;
let timerStatusBarItem: vscode.StatusBarItem;
let activeTask: TaskItem | undefined;

export async function activate(context: vscode.ExtensionContext) {
  console.log('Congratulations, your extension "ordo-todo" is now active!');

  const token = await context.secrets.get(CREAPOLIS_TOKEN_KEY);
  if (token) {
    setAuthToken(token);
  }

  const treeDataProvider = new CreapolisTreeDataProvider();
  vscode.window.registerTreeDataProvider('creapolisProjects', treeDataProvider);

  timerStatusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
  context.subscriptions.push(timerStatusBarItem);

  const loginCommand = vscode.commands.registerCommand('ordo-todo.login', async () => {
    const email = await vscode.window.showInputBox({ prompt: 'Enter your Creapolis email' });
    if (!email) return;

    const password = await vscode.window.showInputBox({ prompt: 'Enter your password', password: true });
    if (!password) return;

    try {
      const response = await api.post('/auth/login', { email, password });
      const { token } = response.data;
      await context.secrets.store(CREAPOLIS_TOKEN_KEY, token);
      setAuthToken(token);
      vscode.window.showInformationMessage('Successfully logged in to Creapolis!');
      treeDataProvider.refresh();
    } catch (error) {
      vscode.window.showErrorMessage('Failed to log in to Creapolis. Please check your credentials.');
    }
  });

  const logoutCommand = vscode.commands.registerCommand('ordo-todo.logout', async () => {
    await context.secrets.delete(CREAPOLIS_TOKEN_KEY);
    setAuthToken(null);
    vscode.window.showInformationMessage('Successfully logged out from Creapolis.');
    treeDataProvider.refresh();
  });

  const getProjectsCommand = vscode.commands.registerCommand('ordo-todo.getProjects', async () => {
    try {
      const response = await api.get('/projects');
      const projects = response.data.map((project: any) => project.name).join(', ');
      vscode.window.showInformationMessage(`Projects: ${projects}`);
    } catch (error) {
      vscode.window.showErrorMessage('Failed to fetch projects. Are you logged in?');
    }
  });

  const refreshCommand = vscode.commands.registerCommand('ordo-todo.refresh', () => {
    treeDataProvider.refresh();
  });

  const createTaskCommand = vscode.commands.registerCommand('ordo-todo.createTask', async (projectItem?: ProjectItem) => {
    let projectId: any;
    if (projectItem) {
      projectId = projectItem.id;
    } else {
      const projects = await api.get('/projects');
      const projectNames = projects.data.map((p: any) => p.name);
      const selectedProjectName = await vscode.window.showQuickPick(projectNames, {
        placeHolder: 'Select a project for the new task'
      });
      if (!selectedProjectName) return;
      const selectedProject = projects.data.find((p: any) => p.name === selectedProjectName);
      projectId = selectedProject.id;
    }

    const taskTitle = await vscode.window.showInputBox({ prompt: 'Enter the task title' });
    if (!taskTitle) return;

    try {
      await api.post(`/projects/${projectId}/tasks`, { title: taskTitle });
      vscode.window.showInformationMessage(`Task "${taskTitle}" created successfully.`);
      treeDataProvider.refresh();
    } catch (error) {
      vscode.window.showErrorMessage('Failed to create task.');
    }
  });

  const startTimerCommand = vscode.commands.registerCommand('ordo-todo.startTimer', async (taskItem?: TaskItem) => {
    if (timer) {
      vscode.window.showWarningMessage('A timer is already running.');
      return;
    }

    if (!taskItem) {
        // If not started from context menu, let user select a task
        // This part needs implementation of fetching all tasks or recent tasks
        vscode.window.showInformationMessage("Please start the timer from the context menu of a task.");
        return;
    }
    
    activeTask = taskItem;

    try {
      await api.post(`/timelogs/start/${taskItem.id}`);
      let seconds = 0;
      timer = setInterval(() => {
        seconds++;
        const time = new Date(seconds * 1000).toISOString().substr(11, 8);
        timerStatusBarItem.text = `$(watch) ${taskItem.label}: ${time}`;
        timerStatusBarItem.show();
      }, 1000);
      vscode.window.showInformationMessage(`Timer started for task "${taskItem.label}".`);
    } catch (error) {
      vscode.window.showErrorMessage('Failed to start timer.');
    }
  });

  const stopTimerCommand = vscode.commands.registerCommand('ordo-todo.stopTimer', async () => {
    if (!timer || !activeTask) {
      vscode.window.showWarningMessage('No timer is currently running.');
      return;
    }

    try {
        await api.post(`/timelogs/stop/${activeTask.id}`);
        clearInterval(timer);
        timer = undefined;
        timerStatusBarItem.hide();
        vscode.window.showInformationMessage(`Timer stopped for task "${activeTask.label}".`);
        activeTask = undefined;
    } catch(error) {
        vscode.window.showErrorMessage('Failed to stop timer.');
    }
  });

  timerStatusBarItem.command = 'ordo-todo.stopTimer';

  context.subscriptions.push(loginCommand, logoutCommand, getProjectsCommand, refreshCommand, createTaskCommand, startTimerCommand, stopTimerCommand);
}

export function deactivate() {
    if (timer) {
        clearInterval(timer);
    }
}
