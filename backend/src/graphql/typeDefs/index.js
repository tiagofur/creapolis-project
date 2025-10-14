import { baseTypeDefs } from "./base.graphql.js";
import { authTypeDefs } from "./auth.graphql.js";
import { projectTypeDefs } from "./project.graphql.js";
import { taskTypeDefs } from "./task.graphql.js";
import { timeLogTypeDefs } from "./timeLog.graphql.js";
import { workspaceTypeDefs } from "./workspace.graphql.js";
import { commentTypeDefs } from "./comment.graphql.js";

export const typeDefs = [
  baseTypeDefs,
  authTypeDefs,
  workspaceTypeDefs,
  projectTypeDefs,
  taskTypeDefs,
  timeLogTypeDefs,
  commentTypeDefs,
];
