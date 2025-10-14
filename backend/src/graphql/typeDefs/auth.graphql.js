export const authTypeDefs = `#graphql
  enum Role {
    ADMIN
    PROJECT_MANAGER
    TEAM_MEMBER
  }

  type User implements Node {
    id: ID!
    email: String!
    name: String!
    role: Role!
    avatarUrl: String
    createdAt: DateTime!
    updatedAt: DateTime!
    projects: [Project!]!
    assignedTasks: [Task!]!
    workspaces: [Workspace!]!
    ownedWorkspaces: [Workspace!]!
  }

  type AuthPayload {
    user: User!
    token: String!
  }

  input RegisterInput {
    email: String!
    password: String!
    name: String!
    role: Role
  }

  input LoginInput {
    email: String!
    password: String!
  }

  extend type Query {
    # Get current authenticated user profile
    me: User!
    
    # Get user by ID (admin only)
    user(id: ID!): User
    
    # List all users (admin only)
    users(
      page: Int
      limit: Int
      search: String
    ): UsersConnection!
  }

  extend type Mutation {
    # Register a new user
    register(input: RegisterInput!): AuthPayload!
    
    # Login user
    login(input: LoginInput!): AuthPayload!
    
    # Update user profile
    updateProfile(
      name: String
      avatarUrl: String
    ): User!
    
    # Change password
    changePassword(
      currentPassword: String!
      newPassword: String!
    ): Boolean!
  }

  type UsersConnection {
    edges: [UserEdge!]!
    pageInfo: PageInfo!
  }

  type UserEdge {
    node: User!
    cursor: String!
  }
`;
