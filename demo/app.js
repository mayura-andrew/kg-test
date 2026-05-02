/**
 * Unpack Mock Scenario Engine (Client-side)
 * Simulates LangGraph multi-agent behavior and Neo4j Knowledge Graph mappings.
 */

const scenarios = [
    {
        id: "related_rates_ladder",
        trigger_keywords: ["ladder", "sliding", "wall", "rate", "descend"],
        extracted_concepts: ["Related Rates", "Derivatives", "Chain Rule", "Pythagorean Theorem", "Rate of Change"],
        tutor_response: "I see you're working on a related rates problem involving a ladder sliding down a wall. Instead of solving it for you, let's establish the relationships. What equation connects the distance of the base from the wall, the height of the ladder on the wall, and the length of the ladder? Hint: The shape forms a right-angled triangle."
    },
    {
        id: "optimization_can",
        trigger_keywords: ["can", "cylinder", "surface area", "volume", "minimize", "material", "radius"],
        extracted_concepts: ["Optimization", "Derivatives", "Critical Points", "Geometry", "Local Minimum"],
        tutor_response: "This looks like an optimization problem! To minimize the material used for the cylindrical can, we need to minimize its surface area. What is the formula for the surface area of a cylinder, and how can we use the fixed volume constraint to write it in terms of a single variable (e.g., radius)?"
    },
    {
        id: "integration_work",
        trigger_keywords: ["work", "pump", "water", "tank", "height"],
        extracted_concepts: ["Integration", "Definite Integrals", "Work Done", "Physics Application"],
        tutor_response: "This physics problem requires integrating fluid slices. To calculate the work done pumping water out of the tank, we need to determine the force on a single 'slice' of water. What is the volume of a thin horizontal slice of water at an arbitrary height y, and what formula relates Work, Force, and Distance?"
    }
];

const chatHistory = document.getElementById("chat-history");
const chatInput = document.getElementById("chat-input");
const sendBtn = document.getElementById("send-btn");
const typingIndicator = document.getElementById("typing-indicator");
const graphContainer = document.getElementById("graph-container");

const defaultResponse = "That's an interesting problem. I can help scaffold your understanding of the underlying concepts. Can you isolate the specific mathematical structures or formulas you think apply here?";

// Function to interpret the user query against the mock Knowledge Graph
function detectScenario(text) {
    const lowerText = text.toLowerCase();
    let bestMatch = null;
    let maxKWs = 0;
    
    for (const scenario of scenarios) {
        let matches = 0;
        for (const kw of scenario.trigger_keywords) {
            if (lowerText.includes(kw)) matches++;
        }
        if (matches > maxKWs && matches >= 2) {
            maxKWs = matches;
            bestMatch = scenario;
        }
    }
    return bestMatch;
}

// Function to add a chat message text block to the conversation history
function addMessage(text, type) {
    const el = document.createElement("div");
    el.className = `message ${type}`;
    el.textContent = text;
    chatHistory.appendChild(el);
    chatHistory.scrollTop = chatHistory.scrollHeight;
}

// Render dynamic mock nodes and connective paths
function renderGraph(concepts) {
    graphContainer.innerHTML = ''; // Clear graph
    
    if (!concepts || concepts.length === 0) {
        graphContainer.innerHTML = '<div class="graph-placeholder">No specific concepts mapped.</div>';
        return;
    }

    const centerX = graphContainer.clientWidth / 2;
    const centerY = graphContainer.clientHeight / 2;
    const radius = Math.min(centerX, centerY) - 80; // Offset padding
    
    const nodeElements = [];

    concepts.forEach((concept, index) => {
        const isCenter = index === 0;
        const _radius = isCenter ? 0 : radius;
        const angle = isCenter ? 0 : ((index - 1) / (concepts.length - 1)) * 2 * Math.PI;

        const x = centerX + _radius * Math.cos(angle);
        const y = centerY + _radius * Math.sin(angle);

        const node = document.createElement("div");
        node.className = "node";
        node.textContent = concept;
        
        node.style.left = `${x}px`;
        node.style.top = `${y}px`;
        node.style.transform = "translate(-50%, -50%)"; // Center properly around coordinates
        
        if (isCenter) {
            node.style.backgroundColor = "var(--accent)";
            node.style.transform += " scale(1.15)";
        }
        
        graphContainer.appendChild(node);
        
        nodeElements.push({
            el: node,
            x: x,
            y: y,
            isCenter: isCenter
        });
    });

    // Draw mock graph relations to center node
    setTimeout(() => {
        const centerNode = nodeElements.find(n => n.isCenter);
        if(!centerNode) return;
        
        nodeElements.forEach(nodeData => {
            if (nodeData.isCenter) return;
            drawEdge(centerNode.x, centerNode.y, nodeData.x, nodeData.y);
        });
    }, 300); // Wait for nodes to animate in
}

// Basic SVG / Div path simulation for edges
function drawEdge(x1, y1, x2, y2) {
    const length = Math.sqrt(Math.pow(x2 - x1, 2) + Math.pow(y2 - y1, 2));
    const angle  = Math.atan2(y2 - y1, x2 - x1) * 180 / Math.PI;
    
    const edge = document.createElement("div");
    edge.className = "edge";
    edge.style.width = `${length}px`;
    edge.style.left = `${x1}px`;
    edge.style.top = `${y1}px`;
    edge.style.transform = `rotate(${angle}deg)`;
    
    graphContainer.appendChild(edge);
}

function simulateAgentProcessing(scenario, delayStates) {
    let currentStep = 0;
    typingIndicator.classList.remove("hidden");
    
    const interval = setInterval(() => {
        if (currentStep < delayStates.length) {
            typingIndicator.textContent = delayStates[currentStep];
            currentStep++;
        } else {
            clearInterval(interval);
            typingIndicator.classList.add("hidden");
            
            // Render Graph
            if (scenario) {
                renderGraph(scenario.extracted_concepts);
                addMessage(scenario.tutor_response, "tutor");
            } else {
                renderGraph(["Unresolved Domain"]);
                addMessage(defaultResponse, "tutor");
            }
        }
    }, 1400); // Simulated LLM thinking delay
}

function handleSubmission() {
    const text = chatInput.value.trim();
    if (!text) return;

    addMessage(text, "user");
    chatInput.value = '';
    
    // Reset graph during wait
    graphContainer.innerHTML = '<div class="graph-placeholder">Mapping domain... Waiting for KG response...</div>';

    const scenario = detectScenario(text);
    
    const states = [
        "Agent routing query...",
        "Querying Neo4j Knowledge Graph...",
        "Evaluating Prerequisites Graph...",
        "Formulating pedagogical response..."
    ];

    simulateAgentProcessing(scenario, states);
}

// Event Listeners
sendBtn.addEventListener("click", handleSubmission);
chatInput.addEventListener("keydown", (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault();
        handleSubmission();
    }
});