const express = require('express');
const { GoogleGenerativeAI } = require('@google/generative-ai');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(express.json());
app.use(cors());

// ⚠️ Replace with your actual Gemini API key
const GEMINI_API_KEY = "AIzaSyC1GdvjpM4JJa8rZdmqU3LnEKScvAj65ow";

// Initialize Gemini client
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
const model = genAI.getGenerativeModel({ 
    model: "gemini-1.5-flash",
    generationConfig: {
        temperature: 0.2,
        maxOutputTokens: 400,
    }
});

const SYSTEM_INSTRUCTIONS = `
You are MedTriage, a kind medical assistant.
Your job:
1) When a user describes symptoms, ask **one clear follow-up question at a time**, like a doctor would.
   (Example: "How long have you had the headache?" or "Is the cough dry or with phlegm?")
2) Continue asking short questions until you have enough detail (around 3–5 turns).
3) Then give a **final response**:
   - Possible cause in simple words
   - 2–3 home-care tips/remedies
   - Safety advice: when to see a doctor
4) Always be empathetic, short, and clear.
5) If symptoms are dangerous (chest pain, breathing trouble, fainting, heavy bleeding, stroke signs), **immediately say it may be serious and advise urgent hospital visit**.
6) If the user types in Hindi, reply in Hindi. If in English, reply in English.
7) Do not output JSON or structured fields — just plain helpful text.
8) Do not prescribe specific medicines by name, only simple remedies (rest, fluids, warm water, etc.).
`;

// Store conversations (in production, use a database)
const conversations = new Map();

// Language detection function (simplified version)
function detectLanguage(text) {
    // Simple Hindi detection - check for Devanagari characters
    const hindiRegex = /[\u0900-\u097F]/;
    return hindiRegex.test(text) ? 'hi' : 'en';
}

// Helper function to call Gemini
async function callGemini(prompt) {
    try {
        const result = await model.generateContent(prompt);
        const response = await result.response;
        return response.text();
    } catch (error) {
        console.error('Error calling Gemini:', error);
        throw new Error('Failed to get AI response');
    }
}

// MedTriage chat function
async function medtriageChat(sessionId, userInput) {
    // Get or create conversation
    let conversation = conversations.get(sessionId) || {
        turns: [],
        done: false
    };

    if (conversation.done) {
        return "✅ Session complete. Please start a new chat.";
    }

    // Language detection
    let lang = detectLanguage(userInput);
    console.log(`Detected language: ${lang}`);

    // Build conversation history
    let historyText = "";
    for (const [role, text] of conversation.turns) {
        historyText += `${role.toUpperCase()}: ${text}\n`;
    }

    // Create prompt for Gemini
    const prompt = `${SYSTEM_INSTRUCTIONS}

Conversation so far:
${historyText}
USER: ${userInput}
ASSISTANT:`;

    // Call Gemini
    const reply = await callGemini(prompt);

    // Save conversation state
    conversation.turns.push(["user", userInput]);
    conversation.turns.push(["assistant", reply]);

    // Check if conversation should end
    const endWords = ["it may be", "possible cause", "likely", "advice", "doctor", "hospital", "serious"];
    if (endWords.some(word => reply.toLowerCase().includes(word))) {
        conversation.done = true;
    }

    // Store updated conversation
    conversations.set(sessionId, conversation);

    return reply;
}

// Reset conversation function
function resetConversation(sessionId) {
    conversations.set(sessionId, {
        turns: [],
        done: false
    });
    return "🔄 Chat reset. Please describe your symptoms.";
}

// API Routes

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        message: 'MedTriage API is running',
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Get API info endpoint
app.get('/', (req, res) => {
    res.json({
        name: 'MedTriage API',
        version: '1.0.0',
        description: 'AI-powered medical symptom checker',
        endpoints: {
            'GET /health': 'Health check',
            'POST /chat': 'Chat with MedTriage',
            'POST /reset': 'Reset conversation',
            'GET /conversation/:sessionId': 'Get conversation history'
        }
    });
});

// Chat endpoint
app.post('/chat', async (req, res) => {
    try {
        const { message, sessionId = 'default' } = req.body;
        
        if (!message || message.trim().length === 0) {
            return res.status(400).json({ 
                error: 'Message is required and cannot be empty' 
            });
        }

        console.log(`Chat request - SessionID: ${sessionId}, Message: ${message}`);

        const response = await medtriageChat(sessionId, message.trim());
        
        res.json({ 
            response,
            sessionId,
            timestamp: new Date().toISOString(),
            success: true
        });
    } catch (error) {
        console.error('Chat error:', error);
        res.status(500).json({ 
            error: 'Internal server error',
            message: error.message,
            success: false 
        });
    }
});

// Reset conversation endpoint
app.post('/reset', (req, res) => {
    try {
        const { sessionId = 'default' } = req.body;
        
        console.log(`Reset request - SessionID: ${sessionId}`);
        
        const message = resetConversation(sessionId);
        
        res.json({ 
            message,
            sessionId,
            timestamp: new Date().toISOString(),
            success: true
        });
    } catch (error) {
        console.error('Reset error:', error);
        res.status(500).json({ 
            error: 'Internal server error',
            message: error.message,
            success: false 
        });
    }
});

// Get conversation history endpoint
app.get('/conversation/:sessionId', (req, res) => {
    try {
        const { sessionId } = req.params;
        const conversation = conversations.get(sessionId) || {
            turns: [],
            done: false
        };
        
        console.log(`Get conversation - SessionID: ${sessionId}`);
        
        res.json({
            conversation,
            sessionId,
            timestamp: new Date().toISOString(),
            success: true
        });
    } catch (error) {
        console.error('Get conversation error:', error);
        res.status(500).json({ 
            error: 'Internal server error',
            message: error.message,
            success: false 
        });
    }
});

// Get all active sessions (for debugging)
app.get('/sessions', (req, res) => {
    try {
        const sessions = Array.from(conversations.keys()).map(sessionId => ({
            sessionId,
            turnCount: conversations.get(sessionId).turns.length,
            done: conversations.get(sessionId).done
        }));
        
        res.json({
            sessions,
            totalSessions: sessions.length,
            timestamp: new Date().toISOString(),
            success: true
        });
    } catch (error) {
        console.error('Get sessions error:', error);
        res.status(500).json({ 
            error: 'Internal server error',
            message: error.message,
            success: false 
        });
    }
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error('Unhandled error:', err);
    res.status(500).json({
        error: 'Something went wrong!',
        success: false
    });
});

// 404 handler
app.use((req, res) => {
    res.status(404).json({
        error: 'Endpoint not found',
        success: false,
        availableEndpoints: ['/', '/health', '/chat', '/reset', '/conversation/:sessionId', '/sessions']
    });
});

// Start server
app.listen(port, () => {
    console.log(`🏥 MedTriage API server running on port ${port}`);
    console.log(`📋 Health check: http://localhost:${port}/health`);
    console.log(`💬 Chat endpoint: POST http://localhost:${port}/chat`);
    console.log(`🔄 Reset endpoint: POST http://localhost:${port}/reset`);
    console.log(`📖 API info: http://localhost:${port}/`);
    console.log(`🚀 Server started at: ${new Date().toISOString()}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('🛑 SIGTERM received, shutting down gracefully');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('🛑 SIGINT received, shutting down gracefully');
    process.exit(0);
});

module.exports = app;
app.listen(port, '0.0.0.0', () => {  // Listen on all interfaces
    console.log(`🏥 MedTriage API server running on port ${port}`);
});