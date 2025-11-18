import { setMLAdapter } from "./categorizationService.js";

async function initAdapter() {
  if (process.env.OPENAI_API_KEY) {
    try {
      const adapter = (await import("./openaiAdapter.js")).default;
      setMLAdapter(adapter);
    } catch (e) {}
  }
}

initAdapter();