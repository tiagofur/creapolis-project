import { ApolloServer } from "@apollo/server";
import { expressMiddleware } from "@apollo/server/express4";
import { ApolloServerPluginDrainHttpServer } from "@apollo/server/plugin/drainHttpServer";
import { typeDefs } from "./typeDefs/index.js";
import { resolvers } from "./resolvers/index.js";
import { createContext } from "./context.js";

/**
 * Creates and configures the Apollo GraphQL server
 */
export const createApolloServer = async (httpServer) => {
  const server = new ApolloServer({
    typeDefs,
    resolvers,
    plugins: [
      // Proper shutdown for the HTTP server
      ApolloServerPluginDrainHttpServer({ httpServer }),
    ],
    formatError: (formattedError, error) => {
      // Log errors for debugging
      if (process.env.NODE_ENV === "development") {
        console.error("GraphQL Error:", error);
      }

      // Return formatted error
      return {
        message: formattedError.message,
        code: formattedError.extensions?.code || "INTERNAL_SERVER_ERROR",
        ...(process.env.NODE_ENV === "development" && {
          stack: formattedError.extensions?.exception?.stacktrace,
        }),
      };
    },
    introspection: process.env.NODE_ENV !== "production",
  });

  await server.start();

  return server;
};

/**
 * Creates the Express middleware for GraphQL
 */
export const createGraphQLMiddleware = (server) => {
  return expressMiddleware(server, {
    context: createContext,
  });
};
