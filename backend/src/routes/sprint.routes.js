import express from "express";
import * as sprintController from "../controllers/sprint.controller.js";
import { protect } from "../middleware/auth.js";

const router = express.Router();

router.use(protect);

router.post("/", sprintController.createSprint);
router.get("/project/:projectId", sprintController.getSprintsByProject);
router.get("/project/:projectId/backlog", sprintController.getBacklog);
router.get("/:id", sprintController.getSprintById);
router.put("/:id", sprintController.updateSprint);
router.delete("/:id", sprintController.deleteSprint);

router.post("/:id/tasks", sprintController.addTasksToSprint);
router.delete("/:id/tasks", sprintController.removeTasksFromSprint);

router.post("/:id/start", sprintController.startSprint);
router.post("/:id/complete", sprintController.completeSprint);

export default router;
