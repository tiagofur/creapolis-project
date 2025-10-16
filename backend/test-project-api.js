/**
 * Test script for new Project API fields
 * Tests: status, startDate, endDate, managerId, progress
 *
 * Run: node test-project-api.js
 */

import axios from "axios";

const API_URL = "http://localhost:3001/api";
let authToken = "";
let testWorkspaceId = null;
let testProjectId = null;

// Helper: Login and get token
async function login() {
  try {
    const response = await axios.post(`${API_URL}/auth/login`, {
      email: "usuario1@creapolis.com",
      password: "Password123!",
    });

    authToken = response.data.data.token;
    console.log("✅ Login successful");
    return true;
  } catch (error) {
    console.error("❌ Login failed:", error.response?.data || error.message);
    return false;
  }
}

// Helper: Get workspaces
async function getWorkspaces() {
  try {
    const response = await axios.get(`${API_URL}/workspaces`, {
      headers: { Authorization: `Bearer ${authToken}` },
    });

    const workspaces = response.data.data.workspaces;
    if (workspaces && workspaces.length > 0) {
      testWorkspaceId = workspaces[0].id;
      console.log(
        `✅ Found workspace: ${workspaces[0].name} (ID: ${testWorkspaceId})`
      );
      return true;
    }

    console.error("❌ No workspaces found");
    return false;
  } catch (error) {
    console.error(
      "❌ Failed to get workspaces:",
      error.response?.data || error.message
    );
    return false;
  }
}

// Test 1: Create project with new fields
async function testCreateProject() {
  console.log("\n🧪 TEST 1: Create Project with new fields");

  try {
    const startDate = new Date();
    const endDate = new Date();
    endDate.setMonth(endDate.getMonth() + 3); // 3 months from now

    const projectData = {
      name: `Test Project ${Date.now()}`,
      description: "Testing new Project fields",
      workspaceId: testWorkspaceId,
      status: "PLANNED",
      startDate: startDate.toISOString(),
      endDate: endDate.toISOString(),
      // managerId will default to current user
    };

    const response = await axios.post(`${API_URL}/projects`, projectData, {
      headers: { Authorization: `Bearer ${authToken}` },
    });

    const project = response.data.data;
    testProjectId = project.id;

    console.log("✅ Project created successfully:");
    console.log(`   - ID: ${project.id}`);
    console.log(`   - Name: ${project.name}`);
    console.log(`   - Status: ${project.status}`);
    console.log(`   - Start: ${project.startDate}`);
    console.log(`   - End: ${project.endDate}`);
    console.log(
      `   - Manager: ${project.manager?.name || "N/A"} (ID: ${
        project.managerId
      })`
    );
    console.log(`   - Progress: ${project.progress}`);

    return true;
  } catch (error) {
    console.error(
      "❌ Create project failed:",
      error.response?.data || error.message
    );
    return false;
  }
}

// Test 2: Update project
async function testUpdateProject() {
  console.log("\n🧪 TEST 2: Update Project fields");

  if (!testProjectId) {
    console.error("❌ No project to update");
    return false;
  }

  try {
    const updateData = {
      status: "ACTIVE",
      progress: 0.25,
      description: "Updated description - now active",
    };

    const response = await axios.put(
      `${API_URL}/projects/${testProjectId}`,
      updateData,
      {
        headers: { Authorization: `Bearer ${authToken}` },
      }
    );

    const project = response.data.data;

    console.log("✅ Project updated successfully:");
    console.log(`   - Status: ${project.status}`);
    console.log(`   - Progress: ${project.progress}`);
    console.log(`   - Description: ${project.description}`);
    console.log(`   - Manager: ${project.manager?.name || "N/A"}`);

    return true;
  } catch (error) {
    console.error(
      "❌ Update project failed:",
      error.response?.data || error.message
    );
    return false;
  }
}

// Test 3: Get project by ID
async function testGetProject() {
  console.log("\n🧪 TEST 3: Get Project by ID (verify manager relation)");

  if (!testProjectId) {
    console.error("❌ No project to get");
    return false;
  }

  try {
    const response = await axios.get(`${API_URL}/projects/${testProjectId}`, {
      headers: { Authorization: `Bearer ${authToken}` },
    });

    const project = response.data.data;

    console.log("✅ Project retrieved successfully:");
    console.log(`   - Name: ${project.name}`);
    console.log(`   - Status: ${project.status}`);
    console.log(`   - Progress: ${project.progress}`);
    console.log(`   - Manager: ${JSON.stringify(project.manager, null, 2)}`);
    console.log(`   - Members: ${project.members?.length || 0} members`);

    return true;
  } catch (error) {
    console.error(
      "❌ Get project failed:",
      error.response?.data || error.message
    );
    return false;
  }
}

// Test 4: Validation errors
async function testValidation() {
  console.log("\n🧪 TEST 4: Validation (invalid status)");

  try {
    const projectData = {
      name: "Invalid Project",
      description: "Testing validation",
      workspaceId: testWorkspaceId,
      status: "INVALID_STATUS", // Should fail
      startDate: new Date().toISOString(),
      endDate: new Date().toISOString(),
    };

    await axios.post(`${API_URL}/projects`, projectData, {
      headers: { Authorization: `Bearer ${authToken}` },
    });

    console.error("❌ Validation should have failed but succeeded");
    return false;
  } catch (error) {
    if (error.response?.status === 400) {
      console.log("✅ Validation correctly rejected invalid status");
      console.log(`   - Error: ${error.response.data.message}`);
      return true;
    }
    console.error(
      "❌ Unexpected error:",
      error.response?.data || error.message
    );
    return false;
  }
}

// Main test runner
async function runTests() {
  console.log("🚀 Starting Project API Tests\n");

  // Setup
  if (!(await login())) {
    console.log("\n❌ Tests aborted: Login failed");
    return;
  }

  if (!(await getWorkspaces())) {
    console.log("\n❌ Tests aborted: No workspaces available");
    return;
  }

  // Run tests
  const results = [];
  results.push(await testCreateProject());
  results.push(await testUpdateProject());
  results.push(await testGetProject());
  results.push(await testValidation());

  // Summary
  const passed = results.filter((r) => r).length;
  const total = results.length;

  console.log("\n" + "=".repeat(50));
  console.log(`📊 Test Results: ${passed}/${total} passed`);
  console.log("=".repeat(50));

  if (passed === total) {
    console.log("✅ All tests passed!");
  } else {
    console.log("❌ Some tests failed");
  }
}

// Run
runTests().catch(console.error);
