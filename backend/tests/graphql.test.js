import { describe, it, expect, beforeAll, afterAll } from "@jest/globals";
import request from "supertest";
import { app, serverReady } from "../src/server.js";
const HAS_DB = !!process.env.DATABASE_URL;

const suite = HAS_DB ? describe : describe.skip;

suite("GraphQL API Tests", () => {
  let authToken;
  let workspaceId;
  let projectId;
  let taskAId;
  let taskBId;

  beforeAll(async () => {
    await serverReady;
    // Create user via REST
    const userRes = await request(app).post("/api/auth/register").send({
      email: "graphql-deps@example.com",
      password: "password123",
      name: "GraphQL Tester",
    });
    authToken = userRes.body.data.token;

    // Workspace
    const wsRes = await request(app)
      .post("/api/workspaces")
      .set("Authorization", `Bearer ${authToken}`)
      .send({ name: "GraphQL Workspace", description: "Deps tests" });
    workspaceId = wsRes.body.data.id;

    // Project
    const startDate = new Date().toISOString();
    const endDate = new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString();
    const projectRes = await request(app)
      .post("/api/projects")
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        name: "GraphQL Project",
        description: "Deps",
        workspaceId,
        startDate,
        endDate,
        status: "ACTIVE",
      });
    projectId = projectRes.body.data.id;

    // Create two tasks via GraphQL
    const mutationCreate = `mutation($input: CreateTaskInput!) { createTask(input: $input) { id title projectId } }`;
    const resTaskA = await request(app)
      .post("/graphql")
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        query: mutationCreate,
        variables: { input: { title: "Task A", estimatedHours: 2, projectId } },
      });
    const resTaskB = await request(app)
      .post("/graphql")
      .set("Authorization", `Bearer ${authToken}`)
      .send({
        query: mutationCreate,
        variables: { input: { title: "Task B", estimatedHours: 2, projectId } },
      });
    taskAId = parseInt(resTaskA.body.data.createTask.id);
    taskBId = parseInt(resTaskB.body.data.createTask.id);
  });

  afterAll(async () => {
    // No explicit teardown; globalTeardown handles server and prisma
  });

  describe("Authentication", () => {
    it("should register a new user via GraphQL", async () => {
      const mutation = `
        mutation {
          register(input: {
            email: "graphql@example.com"
            password: "password123"
            name: "GraphQL User"
          }) {
            token
            user {
              id
              email
              name
              role
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.register).toBeDefined();
      expect(res.body.data.register.user.email).toBe("graphql@example.com");
      expect(res.body.data.register.token).toBeDefined();

      authToken = res.body.data.register.token;
      userId = parseInt(res.body.data.register.user.id, 10);
    });

    it("should login a user via GraphQL", async () => {
      const mutation = `
        mutation {
          login(input: {
            email: "graphql@example.com"
            password: "password123"
          }) {
            token
            user {
              id
              email
              name
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.login).toBeDefined();
      expect(res.body.data.login.user.email).toBe("graphql@example.com");
      expect(res.body.data.login.token).toBeDefined();
    });

    it("should get current user profile", async () => {
      const query = `
        query {
          me {
            id
            email
            name
            role
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.me).toBeDefined();
      expect(res.body.data.me.email).toBe("graphql@example.com");
    });

    it("should fail to get profile without token", async () => {
      const query = `
        query {
          me {
            id
            email
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .send({ query })
        .expect(200);

      expect(res.body.errors).toBeDefined();
      expect(res.body.errors[0].code).toBe("UNAUTHENTICATED");
    });

    it("should update user profile", async () => {
      const mutation = `
        mutation {
          updateProfile(name: "Updated Name") {
            id
            name
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.updateProfile.name).toBe("Updated Name");
    });
  });

  describe("Workspaces", () => {
    it("should create a workspace", async () => {
      const mutation = `
        mutation {
          createWorkspace(input: {
            name: "Test Workspace"
            description: "A test workspace"
            type: TEAM
          }) {
            id
            name
            type
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.createWorkspace).toBeDefined();
      expect(res.body.data.createWorkspace.name).toBe("Test Workspace");

      workspaceId = parseInt(res.body.data.createWorkspace.id, 10);
    });

    it("should list workspaces", async () => {
      const query = `
        query {
          workspaces(page: 1, limit: 10) {
            edges {
              node {
                id
                name
                type
              }
            }
            pageInfo {
              totalCount
              hasNextPage
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);
      expect(res.body.data).toBeDefined();
      expect(res.body.data.workspaces).toBeDefined();
      expect(res.body.data.workspaces.edges.length).toBeGreaterThan(0);
    });
  });

  describe("Projects", () => {
    let projectId;

    beforeAll(async () => {
      if (!workspaceId) {
        const mutation = `
          mutation {
            createWorkspace(input: {
              name: "Project Test Workspace"
              description: "Workspace created for GraphQL project tests"
              type: TEAM
            }) {
              id
            }
          }
        `;

        const res = await request(app)
          .post("/graphql")
          .set("Authorization", `Bearer ${authToken}`)
          .send({ query: mutation })
          .expect(200);

        workspaceId = parseInt(res.body.data.createWorkspace.id, 10);
      }
    });

    it("should create a project", async () => {
      const startDate = new Date().toISOString();
      const endDate = new Date(
        Date.now() + 7 * 24 * 60 * 60 * 1000
      ).toISOString();
      const mutation = `
        mutation {
          createProject(input: {
            name: "Test Project"
            description: "A test project"
            workspaceId: ${workspaceId}
            status: ACTIVE
            startDate: "${startDate}"
            endDate: "${endDate}"
          }) {
            id
            name
            description
            status
            startDate
            endDate
            managerId
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.createProject).toBeDefined();
      expect(res.body.data.createProject.name).toBe("Test Project");
      expect(res.body.data.createProject.status).toBe("ACTIVE");
      expect(
        new Date(res.body.data.createProject.startDate).toISOString()
      ).toBe(new Date(startDate).toISOString());
      expect(new Date(res.body.data.createProject.endDate).toISOString()).toBe(
        new Date(endDate).toISOString()
      );
      expect(res.body.data.createProject.managerId).toBe(userId);

      projectId = parseInt(res.body.data.createProject.id, 10);
    });

    it("should list projects", async () => {
      const query = `
        query {
          projects(page: 1, limit: 10) {
            edges {
              node {
                id
                name
                description
                status
                startDate
                endDate
              }
            }
            pageInfo {
              totalCount
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.projects.edges.length).toBeGreaterThan(0);
    });

    it("should get project statistics", async () => {
      const query = `
        query {
          projectStatistics(id: "${projectId}") {
            totalTasks
            completedTasks
            inProgressTasks
            completionPercentage
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.projectStatistics).toBeDefined();
      expect(res.body.data.projectStatistics.totalTasks).toBe(0);
    });
  });

  describe("Tasks", () => {
    let taskWorkspaceId;
    let projectId;
    let taskId;

    beforeAll(async () => {
      const workspaceMutation = `
        mutation {
          createWorkspace(input: {
            name: "Task Test Workspace"
            description: "Workspace for GraphQL task tests"
            type: TEAM
          }) {
            id
          }
        }
      `;

      const workspaceRes = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: workspaceMutation })
        .expect(200);

      taskWorkspaceId = parseInt(workspaceRes.body.data.createWorkspace.id, 10);

      const startDate = new Date().toISOString();
      const endDate = new Date(
        Date.now() + 7 * 24 * 60 * 60 * 1000
      ).toISOString();

      const projectMutation = `
        mutation {
          createProject(input: {
            name: "Task Test Project"
            description: "Project for GraphQL task tests"
            workspaceId: ${taskWorkspaceId}
            status: ACTIVE
            startDate: "${startDate}"
            endDate: "${endDate}"
          }) {
            id
          }
        }
      `;

      const projectRes = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: projectMutation })
        .expect(200);

      projectId = parseInt(projectRes.body.data.createProject.id, 10);
    });

    it("should create a task", async () => {
      const mutation = `
        mutation {
          createTask(input: {
            title: "Test Task"
            description: "A test task"
            estimatedHours: 4
            projectId: ${projectId}
          }) {
            id
            title
            status
            estimatedHours
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.createTask).toBeDefined();
      expect(res.body.data.createTask.title).toBe("Test Task");
      expect(res.body.data.createTask.status).toBe("PLANNED");

      taskId = res.body.data.createTask.id;
    });

    it("should update task status", async () => {
      const mutation = `
        mutation {
          updateTask(id: "${taskId}", input: {
            status: IN_PROGRESS
          }) {
            id
            status
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query: mutation })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.updateTask.status).toBe("IN_PROGRESS");
    });

    it("should list my tasks", async () => {
      const query = `
        query {
          myTasks(page: 1, limit: 10) {
            edges {
              node {
                id
                title
                status
              }
            }
            pageInfo {
              totalCount
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);

      expect(res.body.data).toBeDefined();
      expect(res.body.data.myTasks).toBeDefined();
    });
  });

  describe("Dependencies", () => {
    let authToken2;
    it("should add dependency A -> B and reject circular B -> A", async () => {
      const addDepMutation = `mutation($input: AddTaskDependencyInput!) { addTaskDependency(input: $input) { predecessorId successorId } }`;

      // First dependency: A -> B
      const res1 = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          query: addDepMutation,
          variables: { input: { predecessorId: taskAId, successorId: taskBId, type: "FINISH_TO_START" } },
        });
      expect(res1.body.errors).toBeUndefined();
      expect(res1.body.data.addTaskDependency.predecessorId).toBe(taskAId);

      // Attempt cycle: B -> A
      const res2 = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          query: addDepMutation,
          variables: { input: { predecessorId: taskBId, successorId: taskAId, type: "FINISH_TO_START" } },
        });
      expect(res2.body.errors?.[0].message).toContain("Circular dependency");
    });

    it("should reject cross-project dependency", async () => {
      // Create another project and task C
      const startDate = new Date().toISOString();
      const endDate = new Date(Date.now() + 2 * 24 * 60 * 60 * 1000).toISOString();
      const projectRes = await request(app)
        .post("/api/projects")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ name: "GraphQL Project 2", workspaceId, startDate, endDate, status: "ACTIVE" });
      const project2Id = projectRes.body.data.id;

      const mutationCreate = `mutation($input: CreateTaskInput!) { createTask(input: $input) { id } }`;
      const resTaskC = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          query: mutationCreate,
          variables: { input: { title: "Task C", estimatedHours: 1, projectId: project2Id } },
        });
      const taskCId = parseInt(resTaskC.body.data.createTask.id);

      const addDepMutation = `mutation($input: AddTaskDependencyInput!) { addTaskDependency(input: $input) { predecessorId successorId } }`;
      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          query: addDepMutation,
          variables: { input: { predecessorId: taskAId, successorId: taskCId, type: "FINISH_TO_START" } },
        });
      expect(res.body.errors?.[0].message).toContain("Tasks must belong to the same project");
    });

    it("removeTaskDependency should enforce authorization", async () => {
      // Ensure a dependency exists A -> B
      const addDepMutation = `mutation($input: AddTaskDependencyInput!) { addTaskDependency(input: $input) { id } }`;
      const resAdd = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          query: addDepMutation,
          variables: { input: { predecessorId: taskAId, successorId: taskBId, type: "FINISH_TO_START" } },
        });
      const depId = resAdd.body.data.addTaskDependency.id;

      // Register a second user and try to remove dependency
      const user2Res = await request(app).post("/api/auth/register").send({
        email: "graphql-deps-2@example.com",
        password: "password123",
        name: "GraphQL Tester 2",
      });
      authToken2 = user2Res.body.data.token;

      const removeDepMutation = `mutation($id: ID!) { removeTaskDependency(id: $id) }`;
      const resRemove = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken2}`)
        .send({ query: removeDepMutation, variables: { id: depId } });
      expect(resRemove.body.errors?.[0].code).toBe("FORBIDDEN");
    });

    it("should reject self-dependency", async () => {
      const addDepMutation = `mutation($input: AddTaskDependencyInput!) { addTaskDependency(input: $input) { predecessorId successorId } }`;
      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({
          query: addDepMutation,
          variables: { input: { predecessorId: taskAId, successorId: taskAId, type: "FINISH_TO_START" } },
        });
      expect(res.body.errors?.[0].message).toContain("Cannot create circular dependency");
      expect(res.body.errors?.[0].extensions.code).toBe("BAD_REQUEST");
    });

    it("addTaskDependency should enforce authorization", async () => {
      // Second user (not member of project) attempts to add dependency
      const addDepMutation = `mutation($input: AddTaskDependencyInput!) { addTaskDependency(input: $input) { predecessorId successorId } }`;
      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken2}`)
        .send({
          query: addDepMutation,
          variables: { input: { predecessorId: taskAId, successorId: taskBId, type: "FINISH_TO_START" } },
        });
      expect(res.body.errors?.[0].extensions.code).toBe("FORBIDDEN");
    });
  });

  describe("Error Handling", () => {
    it("should return error for invalid email", async () => {
      const mutation = `
        mutation {
          register(input: {
            email: "invalid-email"
            password: "password123"
            name: "Test User"
          }) {
            token
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .send({ query: mutation })
        .expect(200);

      // GraphQL always returns 200, errors are in the response
      expect(res.body.errors).toBeDefined();
      expect(res.body.errors[0].code).toBe("BAD_REQUEST");
    });

    it("should return error for unauthorized access", async () => {
      const query = `
        query {
          users(page: 1, limit: 10) {
            edges {
              node {
                id
                email
              }
            }
          }
        }
      `;

      const res = await request(app)
        .post("/graphql")
        .set("Authorization", `Bearer ${authToken}`)
        .send({ query })
        .expect(200);

      expect(res.body.errors).toBeDefined();
      expect(res.body.errors[0].code).toBe("FORBIDDEN");
    });
  });
});
