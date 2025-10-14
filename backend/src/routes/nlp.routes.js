import express from 'express';
import nlpController from '../controllers/nlp.controller.js';
import { authenticate } from '../middleware/auth.middleware.js';
import { body } from 'express-validator';
import { validate } from '../middleware/validation.middleware.js';

const router = express.Router();

// All routes require authentication
router.use(authenticate);

/**
 * @route   POST /api/nlp/parse-task-instruction
 * @desc    Parse natural language instruction into structured task data
 * @access  Private
 */
router.post(
  '/parse-task-instruction',
  [
    body('instruction')
      .trim()
      .notEmpty()
      .withMessage('Instruction text is required')
      .isLength({ min: 5, max: 1000 })
      .withMessage('Instruction must be between 5 and 1000 characters')
  ],
  validate,
  nlpController.parseInstruction
);

/**
 * @route   GET /api/nlp/examples
 * @desc    Get usage examples for NLP task creation
 * @access  Private
 */
router.get('/examples', nlpController.getExamples);

/**
 * @route   GET /api/nlp/info
 * @desc    Get NLP service information and capabilities
 * @access  Private
 */
router.get('/info', nlpController.getInfo);

export default router;
