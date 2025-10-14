export const timeLogTypeDefs = `#graphql
  type TimeLog implements Node {
    id: ID!
    taskId: Int!
    task: Task!
    userId: Int!
    user: User!
    startTime: DateTime!
    endTime: DateTime
    duration: Float
    createdAt: DateTime!
    updatedAt: DateTime!
  }

  input StartTimeLogInput {
    taskId: Int!
  }

  input StopTimeLogInput {
    id: ID!
  }

  extend type Query {
    # Get time log by ID
    timeLog(id: ID!): TimeLog
    
    # List time logs
    timeLogs(
      taskId: Int
      userId: Int
      startDate: DateTime
      endDate: DateTime
      page: Int
      limit: Int
    ): TimeLogsConnection!
    
    # Get active time log for current user
    activeTimeLog: TimeLog
    
    # Get time log statistics
    timeLogStatistics(
      userId: Int
      projectId: Int
      startDate: DateTime!
      endDate: DateTime!
    ): TimeLogStatistics!
  }

  extend type Mutation {
    # Start time tracking for a task
    startTimeLog(input: StartTimeLogInput!): TimeLog!
    
    # Stop time tracking
    stopTimeLog(input: StopTimeLogInput!): TimeLog!
    
    # Manually create time log
    createTimeLog(
      taskId: Int!
      startTime: DateTime!
      endTime: DateTime!
    ): TimeLog!
    
    # Delete time log
    deleteTimeLog(id: ID!): Boolean!
  }

  type TimeLogsConnection {
    edges: [TimeLogEdge!]!
    pageInfo: PageInfo!
  }

  type TimeLogEdge {
    node: TimeLog!
    cursor: String!
  }

  type TimeLogStatistics {
    totalHours: Float!
    taskCount: Int!
    averageHoursPerTask: Float!
    byDay: [DailyTimeLog!]!
  }

  type DailyTimeLog {
    date: DateTime!
    hours: Float!
    taskCount: Int!
  }
`;
