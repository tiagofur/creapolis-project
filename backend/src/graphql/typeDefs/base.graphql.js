export const baseTypeDefs = `#graphql
  scalar DateTime
  scalar JSON

  type Query {
    _empty: String
  }

  type Mutation {
    _empty: String
  }

  type Subscription {
    _empty: String
  }

  type PageInfo {
    hasNextPage: Boolean!
    hasPreviousPage: Boolean!
    startCursor: String
    endCursor: String
    totalCount: Int!
  }

  interface Node {
    id: ID!
  }

  type Error {
    field: String
    message: String!
  }

  type ValidationError {
    errors: [Error!]!
  }
`;
