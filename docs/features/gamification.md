# Gamification Feature

## Overview

The Gamification feature aims to increase user engagement by rewarding actions with reputation points and badges. It includes a leaderboard to foster friendly competition.

## Architecture

### Backend

- **Service**: `src/services/gamification.service.js` - Centralizes logic for points, badges, and rules.
- **Controller**: `src/controllers/gamification.controller.js` - Endpoints for stats and leaderboard.
- **Routes**: `/api/gamification/me`, `/api/gamification/leaderboard`.
- **Database**: Uses `User` (reputation), `Badge`, and `ReputationLog` models.

### Frontend (Flutter)

- **Domain**:
  - Entities: `GamificationStats`, `Badge`, `ReputationLog`.
  - Repository: `GamificationRepository`.
  - UseCases: `GetGamificationStatsUseCase`, `GetLeaderboardUseCase`.
- **Data**:
  - DataSource: `GamificationRemoteDataSource`.
  - Repository Impl: `GamificationRepositoryImpl`.
  - Models: `UserModel` (updated with reputation).
- **Presentation**:
  - BLoC: `GamificationBloc`.
  - Widgets: `GamificationCard` (in Profile).
  - Screens: `LeaderboardScreen`.

## Key Features

1. **Reputation Points**: Awarded for actions like voting (logic in `GamificationService`).
2. **Badges**: Awarded based on milestones (e.g., "First Vote").
3. **Leaderboard**: Displays top users based on reputation.
4. **Profile Integration**: Shows current reputation and recent badges in the user profile.

## Future Improvements

- Add more badge types and rules.
- Implement levels based on reputation points.
- Add notifications when a badge is earned.
