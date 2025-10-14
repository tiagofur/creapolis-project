export const projectTypeDefs = `#graphql
  type Project implements Node {
    id: ID!
    name: String!
    description: String
    workspaceId: Int!
    workspace: Workspace!
    createdAt: DateTime!
    updatedAt: DateTime!
    members: [ProjectMember!]!
    tasks: [Task!]!
    comments: [Comment!]!
    statistics: ProjectStatistics!
  }

  type ProjectMember {
    id: ID!
    user: User!
    userId: Int!
    projectId: Int!
    project: Project!
    joinedAt: DateTime!
  }

  type ProjectStatistics {
    totalTasks: Int!
    completedTasks: Int!
    inProgressTasks: Int!
    plannedTasks: Int!
    totalEstimatedHours: Float!
    totalActualHours: Float!
    completionPercentage: Float!
  }

  input CreateProjectInput {
    name: String!
    description: String
    workspaceId: Int!
  }

  input UpdateProjectInput {
    name: String
    description: String
  }

  input AddProjectMemberInput {
    userId: Int!
  }

  extend type Query {
    # Get project by ID
    project(id: ID!): Project
    
    # List projects (with pagination and filters)
    projects(
      page: Int
      limit: Int
      workspaceId: Int
      search: String
    ): ProjectsConnection!
    
    # Get project statistics
    projectStatistics(id: ID!): ProjectStatistics!
  }

  extend type Mutation {
    # Create new project
    createProject(input: CreateProjectInput!): Project!
    
    # Update project
    updateProject(id: ID!, input: UpdateProjectInput!): Project!
    
    # Delete project
    deleteProject(id: ID!): Boolean!
    
    # Add member to project
    addProjectMember(projectId: ID!, input: AddProjectMemberInput!): ProjectMember!
    
    # Remove member from project
    removeProjectMember(projectId: ID!, userId: Int!): Boolean!
  }

  type ProjectsConnection {
    edges: [ProjectEdge!]!
    pageInfo: PageInfo!
  }

  type ProjectEdge {
    node: Project!
    cursor: String!
  }
`;
