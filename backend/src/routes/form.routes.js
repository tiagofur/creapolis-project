const express = require("express");
const router = express.Router();
const formController = require("../controllers/form.controller");
const authMiddleware = require("../middleware/auth.middleware");

// Protected routes (require auth)
router.post(
  "/projects/:projectId/forms",
  authMiddleware,
  formController.createForm
);
router.get(
  "/projects/:projectId/forms",
  authMiddleware,
  formController.getFormsByProject
);
router.get("/forms/:formId", authMiddleware, formController.getFormById);
router.put("/forms/:formId", authMiddleware, formController.updateForm);
router.delete("/forms/:formId", authMiddleware, formController.deleteForm);

// Public routes (no auth required)
router.get("/public/forms/:publicLink", formController.getPublicForm);
router.post(
  "/public/forms/:publicLink/submit",
  formController.submitPublicForm
);

module.exports = router;
