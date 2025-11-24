import { Server } from "socket.io";
import jwt from "jsonwebtoken";

class WebSocketService {
  constructor() {
    this.io = null;
    this.activeRooms = new Map(); // roomId -> Set of user data
  }

  /**
   * Initialize WebSocket server
   * @param {Server} httpServer - HTTP server instance
   */
  initialize(httpServer) {
    this.io = new Server(httpServer, {
      cors: {
        origin: (origin, callback) => {
          // Allow all localhost origins in development
          if (!origin || /^http:\/\/localhost:\d+$/.test(origin)) {
            return callback(null, true);
          }
          callback(new Error("Not allowed by CORS"));
        },
        credentials: true,
      },
    });

    this.setupConnectionHandlers();
    console.log("✅ WebSocket service initialized");
  }

  /**
   * Setup connection handlers
   */
  setupConnectionHandlers() {
    // Middleware for authentication
    this.io.use((socket, next) => {
      const token =
        socket.handshake.auth.token ||
        socket.handshake.headers.authorization?.split(" ")[1];
      if (!token) {
        // Allow unauthenticated connections for now if needed, or reject
        // For now, let's just log and proceed, but ideally we should reject or handle guest users
        // But for notifications, we need userId.
        // If no token, maybe it's a guest or public page?
        // Let's try to verify if token exists.
        return next();
      }
      try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        socket.userId = decoded.id;
        next();
      } catch (err) {
        console.error("Socket auth error:", err.message);
        next(new Error("Authentication error"));
      }
    });

    this.io.on("connection", (socket) => {
      console.log(`🔌 Client connected: ${socket.id}, User: ${socket.userId}`);

      // Join user specific room
      if (socket.userId) {
        socket.join(`user_${socket.userId}`);
      }

      // Join a collaboration room (task, project, etc.)
      socket.on("join_room", ({ roomId, userId, userName }) => {
        socket.join(roomId);

        // Track active users in room
        if (!this.activeRooms.has(roomId)) {
          this.activeRooms.set(roomId, new Map());
        }
        this.activeRooms.get(roomId).set(socket.id, { userId, userName });

        // Notify others in room
        const activeUsers = Array.from(this.activeRooms.get(roomId).values());
        this.io.to(roomId).emit("room_users_updated", { activeUsers });

        console.log(`👥 User ${userName} joined room ${roomId}`);
      });

      // Leave a collaboration room
      socket.on("leave_room", ({ roomId }) => {
        this.leaveRoom(socket, roomId);
      });

      // Cursor position update
      socket.on("cursor_update", ({ roomId, userId, userName, position }) => {
        socket.to(roomId).emit("cursor_moved", {
          userId,
          userName,
          position,
          socketId: socket.id,
        });
      });

      // Content update (description, comment, etc.)
      socket.on(
        "content_update",
        ({ roomId, contentType, contentId, content, userId, userName }) => {
          socket.to(roomId).emit("content_changed", {
            contentType,
            contentId,
            content,
            userId,
            userName,
            timestamp: new Date().toISOString(),
          });
        }
      );

      // Comment added
      socket.on("comment_added", ({ roomId, comment, userId, userName }) => {
        this.io.to(roomId).emit("new_comment", {
          comment,
          userId,
          userName,
          timestamp: new Date().toISOString(),
        });
      });

      // Notification event
      socket.on("notification_received", ({ userId, notification }) => {
        this.io.to(`user_${userId}`).emit("new_notification", {
          notification,
          timestamp: new Date().toISOString(),
        });
      });

      // Typing indicator
      socket.on("typing_start", ({ roomId, userId, userName, field }) => {
        socket.to(roomId).emit("user_typing", {
          userId,
          userName,
          field,
          isTyping: true,
        });
      });

      socket.on("typing_stop", ({ roomId, userId, userName, field }) => {
        socket.to(roomId).emit("user_typing", {
          userId,
          userName,
          field,
          isTyping: false,
        });
      });

      // Handle disconnection
      socket.on("disconnect", () => {
        console.log(`🔌 Client disconnected: ${socket.id}`);
        this.handleDisconnection(socket);
      });
    });
  }

  /**
   * Handle user leaving a room
   */
  leaveRoom(socket, roomId) {
    socket.leave(roomId);

    if (this.activeRooms.has(roomId)) {
      this.activeRooms.get(roomId).delete(socket.id);

      // Notify remaining users
      const activeUsers = Array.from(this.activeRooms.get(roomId).values());
      this.io.to(roomId).emit("room_users_updated", { activeUsers });

      // Clean up empty rooms
      if (this.activeRooms.get(roomId).size === 0) {
        this.activeRooms.delete(roomId);
      }
    }
  }

  /**
   * Handle client disconnection
   */
  handleDisconnection(socket) {
    // Remove user from all rooms
    this.activeRooms.forEach((users, roomId) => {
      if (users.has(socket.id)) {
        this.leaveRoom(socket, roomId);
      }
    });
  }

  /**
   * Broadcast event to a specific room
   */
  broadcastToRoom(roomId, event, data) {
    if (this.io) {
      this.io.to(roomId).emit(event, data);
    }
  }

  /**
   * Emit event to a specific user
   */
  emitToUser(userId, event, data) {
    if (this.io) {
      this.io.to(`user_${userId}`).emit(event, data);
    }
  }

  /**
   * Get active users in a room
   */
  getActiveUsers(roomId) {
    if (!this.activeRooms.has(roomId)) {
      return [];
    }
    return Array.from(this.activeRooms.get(roomId).values());
  }
}

// Singleton instance
const websocketService = new WebSocketService();
export default websocketService;
