export const taskTypeDefs = `#graphql
  enum TaskStatus {
    PLANNED
    IN_PROGRESS
    BLOCKED
    COMPLETED
    CANCELLED
  }

  enum DependencyType {
    FINISH_TO_START
    START_TO_START
  }

  type Task implements Node {
    id: ID!
    title: String!
    description: String
    status: TaskStatus!
    estimatedHours: Float!
    actualHours: Float!
    startDate: DateTime
    endDate: DateTime
    projectId: Int!
    project: Project!
    assigneeId: Int
    assignee: User
    createdAt: DateTime!
    updatedAt: DateTime!
    dependencies: [Dependency!]!
    dependents: [Dependency!]!
    timeLogs: [TimeLog!]!
    comments: [Comment!]!
  }

  type Dependency {
    id: ID!
    predecessorId: Int!
    successorId: Int!
    predecessor: Task!
    successor: Task!
    type: DependencyType!
    createdAt: DateTime!
  }

  input CreateTaskInput {
    title: String!
    description: String
    status: TaskStatus
    estimatedHours: Float!
    startDate: DateTime
    endDate: DateTime
    projectId: Int!
    assigneeId: Int
  }

  input UpdateTaskInput {
    title: String
    description: String
    status: TaskStatus
    estimatedHours: Float
    actualHours: Float
    startDate: DateTime
    endDate: DateTime
    assigneeId: Int
  }

  input AddDependencyInput {
    predecessorId: Int!
    successorId: Int!
    type: DependencyType
  }

  extend type Query {
    # Get task by ID
    task(id: ID!): Task
    
    # List tasks (with filters)
    tasks(
      projectId: Int
      assigneeId: Int
      status: TaskStatus
      page: Int
      limit: Int
      search: String
    ): TasksConnection!
    
    # Get tasks assigned to current user
    myTasks(
      status: TaskStatus
      page: Int
      limit: Int
    ): TasksConnection!
  }

  extend type Mutation {
    # Create new task
    createTask(input: CreateTaskInput!): Task!
    
    # Update task
    updateTask(id: ID!, input: UpdateTaskInput!): Task!
    
    # Delete task
    deleteTask(id: ID!): Boolean!
    
    # Add dependency between tasks
    addTaskDependency(input: AddDependencyInput!): Dependency!
    
    # Remove dependency
    removeTaskDependency(id: ID!): Boolean!
    
    # Assign task to user
    assignTask(taskId: ID!, userId: Int!): Task!
    
    # Unassign task
    unassignTask(taskId: ID!): Task!
  }

  type TasksConnection {
    edges: [TaskEdge!]!
    pageInfo: PageInfo!
  }

  type TaskEdge {
    node: Task!
    cursor: String!
  }
`;
