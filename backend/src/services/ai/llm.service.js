import axios from "axios";

/**
 * LLM Service
 * Centralized service for interacting with Large Language Models (OpenAI, etc.)
 */
class LLMService {
  constructor() {
    this.apiKey = process.env.OPENAI_API_KEY;
    this.model = process.env.OPENAI_MODEL || "gpt-4o";
    this.baseUrl = "https://api.openai.com/v1/chat/completions";
  }

  /**
   * Check if LLM service is configured and available
   */
  isAvailable() {
    return !!this.apiKey;
  }

  /**
   * Send a prompt to the LLM and get a JSON response
   * @param {string} systemPrompt - The system instructions
   * @param {string} userPrompt - The user's input
   * @param {Object} options - Additional options (temperature, model, etc.)
   */
  async generateJSON(systemPrompt, userPrompt, options = {}) {
    if (!this.isAvailable()) {
      throw new Error("LLM Service not configured (missing API Key)");
    }

    try {
      const response = await axios.post(
        this.baseUrl,
        {
          model: options.model || this.model,
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: userPrompt },
          ],
          response_format: { type: "json_object" },
          temperature: options.temperature || 0.2,
        },
        {
          headers: {
            Authorization: `Bearer ${this.apiKey}`,
            "Content-Type": "application/json",
          },
          timeout: 30000, // 30 seconds timeout
        }
      );

      const content = response.data.choices[0].message.content;
      return JSON.parse(content);
    } catch (error) {
      console.error(
        "LLM Service Error:",
        error.response?.data || error.message
      );
      throw error;
    }
  }

  /**
   * Send a prompt to the LLM and get a text response
   */
  async generateText(systemPrompt, userPrompt, options = {}) {
    if (!this.isAvailable()) {
      throw new Error("LLM Service not configured");
    }

    try {
      const response = await axios.post(
        this.baseUrl,
        {
          model: options.model || this.model,
          messages: [
            { role: "system", content: systemPrompt },
            { role: "user", content: userPrompt },
          ],
          temperature: options.temperature || 0.7,
        },
        {
          headers: {
            Authorization: `Bearer ${this.apiKey}`,
            "Content-Type": "application/json",
          },
          timeout: 30000,
        }
      );

      return response.data.choices[0].message.content;
    } catch (error) {
      console.error(
        "LLM Service Error:",
        error.response?.data || error.message
      );
      throw error;
    }
  }
}

export default new LLMService();
