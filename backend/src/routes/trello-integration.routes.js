import express from "express";
import trelloIntegrationController from "../controllers/trello-integration.controller.js";
import { authenticate } from "../middleware/auth.middleware.js";
import { validate } from "../middleware/validation.middleware.js";
import { body, query, param } from "express-validator";

const router = express.Router();

/**
 * @route   GET /api/integrations/trello/connect
 * @desc    Get Trello OAuth authorization URL
 * @access  Private
 */
router.get("/connect", authenticate, trelloIntegrationController.connect);

/**
 * @route   GET /api/integrations/trello/callback
 * @desc    OAuth callback handler
 * @access  Public (called by Trello)
 */
router.get("/callback", trelloIntegrationController.callback);

/**
 * @route   POST /api/integrations/trello/tokens
 * @desc    Save Trello token
 * @access  Private
 */
router.post(
  "/tokens",
  authenticate,
  [body("token").notEmpty().withMessage("Token is required")],
  validate,
  trelloIntegrationController.saveTokens
);

/**
 * @route   DELETE /api/integrations/trello/disconnect
 * @desc    Disconnect Trello integration
 * @access  Private
 */
router.delete("/disconnect", authenticate, trelloIntegrationController.disconnect);

/**
 * @route   GET /api/integrations/trello/status
 * @desc    Get Trello connection status
 * @access  Private
 */
router.get("/status", authenticate, trelloIntegrationController.getStatus);

/**
 * @route   GET /api/integrations/trello/boards
 * @desc    Get list of Trello boards
 * @access  Private
 */
router.get("/boards", authenticate, trelloIntegrationController.getBoards);

/**
 * @route   GET /api/integrations/trello/boards/:boardId
 * @desc    Get board details with lists and cards
 * @access  Private
 */
router.get(
  "/boards/:boardId",
  authenticate,
  [param("boardId").notEmpty().withMessage("Board ID is required")],
  validate,
  trelloIntegrationController.getBoardDetails
);

/**
 * @route   POST /api/integrations/trello/cards
 * @desc    Create a new card
 * @access  Private
 */
router.post(
  "/cards",
  authenticate,
  [
    body("listId").notEmpty().withMessage("List ID is required"),
    body("name").notEmpty().withMessage("Card name is required"),
    body("desc").optional().isString(),
    body("due").optional().isISO8601(),
    body("labels").optional().isArray(),
  ],
  validate,
  trelloIntegrationController.createCard
);

/**
 * @route   PUT /api/integrations/trello/cards/:cardId
 * @desc    Update a card
 * @access  Private
 */
router.put(
  "/cards/:cardId",
  authenticate,
  [
    param("cardId").notEmpty().withMessage("Card ID is required"),
    body("name").optional().isString(),
    body("desc").optional().isString(),
    body("due").optional().isISO8601(),
    body("idList").optional().isString(),
  ],
  validate,
  trelloIntegrationController.updateCard
);

/**
 * @route   GET /api/integrations/trello/logs
 * @desc    Get integration activity logs
 * @access  Private
 */
router.get(
  "/logs",
  authenticate,
  [
    query("limit").optional().isInt({ min: 1, max: 100 }),
    query("action").optional().isString(),
    query("status").optional().isIn(["SUCCESS", "FAILED", "PENDING"]),
  ],
  validate,
  trelloIntegrationController.getLogs
);

export default router;
