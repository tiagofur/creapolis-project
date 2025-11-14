import express from "express";
import cors from "cors";
import helmet from "helmet";
import morgan from "morgan";
import dotenv from "dotenv";
import rateLimit from "express-rate-limit";
import { createServer } from "http";

// Load environment variables
dotenv.config();

// Import routes
import authRoutes from "./routes/auth.routes.js";
import projectRoutes from "./routes/project.routes.js";
import taskRoutes from "./routes/task.routes.js";
import { taskTimeLogRoutes, timelogRouter } from "./routes/timelog.routes.js";
import googleCalendarRoutes from "./routes/google-calendar.routes.js";
import slackIntegrationRoutes from "./routes/slack-integration.routes.js";
import trelloIntegrationRoutes from "./routes/trello-integration.routes.js";
import integrationsRoutes from "./routes/integrations.routes.js";
import workspaceRoutes from "./routes/workspace.routes.js";
import reportRoutes from "./routes/report.routes.js";
import collaborationRoutes from "./routes/collaboration.routes.js";
import commentRoutes from "./routes/comment.routes.js";
import notificationRoutes from "./routes/notification.routes.js";
import pushNotificationRoutes from "./routes/push-notification.routes.js";
import aiRoutes from "./routes/aiRoutes.js";
import nlpRoutes from "./routes/nlp.routes.js";
import searchRoutes from "./routes/search.routes.js";
import roleRoutes from "./routes/role.routes.js";
import blogRoutes from "./routes/blog.routes.js";
import forumRoutes from "./routes/forum.routes.js";
import voteRoutes from "./routes/vote.routes.js";
import knowledgeRoutes from "./routes/knowledge.routes.js";
import supportRoutes from "./routes/support.routes.js";

// Import WebSocket service
import websocketService from "./services/websocket.service.js";

// Import Firebase service
import firebaseService from "./services/firebase.service.js";

// Import GraphQL setup
import {
  createApolloServer,
  createGraphQLMiddleware,
} from "./graphql/index.js";

const app = express();
const httpServer = createServer(app);
const PORT = process.env.PORT || 3001;
const isTestEnvironment = process.env.NODE_ENV === "test";
let initializationPromise;
let graphqlInitialized = false;
let notFoundHandlerRegistered = false;
let errorHandlerRegistered = false;

// Security middleware
app.use(helmet());

// CORS configuration
const corsOrigins = process.env.CORS_ORIGIN
  ? process.env.CORS_ORIGIN.split(",").map((origin) => origin.trim())
  : ["http://localhost:5173"];

// Función para validar origen en desarrollo (permite cualquier puerto localhost)
const corsOptions = {
  origin: (origin, callback) => {
    // Permitir requests sin origin (como Postman, curl, etc.)
    if (!origin) {
      return callback(null, true);
    }

    // En desarrollo, permitir cualquier puerto localhost
    if (process.env.NODE_ENV === "development") {
      const localhostPattern = /^http:\/\/localhost:\d+$/;
      if (localhostPattern.test(origin) || origin === "http://localhost") {
        return callback(null, true);
      }
    }

    // Verificar si el origen está en la lista permitida
    if (corsOrigins.includes(origin)) {
      return callback(null, true);
    }

    // Rechazar origen no permitido
    callback(new Error("Not allowed by CORS"));
  },
  credentials: true,
};

app.use(cors(corsOptions));

// Rate limiting
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: "Too many requests from this IP, please try again later.",
});
app.use("/api/", limiter);

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging middleware
if (!isTestEnvironment) {
  app.use(morgan("dev"));
}

// Health check endpoints (para Docker healthcheck)
app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  });
});

app.get("/api/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
  });
});

// API routes
app.use("/api/auth", authRoutes);
app.use("/api/workspaces", workspaceRoutes);
app.use("/api/projects", projectRoutes);
app.use("/api/projects/:projectId/tasks", taskRoutes);
app.use("/api/tasks", taskTimeLogRoutes);
app.use("/api/timelogs", timelogRouter);
app.use("/api/integrations/google", googleCalendarRoutes);
app.use("/api/integrations/slack", slackIntegrationRoutes);
app.use("/api/integrations/trello", trelloIntegrationRoutes);
app.use("/api/integrations", integrationsRoutes);
app.use("/api/reports", reportRoutes);
app.use("/api/collaboration", collaborationRoutes);
app.use("/api/comments", commentRoutes);
app.use("/api/notifications", notificationRoutes);
app.use("/api/push", pushNotificationRoutes);
app.use("/api/ai", aiRoutes);
app.use("/api/nlp", nlpRoutes);
app.use("/api/search", searchRoutes);
app.use("/api/roles", roleRoutes);
app.use("/api/blog", blogRoutes);
app.use("/api/forum", forumRoutes);
app.use("/api/votes", voteRoutes);
app.use("/api/knowledge", knowledgeRoutes);
app.use("/api/support", supportRoutes);

// Root endpoint
app.get("/", (req, res) => {
  res.json({
    message: "Creapolis API Server",
    version: "1.0.0",
    endpoints: {
      health: "/health",
      api: "/api",
    },
  });
});

const startServer = ({ listen = true } = {}) => {
  if (!initializationPromise) {
    initializationPromise = (async () => {
      try {
        if (!isTestEnvironment) {
          firebaseService.initialize();
          websocketService.initialize(httpServer);
        }

        if (!graphqlInitialized) {
          const apolloServer = await createApolloServer(httpServer);
          app.use(
            "/graphql",
            express.json(),
            createGraphQLMiddleware(apolloServer)
          );
          graphqlInitialized = true;
        }

        if (!notFoundHandlerRegistered) {
          app.use((req, res) => {
            res.status(404).json({
              error: "Not Found",
              message: `Route ${req.method} ${req.url} not found`,
            });
          });
          notFoundHandlerRegistered = true;
        }

        if (!errorHandlerRegistered) {
          app.use((err, req, res, next) => {
            console.error("Error:", err);

            const status = err.statusCode || err.status || 500;
            const message = err.message || "Internal Server Error";
            const responseBody = {
              success: false,
              message,
              timestamp: new Date().toISOString(),
            };

            if (err.details) {
              responseBody.details = err.details;
            }

            if (process.env.NODE_ENV === "development" && err.stack) {
              responseBody.stack = err.stack;
            }

            res.status(status).json(responseBody);
          });
          errorHandlerRegistered = true;
        }

        if (listen) {
          await new Promise((resolve) => {
            httpServer.listen(PORT, () => {
              console.log(`🚀 Server running on port ${PORT}`);
              console.log(
                `📝 Environment: ${process.env.NODE_ENV || "development"}`
              );
              console.log(`🔗 Health check: http://localhost:${PORT}/health`);
              console.log(`🔌 WebSocket ready for connections`);
              console.log(
                `🎯 GraphQL endpoint: http://localhost:${PORT}/graphql`
              );
              console.log(
                `📊 GraphQL Playground: http://localhost:${PORT}/graphql (in dev mode)`
              );
              console.log(
                `🔔 Push notifications: ${
                  firebaseService.isInitialized() ? "enabled" : "disabled"
                }`
              );
              resolve();
            });
          });
        }

        return { app, httpServer };
      } catch (error) {
        console.error("Failed to start server:", error);

        if (listen) {
          process.exit(1);
        }

        throw error;
      }
    })();
  }

  return initializationPromise;
};

const serverReady = startServer({ listen: !isTestEnvironment });

if (!isTestEnvironment) {
  serverReady.catch((error) => {
    console.error("Server startup failed:", error);
  });
}

export { app, startServer, serverReady };
export default app;
