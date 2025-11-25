import {
  parseTaskInstruction,
  analyzeProjectRisk,
  generateDailySummary,
  getUsageExamples,
} from "../services/ai/nlpService.js";
import auditService from "../services/audit.service.js";
import { successResponse, asyncHandler } from "../utils/response.js";

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

    if (!instruction || typeof instruction !== "string") {
      return res.status(400).json({
        success: false,
        message: "Instruction text is required",
      });
    }

    const result = await parseTaskInstruction(instruction);

    return successResponse(res, result, "Instruction parsed successfully");
  });

  /**
   * Analyze project risks using AI
   * POST /api/nlp/analyze-risk
   */
  analyzeRisk = asyncHandler(async (req, res) => {
    const { projectData } = req.body;

    if (!projectData) {
      return res.status(400).json({
        success: false,
        message: "Project data is required",
      });
    }

    const result = await analyzeProjectRisk(projectData);

    return successResponse(
      res,
      result,
      "Project risk analysis completed successfully"
    );
  });

  /**
   * Generate daily standup summary
   * POST /api/nlp/generate-summary
   */
  generateSummary = asyncHandler(async (req, res) => {
    const { date } = req.body;
    const userId = req.user.id;
    const userName = req.user.name || "User";

    let startDate, endDate;
    if (date) {
      startDate = new Date(date);
      startDate.setHours(0, 0, 0, 0);
      endDate = new Date(date);
      endDate.setHours(23, 59, 59, 999);
    } else {
      // Default to last 24 hours
      endDate = new Date();
      startDate = new Date();
      startDate.setDate(startDate.getDate() - 1);
    }

    const activities = await auditService.getUserActivityLogs(
      userId,
      startDate,
      endDate
    );
    const result = await generateDailySummary(activities, userName);

    return successResponse(res, result, "Daily summary generated successfully");
  });

  /**
   * Get usage examples for NLP task creation
   * GET /api/nlp/examples
   */
  getExamples = asyncHandler(async (req, res) => {
    const examples = getUsageExamples();

    return successResponse(res, examples, "Examples retrieved successfully");
  });

  /**
   * Get NLP service information and capabilities
   * GET /api/nlp/info
   */
  getInfo = asyncHandler(async (req, res) => {
    const info = {
      version: "1.0.0",
      capabilities: {
        languages: ["Spanish", "English"],
        extractableFields: [
          "title",
          "description",
          "priority",
          "dueDate",
          "assignee",
          "category",
        ],
        priorityLevels: ["LOW", "MEDIUM", "HIGH"],
        supportedDateFormats: [
          "Relative dates (hoy, mañana, today, tomorrow)",
          "Weekdays (lunes, viernes, monday, friday)",
          "Absolute dates (25 de octubre, October 25)",
          "ISO format (2024-10-25)",
          "DD/MM/YYYY or DD-MM-YYYY",
        ],
      },
      features: [
        "Automatic task categorization",
        "Multi-language support (Spanish/English)",
        "Confidence scores for each extracted field",
        "Flexible date parsing",
        "Priority detection",
        "Assignee extraction",
      ],
    };

    return successResponse(
      res,
      info,
      "NLP service information retrieved successfully"
    );
  });
}

export default new NLPController();
