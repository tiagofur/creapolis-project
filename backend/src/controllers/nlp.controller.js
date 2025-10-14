import { parseTaskInstruction, getUsageExamples } from '../services/ai/nlpService.js';
import { successResponse, asyncHandler } from '../utils/response.js';

/**
 * NLP Controller
 * Handles natural language processing for task creation
 */
class NLPController {
  /**
   * Parse natural language instruction into structured task data
   * POST /api/nlp/parse-task-instruction
   */
  parseInstruction = asyncHandler(async (req, res) => {
    const { instruction } = req.body;
    
    if (!instruction || typeof instruction !== 'string') {
      return res.status(400).json({
        success: false,
        message: 'Instruction text is required'
      });
    }
    
    const result = parseTaskInstruction(instruction);
    
    return successResponse(
      res,
      result,
      'Instruction parsed successfully'
    );
  });
  
  /**
   * Get usage examples for NLP task creation
   * GET /api/nlp/examples
   */
  getExamples = asyncHandler(async (req, res) => {
    const examples = getUsageExamples();
    
    return successResponse(
      res,
      examples,
      'Examples retrieved successfully'
    );
  });
  
  /**
   * Get NLP service information and capabilities
   * GET /api/nlp/info
   */
  getInfo = asyncHandler(async (req, res) => {
    const info = {
      version: '1.0.0',
      capabilities: {
        languages: ['Spanish', 'English'],
        extractableFields: [
          'title',
          'description',
          'priority',
          'dueDate',
          'assignee',
          'category'
        ],
        priorityLevels: ['LOW', 'MEDIUM', 'HIGH'],
        supportedDateFormats: [
          'Relative dates (hoy, mañana, today, tomorrow)',
          'Weekdays (lunes, viernes, monday, friday)',
          'Absolute dates (25 de octubre, October 25)',
          'ISO format (2024-10-25)',
          'DD/MM/YYYY or DD-MM-YYYY'
        ]
      },
      features: [
        'Automatic task categorization',
        'Multi-language support (Spanish/English)',
        'Confidence scores for each extracted field',
        'Flexible date parsing',
        'Priority detection',
        'Assignee extraction'
      ]
    };
    
    return successResponse(
      res,
      info,
      'NLP service information retrieved successfully'
    );
  });
}

export default new NLPController();
