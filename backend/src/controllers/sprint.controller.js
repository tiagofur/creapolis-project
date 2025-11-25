import sprintService from "../services/sprint.service.js";
import { asyncHandler } from "../middleware/async.js";

export const createSprint = asyncHandler(async (req, res) => {
  const sprint = await sprintService.createSprint(req.user.id, req.body);
  res.status(201).json(sprint);
});

export const getSprintsByProject = asyncHandler(async (req, res) => {
  const { projectId } = req.params;
  const { status } = req.query;
  const sprints = await sprintService.getSprintsByProject(
    req.user.id,
    parseInt(projectId),
    { status }
  );
  res.json(sprints);
});

export const getSprintById = asyncHandler(async (req, res) => {
  const sprint = await sprintService.getSprintById(req.user.id, req.params.id);
  res.json(sprint);
});

export const updateSprint = asyncHandler(async (req, res) => {
  const sprint = await sprintService.updateSprint(
    req.user.id,
    req.params.id,
    req.body
  );
  res.json(sprint);
});

export const deleteSprint = asyncHandler(async (req, res) => {
  const result = await sprintService.deleteSprint(req.user.id, req.params.id);
  res.json(result);
});

export const addTasksToSprint = asyncHandler(async (req, res) => {
  const { taskIds } = req.body;
  const result = await sprintService.addTasksToSprint(
    req.user.id,
    req.params.id,
    taskIds
  );
  res.json(result);
});

export const removeTasksFromSprint = asyncHandler(async (req, res) => {
  const { taskIds } = req.body;
  const result = await sprintService.removeTasksFromSprint(
    req.user.id,
    req.params.id,
    taskIds
  );
  res.json(result);
});

export const startSprint = asyncHandler(async (req, res) => {
  const sprint = await sprintService.startSprint(req.user.id, req.params.id);
  res.json(sprint);
});

export const completeSprint = asyncHandler(async (req, res) => {
  const sprint = await sprintService.completeSprint(req.user.id, req.params.id);
  res.json(sprint);
});

export const getBacklog = asyncHandler(async (req, res) => {
  const { projectId } = req.params;
  const tasks = await sprintService.getBacklog(req.user.id, projectId);
  res.json(tasks);
});
