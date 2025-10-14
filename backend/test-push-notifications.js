/**
 * Test script for Push Notification System
 * 
 * Run with: node backend/test-push-notifications.js
 * 
 * Prerequisites:
 * - Backend server running
 * - Firebase credentials configured in .env
 * - At least one user registered
 */

import dotenv from 'dotenv';
dotenv.config();

import firebaseService from './src/services/firebase.service.js';
import pushNotificationService from './src/services/push-notification.service.js';
import notificationService from './src/services/notification.service.js';

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  blue: '\x1b[36m',
};

function log(message, color = colors.reset) {
  console.log(`${color}${message}${colors.reset}`);
}

async function testFirebaseInitialization() {
  log('\n1. Testing Firebase Initialization...', colors.blue);
  
  try {
    firebaseService.initialize();
    
    if (firebaseService.isInitialized()) {
      log('✓ Firebase initialized successfully', colors.green);
      return true;
    } else {
      log('✗ Firebase not initialized (credentials missing?)', colors.yellow);
      log('  This is OK for local dev without Firebase', colors.yellow);
      return false;
    }
  } catch (error) {
    log(`✗ Error initializing Firebase: ${error.message}`, colors.red);
    return false;
  }
}

async function testPreferencesCreation() {
  log('\n2. Testing Notification Preferences...', colors.blue);
  
  try {
    const testUserId = 1; // Assuming user 1 exists
    
    // Get or create preferences
    const preferences = await pushNotificationService.getUserPreferences(testUserId);
    
    log('✓ Preferences retrieved/created successfully', colors.green);
    log(`  Push enabled: ${preferences.pushEnabled}`, colors.reset);
    log(`  Email enabled: ${preferences.emailEnabled}`, colors.reset);
    log(`  Mention notifications: ${preferences.mentionNotifications}`, colors.reset);
    
    return true;
  } catch (error) {
    log(`✗ Error with preferences: ${error.message}`, colors.red);
    return false;
  }
}

async function testPreferencesUpdate() {
  log('\n3. Testing Preferences Update...', colors.blue);
  
  try {
    const testUserId = 1;
    
    // Update some preferences
    const updated = await pushNotificationService.updateUserPreferences(testUserId, {
      mentionNotifications: true,
      taskAssignedNotifications: true,
    });
    
    log('✓ Preferences updated successfully', colors.green);
    log(`  Mention notifications: ${updated.mentionNotifications}`, colors.reset);
    log(`  Task assigned notifications: ${updated.taskAssignedNotifications}`, colors.reset);
    
    return true;
  } catch (error) {
    log(`✗ Error updating preferences: ${error.message}`, colors.red);
    return false;
  }
}

async function testDeviceTokenRegistration() {
  log('\n4. Testing Device Token Registration...', colors.blue);
  
  try {
    const testUserId = 1;
    const testToken = `test_token_${Date.now()}`;
    
    // Register a test token
    const deviceToken = await pushNotificationService.registerDeviceToken(
      testUserId,
      testToken,
      'WEB'
    );
    
    log('✓ Device token registered successfully', colors.green);
    log(`  Token ID: ${deviceToken.id}`, colors.reset);
    log(`  Platform: ${deviceToken.platform}`, colors.reset);
    log(`  Active: ${deviceToken.isActive}`, colors.reset);
    
    // Clean up - unregister the test token
    await pushNotificationService.unregisterDeviceToken(testToken);
    log('✓ Test token cleaned up', colors.green);
    
    return true;
  } catch (error) {
    log(`✗ Error with device token: ${error.message}`, colors.red);
    return false;
  }
}

async function testNotificationCreation() {
  log('\n5. Testing Notification Creation...', colors.blue);
  
  try {
    const testUserId = 1;
    
    // Create a test notification
    const notification = await notificationService.createNotification({
      userId: testUserId,
      type: 'SYSTEM',
      title: 'Test Notification',
      message: 'This is a test notification from the push notification system',
      relatedId: null,
      relatedType: null,
    });
    
    log('✓ Notification created successfully', colors.green);
    log(`  ID: ${notification.id}`, colors.reset);
    log(`  Title: ${notification.title}`, colors.reset);
    log(`  Type: ${notification.type}`, colors.reset);
    
    return true;
  } catch (error) {
    log(`✗ Error creating notification: ${error.message}`, colors.red);
    return false;
  }
}

async function testNotificationLogs() {
  log('\n6. Testing Notification Logs...', colors.blue);
  
  try {
    const testUserId = 1;
    
    // Get notification logs
    const logs = await pushNotificationService.getNotificationLogs(testUserId, 5);
    
    log(`✓ Retrieved ${logs.length} notification logs`, colors.green);
    
    if (logs.length > 0) {
      const lastLog = logs[0];
      log(`  Last log status: ${lastLog.status}`, colors.reset);
      log(`  Type: ${lastLog.type}`, colors.reset);
      log(`  Sent at: ${lastLog.sentAt}`, colors.reset);
    }
    
    return true;
  } catch (error) {
    log(`✗ Error getting logs: ${error.message}`, colors.red);
    return false;
  }
}

async function testNotificationMetrics() {
  log('\n7. Testing Notification Metrics...', colors.blue);
  
  try {
    const testUserId = 1;
    const endDate = new Date();
    const startDate = new Date();
    startDate.setDate(startDate.getDate() - 30); // Last 30 days
    
    // Get metrics
    const metrics = await pushNotificationService.getNotificationMetrics(
      testUserId,
      startDate,
      endDate
    );
    
    log('✓ Metrics retrieved successfully', colors.green);
    log(`  Total notifications: ${metrics.total}`, colors.reset);
    log(`  Sent: ${metrics.sent}`, colors.reset);
    log(`  Failed: ${metrics.failed}`, colors.reset);
    
    if (Object.keys(metrics.byType).length > 0) {
      log('  By type:', colors.reset);
      for (const [type, counts] of Object.entries(metrics.byType)) {
        log(`    ${type}: ${counts.total} (${counts.sent} sent, ${counts.failed} failed)`, colors.reset);
      }
    }
    
    return true;
  } catch (error) {
    log(`✗ Error getting metrics: ${error.message}`, colors.red);
    return false;
  }
}

async function runAllTests() {
  log('═══════════════════════════════════════════════════════', colors.blue);
  log('  Push Notification System - Test Suite', colors.blue);
  log('═══════════════════════════════════════════════════════', colors.blue);
  
  const results = [];
  
  // Run tests
  results.push(await testFirebaseInitialization());
  results.push(await testPreferencesCreation());
  results.push(await testPreferencesUpdate());
  results.push(await testDeviceTokenRegistration());
  results.push(await testNotificationCreation());
  results.push(await testNotificationLogs());
  results.push(await testNotificationMetrics());
  
  // Summary
  const passed = results.filter(r => r).length;
  const total = results.length;
  
  log('\n═══════════════════════════════════════════════════════', colors.blue);
  log('  Test Summary', colors.blue);
  log('═══════════════════════════════════════════════════════', colors.blue);
  
  if (passed === total) {
    log(`\n✓ All tests passed (${passed}/${total})`, colors.green);
    log('\nPush notification system is working correctly! 🎉\n', colors.green);
  } else {
    log(`\n⚠ Some tests failed (${passed}/${total} passed)`, colors.yellow);
    log('\nPlease check the errors above and ensure:', colors.yellow);
    log('  1. Backend server is running', colors.reset);
    log('  2. Database is connected', colors.reset);
    log('  3. At least one user exists (ID: 1)', colors.reset);
    log('  4. Firebase credentials are configured (optional for local dev)\n', colors.reset);
  }
  
  process.exit(passed === total ? 0 : 1);
}

// Run tests
runAllTests().catch(error => {
  log(`\n✗ Fatal error: ${error.message}`, colors.red);
  console.error(error);
  process.exit(1);
});
