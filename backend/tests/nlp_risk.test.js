import { jest } from "@jest/globals";

// Mock llmService using unstable_mockModule for ESM support
await jest.unstable_mockModule("../src/services/ai/llm.service.js", () => ({
  default: {
    isAvailable: jest.fn(),
    generateJSON: jest.fn(),
  },
}));

// Import the module under test AFTER mocking
const { analyzeProjectRisk, generateDailySummary } = await import(
  "../src/services/ai/nlpService.js"
);
const { default: llmService } = await import(
  "../src/services/ai/llm.service.js"
);

describe("NLP Service - Risk Analysis", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("analyzeProjectRisk should call llmService.generateJSON", async () => {
    const mockProjectData = {
      name: "Test Project",
      description: "A test project",
      tasks: [],
    };

    const mockResponse = {
      riskLevel: "LOW",
      summary: "Low risk project",
      risks: [],
      recommendations: [],
    };

    llmService.isAvailable.mockReturnValue(true);
    llmService.generateJSON.mockResolvedValue(mockResponse);

    const result = await analyzeProjectRisk(mockProjectData);

    expect(llmService.isAvailable).toHaveBeenCalled();
    expect(llmService.generateJSON).toHaveBeenCalledWith(
      expect.stringContaining("You are a senior project manager AI"),
      JSON.stringify(mockProjectData)
    );
    expect(result).toEqual(mockResponse);
  });

  test("analyzeProjectRisk should throw error if LLM is not available", async () => {
    llmService.isAvailable.mockReturnValue(false);

    await expect(analyzeProjectRisk({})).rejects.toThrow(
      "LLM Service required for risk analysis"
    );
  });
});

describe("NLP Service - Daily Summary", () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  test("generateDailySummary should call llmService.generateJSON with activities", async () => {
    const mockActivities = [
      {
        action: "CREATE",
        entityType: "TASK",
        details: "Created task A",
        createdAt: new Date(),
      },
      {
        action: "UPDATE",
        entityType: "PROJECT",
        details: "Updated project B",
        createdAt: new Date(),
      },
    ];
    const mockUserName = "Test User";

    const mockResponse = {
      summary: "Yesterday I created task A and updated project B.",
      highlights: ["Created task A"],
      nextSteps: [],
    };

    llmService.isAvailable.mockReturnValue(true);
    llmService.generateJSON.mockResolvedValue(mockResponse);

    const result = await generateDailySummary(mockActivities, mockUserName);

    expect(llmService.isAvailable).toHaveBeenCalled();
    expect(llmService.generateJSON).toHaveBeenCalledWith(
      expect.stringContaining(
        "You are an AI assistant generating a daily standup summary"
      ),
      expect.stringContaining("Created task A")
    );
    expect(result).toEqual(mockResponse);
  });

  test("generateDailySummary should return default message if no activities", async () => {
    llmService.isAvailable.mockReturnValue(true);

    const result = await generateDailySummary([], "Test User");

    expect(result.summary).toContain("No activity recorded");
    expect(llmService.generateJSON).not.toHaveBeenCalled();
  });
});
