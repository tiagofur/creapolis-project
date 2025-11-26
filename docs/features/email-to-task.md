# Email-to-Task

This document describes the Email-to-Task feature in Creapolis.

## Overview

The Email-to-Task feature allows users to create tasks by sending emails to a specific address. The system parses the email, extracts task details, and creates a task in the specified project.

## Backend

### Email Parser Service (`emailToTask.service.js`)

The `backend/src/services/emailToTask.service.js` file contains the core logic for this feature. It uses the `mailparser` library to parse raw email content.

### NLP for Task Details

The service leverages the existing `nlpService` to extract structured information from the email's body, such as:
- Title
- Description
- Priority
- Due Date
- Assignee
- Category
- Estimated Hours

If the NLP service cannot extract a title, the email's subject is used as a fallback.

### Gmail API Integration (`gmail.service.js`)

The `backend/src/services/gmail.service.js` file provides integration with the Gmail API to:
- **Watch for new emails**: It can be configured to use Google Pub/Sub to listen for new emails in real-time (requires setup in Google Cloud).
- **Process unread emails**: It can fetch unread emails from the inbox, process them to create tasks, and mark them as read.

Authentication is handled via OAuth2, using tokens stored for each user.

### Auto-assignment Rules

A basic auto-assignment rule has been implemented in `emailToTask.service.js`. As a proof-of-concept, the rule is:
- If an email is received from a `@example.com` domain, the created task is automatically assigned to a predefined user (`test@example.com`).

This can be expanded in the future to a more robust, user-configurable rule engine.

## How It Works

1.  A user sends an email to a designated Creapolis email address.
2.  The email is received by the system (either via a webhook from a service like SendGrid/Mailgun, or by polling a Gmail inbox).
3.  The `gmail.service.js` fetches the raw email content.
4.  The `emailToTask.service.js` uses `mailparser` to parse the email.
5.  The `nlpService` analyzes the email body to extract task details.
6.  Auto-assignment rules are checked to determine the assignee.
7.  A new task is created in the specified workspace and project.
8.  The email is marked as processed (e.g., marked as read or archived).

This feature streamlines the process of creating tasks from external communications, integrating them directly into the Creapolis workflow.
