    // const WebSocket = require('ws');

    // const wss = new WebSocket.Server({ port: 8080 });

    // let rooms = {}; // { roomId: [ws1, ws2] }

    // wss.on('connection', (ws) => {
    // console.log('New client connected');

    // ws.on('message', (message) => {
    //     let data = {};
    //     try {
    //     data = JSON.parse(message);
    //     } catch (e) {
    //     console.error('Invalid JSON', message);
    //     return;
    //     }

    //     switch (data.type) {
    //     case 'join':
    //         if (!rooms[data.room]) rooms[data.room] = [];
    //         rooms[data.room].push(ws);
    //         ws.room = data.room;
    //         console.log(`User joined room ${data.room}`);
    //         break;

    //     case 'offer':
    //     case 'answer':
    //     case 'candidate':
    //         // Relay to other peer in the room
    //         if (ws.room && rooms[ws.room]) {
    //         rooms[ws.room].forEach(client => {
    //             if (client !== ws && client.readyState === WebSocket.OPEN) {
    //             client.send(JSON.stringify(data));
    //             }
    //         });
    //         }
    //         break;
    //     }
    // });

    // ws.on('close', () => {
    //     if (ws.room && rooms[ws.room]) {
    //     rooms[ws.room] = rooms[ws.room].filter(client => client !== ws);
    //     }
    // });
    // });

    // console.log("Signaling server running on ws://192.168.137.1:8080");



const WebSocket = require('ws');

const wss = new WebSocket.Server({ 
    port: 8080,
    perMessageDeflate: false // Disable compression for better debugging
});

let rooms = {}; // { roomId: [ws1, ws2, ...] }
let users = new Map(); // ws -> { id, room }

wss.on('connection', (ws) => {
    const userId = generateUserId();
    console.log(`🔗 New client connected: ${userId}`);
    
    // Store user info
    users.set(ws, { id: userId, room: null });

    ws.on('message', (message) => {
        let data = {};
        try {
            data = JSON.parse(message);
            console.log(`📨 Received from ${userId}:`, data.type, data.room || '');
        } catch (e) {
            console.error('❌ Invalid JSON from', userId, ':', message);
            return;
        }

        const user = users.get(ws);
        
        switch (data.type) {
            case 'join':
                handleJoin(ws, user, data);
                break;

            case 'offer':
                handleOffer(ws, user, data);
                break;

            case 'answer':
                handleAnswer(ws, user, data);
                break;

            case 'candidate':
                handleCandidate(ws, user, data);
                break;

            default:
                console.log(`❓ Unknown message type: ${data.type}`);
        }
    });

    ws.on('close', () => {
        handleDisconnect(ws);
    });

    ws.on('error', (error) => {
        console.error(`❌ WebSocket error for ${userId}:`, error);
    });
});

function handleJoin(ws, user, data) {
    const roomId = data.room;
    
    if (!roomId) {
        console.error('❌ No room ID provided');
        return;
    }

    // Remove user from previous room if any
    if (user.room) {
        leaveRoom(ws, user.room);
    }

    // Initialize room if it doesn't exist
    if (!rooms[roomId]) {
        rooms[roomId] = [];
        console.log(`🏠 Created new room: ${roomId}`);
    }

    // Add user to room
    rooms[roomId].push(ws);
    user.room = roomId;
    ws.room = roomId; // For backward compatibility

    console.log(`👤 User ${user.id} joined room ${roomId}. Room size: ${rooms[roomId].length}`);
    
    // Notify others in room about new user
    broadcastToRoom(roomId, {
        type: 'user-joined',
        userId: user.id,
        roomSize: rooms[roomId].length
    }, ws);

    // Send room info to joining user
    ws.send(JSON.stringify({
        type: 'joined-room',
        roomId: roomId,
        roomSize: rooms[roomId].length,
        isInitiator: rooms[roomId].length === 1
    }));
}

function handleOffer(ws, user, data) {
    console.log(`📞 Relaying offer from ${user.id} in room ${user.room}`);
    
    if (!user.room || !rooms[user.room]) {
        console.error('❌ User not in a valid room');
        return;
    }

    // Add room info to the data
    const offerData = {
        type: 'offer',
        sdp: data.sdp,
        from: user.id
    };

    broadcastToRoom(user.room, offerData, ws);
}

function handleAnswer(ws, user, data) {
    console.log(`✅ Relaying answer from ${user.id} in room ${user.room}`);
    
    if (!user.room || !rooms[user.room]) {
        console.error('❌ User not in a valid room');
        return;
    }

    const answerData = {
        type: 'answer',
        sdp: data.sdp,
        from: user.id
    };

    broadcastToRoom(user.room, answerData, ws);
}

function handleCandidate(ws, user, data) {
    console.log(`🔄 Relaying ICE candidate from ${user.id} in room ${user.room}`);
    
    if (!user.room || !rooms[user.room]) {
        console.error('❌ User not in a valid room');
        return;
    }

    const candidateData = {
        type: 'candidate',
        candidate: data.candidate,
        from: user.id
    };

    broadcastToRoom(user.room, candidateData, ws);
}

function handleDisconnect(ws) {
    const user = users.get(ws);
    if (!user) return;

    console.log(`🔌 User ${user.id} disconnected`);

    if (user.room) {
        leaveRoom(ws, user.room);
        
        // Notify others in room
        broadcastToRoom(user.room, {
            type: 'user-left',
            userId: user.id,
            roomSize: rooms[user.room] ? rooms[user.room].length : 0
        });
    }

    users.delete(ws);
}

function leaveRoom(ws, roomId) {
    if (rooms[roomId]) {
        rooms[roomId] = rooms[roomId].filter(client => client !== ws);
        console.log(`👋 User left room ${roomId}. Room size: ${rooms[roomId].length}`);
        
        // Clean up empty rooms
        if (rooms[roomId].length === 0) {
            delete rooms[roomId];
            console.log(`🗑️ Deleted empty room: ${roomId}`);
        }
    }
}

function broadcastToRoom(roomId, message, excludeWs = null) {
    if (!rooms[roomId]) return;

    const messageStr = JSON.stringify(message);
    let sentCount = 0;

    rooms[roomId].forEach(client => {
        if (client !== excludeWs && client.readyState === WebSocket.OPEN) {
            try {
                client.send(messageStr);
                sentCount++;
            } catch (error) {
                console.error('❌ Error sending message:', error);
            }
        }
    });

    console.log(`📤 Broadcasted ${message.type} to ${sentCount} clients in room ${roomId}`);
}

function generateUserId() {
    return Math.random().toString(36).substr(2, 9);
}

// Log server status every 30 seconds
setInterval(() => {
    const totalRooms = Object.keys(rooms).length;
    const totalUsers = users.size;
    console.log(`📊 Server status: ${totalUsers} users, ${totalRooms} rooms`);
    
    // Log room details
    Object.keys(rooms).forEach(roomId => {
        console.log(`  Room ${roomId}: ${rooms[roomId].length} users`);
    });
}, 30000);

console.log("🚀 Signaling server running on ws://192.168.137.1:8080");
console.log("📝 Debug logging enabled");

// Handle server shutdown gracefully
process.on('SIGINT', () => {
    console.log('\n🛑 Shutting down server...');
    wss.clients.forEach(ws => {
        ws.close(1000, 'Server shutdown');
    });
    wss.close(() => {
        console.log('✅ Server shut down gracefully');
        process.exit(0);
    });
});
