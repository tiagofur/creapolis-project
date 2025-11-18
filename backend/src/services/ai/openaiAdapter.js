import axios from "axios";

const CATEGORY_NAMES = [
  "DEVELOPMENT",
  "DESIGN",
  "TESTING",
  "DOCUMENTATION",
  "MEETING",
  "BUG",
  "FEATURE",
  "MAINTENANCE",
  "RESEARCH",
  "DEPLOYMENT",
  "REVIEW",
  "PLANNING",
];

function buildPrompt(text) {
  return `You are an assistant that classifies a task into one of these categories: ${CATEGORY_NAMES.join(
    ", "
  )}.
Text: "${text}"
Return JSON with keys: suggestedCategory (one of categories), confidence (0-1), reasoning (short), keywords (array).`;
}

export async function suggestCategory(text) {
  const apiKey = process.env.OPENAI_API_KEY;
  const model = process.env.OPENAI_MODEL || "gpt-4o-mini";
  if (!apiKey) return null;
  try {
    const res = await axios.post(
      "https://api.openai.com/v1/chat/completions",
      {
        model,
        messages: [
          { role: "system", content: "Classify tasks into predefined categories." },
          { role: "user", content: buildPrompt(text) },
        ],
        response_format: { type: "json_object" },
        temperature: 0.2,
      },
      {
        headers: {
          Authorization: `Bearer ${apiKey}`,
        },
        timeout: 5000,
      }
    );

    const content = res.data?.choices?.[0]?.message?.content;
    if (!content) return null;
    const parsed = JSON.parse(content);
    if (!CATEGORY_NAMES.includes(parsed.suggestedCategory)) return null;
    return parsed;
  } catch (e) {
    return null;
  }
}

export function train() {
  return true;
}

export default {
  suggestCategory,
  train,
};