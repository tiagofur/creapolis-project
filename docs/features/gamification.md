# Gamification

This document describes the Gamification feature in Creapolis.

## Overview

The Gamification feature is designed to increase user engagement and motivation by rewarding users for their activity within the application. Users can earn points, unlock badges, and complete achievements.

## Backend

### Prisma Models

The following models have been added to the `schema.prisma` file:
- `Badge`: Defines a badge that can be earned.
- `UserBadge`: Links a user to an earned badge.
- `UserActivity`: Logs user activities that contribute to gamification.
- `Achievement`: Defines an achievement that can be unlocked.
- `UserAchievement`: Links a user to an unlocked achievement.

### Gamification Service (`gamification.service.js`)

The `backend/src/services/gamification.service.js` file provides the core logic for the gamification system:
- `recordActivity`: Logs a user activity, updates the user's reputation (points), and checks for new achievements and badges.
- `checkAchievements`: Updates a user's progress towards achievements based on their activities.
- `checkBadges`: Awards badges to users based on their stats (e.g., number of completed tasks).
- `awardBadge`: Awards a specific badge to a user if they haven't earned it yet.
- `getGamificationProfile`: Retrieves a user's complete gamification profile, including points, badges, and achievements.

### API Routes (`gamification.routes.js`)

- `GET /api/gamification/profile/:userId`: Retrieves the gamification profile for a given user.

## Frontend (Flutter)

### Entities

- `Badge`: Represents a badge.
- `Achievement`: Represents an achievement, including progress.
- `GamificationProfile`: A comprehensive model for a user's gamification status.

### Gamification Service (`gamification_service.dart`)

- `getGamificationProfile(userId)`: Fetches the gamification profile from the backend.

### Screens

- `GamificationProfileScreen`: A new screen that displays the user's gamification profile, including:
    - Total points.
    - A grid of earned badges.
    - A list of achievements with their progress.