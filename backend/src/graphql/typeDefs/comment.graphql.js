export const commentTypeDefs = `#graphql
  enum NotificationType {
    MENTION
    COMMENT_REPLY
    TASK_ASSIGNED
    TASK_UPDATED
    PROJECT_UPDATED
    SYSTEM
  }

  type Comment implements Node {
    id: ID!
    content: String!
    taskId: Int
    task: Task
    projectId: Int
    project: Project
    parentId: Int
    parent: Comment
    authorId: Int!
    author: User!
    createdAt: DateTime!
    updatedAt: DateTime!
    isEdited: Boolean!
    replies: [Comment!]!
    mentions: [CommentMention!]!
  }

  type CommentMention {
    id: ID!
    commentId: Int!
    comment: Comment!
    userId: Int!
    user: User!
    createdAt: DateTime!
  }

  type Notification implements Node {
    id: ID!
    userId: Int!
    user: User!
    type: NotificationType!
    title: String!
    message: String!
    isRead: Boolean!
    relatedId: Int
    relatedType: String
    createdAt: DateTime!
    readAt: DateTime
  }

  input CreateCommentInput {
    content: String!
    taskId: Int
    projectId: Int
    parentId: Int
  }

  input UpdateCommentInput {
    content: String!
  }

  extend type Query {
    # Get comment by ID
    comment(id: ID!): Comment
    
    # List comments
    comments(
      taskId: Int
      projectId: Int
      parentId: Int
      page: Int
      limit: Int
    ): CommentsConnection!
    
    # Get notifications
    notifications(
      isRead: Boolean
      type: NotificationType
      page: Int
      limit: Int
    ): NotificationsConnection!
    
    # Get unread notification count
    unreadNotificationCount: Int!
  }

  extend type Mutation {
    # Create comment
    createComment(input: CreateCommentInput!): Comment!
    
    # Update comment
    updateComment(id: ID!, input: UpdateCommentInput!): Comment!
    
    # Delete comment
    deleteComment(id: ID!): Boolean!
    
    # Mark notification as read
    markNotificationAsRead(id: ID!): Notification!
    
    # Mark all notifications as read
    markAllNotificationsAsRead: Boolean!
  }

  extend type Subscription {
    # Subscribe to new comments
    commentAdded(taskId: Int, projectId: Int): Comment!
    
    # Subscribe to notifications
    notificationReceived: Notification!
  }

  type CommentsConnection {
    edges: [CommentEdge!]!
    pageInfo: PageInfo!
  }

  type CommentEdge {
    node: Comment!
    cursor: String!
  }

  type NotificationsConnection {
    edges: [NotificationEdge!]!
    pageInfo: PageInfo!
  }

  type NotificationEdge {
    node: Notification!
    cursor: String!
  }
`;
