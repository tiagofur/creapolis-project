export const workspaceTypeDefs = `#graphql
  enum WorkspaceType {
    PERSONAL
    TEAM
    ENTERPRISE
  }

  enum WorkspaceRole {
    OWNER
    ADMIN
    MEMBER
    GUEST
  }

  enum InvitationStatus {
    PENDING
    ACCEPTED
    DECLINED
    EXPIRED
  }

  type Workspace implements Node {
    id: ID!
    name: String!
    description: String
    avatarUrl: String
    type: WorkspaceType!
    ownerId: Int!
    owner: User!
    allowGuestInvites: Boolean!
    requireEmailVerification: Boolean!
    autoAssignNewMembers: Boolean!
    defaultProjectTemplate: String
    timezone: String!
    language: String!
    createdAt: DateTime!
    updatedAt: DateTime!
    projects: [Project!]!
    members: [WorkspaceMember!]!
    invitations: [WorkspaceInvitation!]!
  }

  type WorkspaceMember {
    id: ID!
    workspaceId: Int!
    workspace: Workspace!
    userId: Int!
    user: User!
    role: WorkspaceRole!
    joinedAt: DateTime!
    lastActiveAt: DateTime
    isActive: Boolean!
  }

  type WorkspaceInvitation {
    id: ID!
    workspaceId: Int!
    workspace: Workspace!
    inviterUserId: Int!
    inviter: User!
    inviteeEmail: String!
    role: WorkspaceRole!
    token: String!
    status: InvitationStatus!
    createdAt: DateTime!
    expiresAt: DateTime!
  }

  input CreateWorkspaceInput {
    name: String!
    description: String
    type: WorkspaceType
    allowGuestInvites: Boolean
    requireEmailVerification: Boolean
    timezone: String
    language: String
  }

  input UpdateWorkspaceInput {
    name: String
    description: String
    avatarUrl: String
    allowGuestInvites: Boolean
    requireEmailVerification: Boolean
    autoAssignNewMembers: Boolean
    defaultProjectTemplate: String
    timezone: String
    language: String
  }

  input InviteToWorkspaceInput {
    workspaceId: Int!
    inviteeEmail: String!
    role: WorkspaceRole
  }

  extend type Query {
    # Get workspace by ID
    workspace(id: ID!): Workspace
    
    # List workspaces
    workspaces(
      page: Int
      limit: Int
      type: WorkspaceType
      search: String
    ): WorkspacesConnection!
    
    # Get workspace invitations
    workspaceInvitations(
      workspaceId: Int
      status: InvitationStatus
    ): [WorkspaceInvitation!]!
  }

  extend type Mutation {
    # Create workspace
    createWorkspace(input: CreateWorkspaceInput!): Workspace!
    
    # Update workspace
    updateWorkspace(id: ID!, input: UpdateWorkspaceInput!): Workspace!
    
    # Delete workspace
    deleteWorkspace(id: ID!): Boolean!
    
    # Invite user to workspace
    inviteToWorkspace(input: InviteToWorkspaceInput!): WorkspaceInvitation!
    
    # Accept workspace invitation
    acceptWorkspaceInvitation(token: String!): WorkspaceMember!
    
    # Decline workspace invitation
    declineWorkspaceInvitation(token: String!): Boolean!
    
    # Remove member from workspace
    removeWorkspaceMember(workspaceId: Int!, userId: Int!): Boolean!
    
    # Update member role
    updateMemberRole(workspaceId: Int!, userId: Int!, role: WorkspaceRole!): WorkspaceMember!
  }

  type WorkspacesConnection {
    edges: [WorkspaceEdge!]!
    pageInfo: PageInfo!
  }

  type WorkspaceEdge {
    node: Workspace!
    cursor: String!
  }
`;
