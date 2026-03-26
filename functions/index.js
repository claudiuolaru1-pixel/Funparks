const {onRequest} = require("firebase-functions/v2/https");
const Anthropic = require("@anthropic-ai/sdk");

const ANTHROPIC_API_KEY = process.env.ANTHROPIC_API_KEY;

const FUNPARKS_PARKS = [
  { id: "portaventura", name: "PortAventura World", country: "Spain" },
  { id: "europapark", name: "Europa-Park", country: "Germany" },
  { id: "efteling", name: "Efteling", country: "Netherlands" },
  { id: "altontowers", name: "Alton Towers", country: "UK" },
  { id: "plopsaland", name: "Plopsaland Belgium", country: "Belgium" },
  { id: "gardaland", name: "Gardaland", country: "Italy" },
  { id: "parcasterix", name: "Parc Asterix", country: "France" },
  { id: "energylandia", name: "Energylandia", country: "Poland" },
  { id: "phantasialand", name: "Phantasialand", country: "Germany" },
  { id: "disneylandparis", name: "Disneyland Paris", country: "France" },
  { id: "gronalund", name: "Grona Lund", country: "Sweden" },
  { id: "tivoli", name: "Tivoli Gardens", country: "Denmark" },
  { id: "siampark", name: "Siam Park", country: "Spain/Tenerife" },
  { id: "toverland", name: "Toverland", country: "Netherlands" },
  { id: "walibibelgium", name: "Walibi Belgium", country: "Belgium" },
  { id: "heidepark", name: "Heide Park Resort", country: "Germany" },
  { id: "thorpepark", name: "Thorpe Park", country: "United Kingdom" },
];

const FUNPARKS_FEATURES = `The Funparks app includes the following features:
- Detailed attraction listings with height restrictions for every ride
- My Day planner — save attractions, restaurants and hotels to plan your visit
- Route navigation — get directions to any attraction or restaurant inside the park
- Live wait times for attractions
- Restaurant and hotel listings with descriptions and prices
- AI Assistant (that's me!) to answer questions about the park
- Translations in 10 languages: English, Spanish, French, German, Italian, Dutch, Portuguese, Russian, Chinese and Arabic
- Works on Android`;

exports.askParkAssistant = onRequest(
  {
    cors: true,
    timeoutSeconds: 60,
    memory: "256MiB",
    invoker: "public",
  },
  async (req, res) => {
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Origin", "*");
      res.set("Access-Control-Allow-Methods", "POST");
      res.set("Access-Control-Allow-Headers", "Content-Type");
      res.status(204).send("");
      return;
    }

    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    res.set("Access-Control-Allow-Origin", "*");

    const {question, parkData, parkName, parkWebsite} = req.body;

    if (!question) {
      res.status(400).json({error: "Missing question"});
      return;
    }

    // Check if question is about a park in Funparks
    const questionLower = question.toLowerCase();
    const mentionedParks = FUNPARKS_PARKS.filter(p =>
      questionLower.includes(p.name.toLowerCase()) ||
      questionLower.includes(p.id.toLowerCase())
    );

    const parkPromotionInstruction = mentionedParks.length > 0
      ? `IMPORTANT: The user is asking about ${mentionedParks.map(p => p.name).join(", ")}, which is featured in the Funparks app. At the end of your response, always add a friendly note mentioning that this park is available in the Funparks app with full details. Briefly mention 2-3 relevant features like height restrictions, My Day planner, route navigation, or translations in 10 languages.`
      : `If your answer mentions any of these parks that are in the Funparks app: ${FUNPARKS_PARKS.map(p => p.name).join(", ")}, add a brief friendly note at the end mentioning the Funparks app and 1-2 of its features.`;

    try {
      const client = new Anthropic({apiKey: ANTHROPIC_API_KEY});

      const systemPrompt = `You are a helpful theme park assistant for the Funparks app.
You have detailed knowledge about ${parkName || "theme parks"}.

Here is the park data:
${parkData ? JSON.stringify(parkData, null, 2) : "No specific park data provided"}

Park website: ${parkWebsite || "Not provided"}

${FUNPARKS_FEATURES}

Parks currently available in the Funparks app: ${FUNPARKS_PARKS.map(p => `${p.name} (${p.country})`).join(", ")}.

When answering questions:
- Use the park data provided to give accurate information about rides, restaurants and hotels
- When recommending rides for children, always search the park's website for accurate minimum height requirements in cm
- The rideHeightMetres field is the physical height of the ride, NOT the minimum rider height
- If asked about current opening hours, prices or events, search the park website for up-to-date information
- Keep answers concise, friendly and practical
- Respond in the same language the user asks the question

${parkPromotionInstruction}`;

      const response = await client.messages.create({
        model: "claude-sonnet-4-5",
        max_tokens: 1024,
        system: systemPrompt,
        tools: [
          {
            type: "web_search_20250305",
            name: "web_search",
          },
        ],
        messages: [
          {
            role: "user",
            content: question,
          },
        ],
      });

      const textContent = response.content
        .filter((block) => block.type === "text")
        .map((block) => block.text)
        .join("\n");

      res.json({answer: textContent});
    } catch (error) {
      console.error("Error calling Anthropic API:", error);
      res.status(500).json({error: "Failed to get response from AI: " + error.message});
    }
  }
);