# 🔄 CI/CD Pipeline Visual Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                     CREAPOLIS CI/CD PIPELINE                        │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  TRIGGER: Pull Request to main/develop                             │
└─────────────────────────────────────────────────────────────────────┘
                              ▼
                    ┌──────────────────┐
                    │   PR Checks      │
                    │   Workflow       │
                    └──────────────────┘
                              ▼
                    ┌──────────────────┐
                    │ Detect Changes   │
                    │  • backend/**    │
                    │  • flutter/**    │
                    └──────────────────┘
                      ▼           ▼
        ┌─────────────────┐   ┌─────────────────┐
        │  Backend Tests  │   │  Flutter Tests  │
        │  • Unit Tests   │   │  • Unit Tests   │
        │  • Integration  │   │  • Widget Tests │
        │  • Coverage     │   │  • Analysis     │
        └─────────────────┘   └─────────────────┘
                      ▼           ▼
                    ┌──────────────────┐
                    │ Comment Results  │
                    │ on PR           │
                    └──────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  TRIGGER: Push to develop                                           │
└─────────────────────────────────────────────────────────────────────┘
                              ▼
        ┌─────────────────────────────────────┐
        │      Run All CI Workflows           │
        │  • Backend CI                       │
        │  • Flutter CI                       │
        └─────────────────────────────────────┘
                              ▼
        ┌─────────────────────────────────────┐
        │    Deploy to Staging                │
        │  • Backend → Staging Server         │
        │  • Flutter Web → Staging Web        │
        │  • Health Checks                    │
        └─────────────────────────────────────┘
                              ▼
        ┌─────────────────────────────────────┐
        │    Send Notifications               │
        │  • Slack                            │
        │  • Email (if failed)                │
        └─────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  TRIGGER: Push to main                                              │
└─────────────────────────────────────────────────────────────────────┘
                              ▼
        ┌─────────────────────────────────────┐
        │      Run All CI Workflows           │
        │  • Backend CI                       │
        │  • Flutter CI                       │
        │  • Android Build (Debug)            │
        │  • iOS Build (Debug)                │
        └─────────────────────────────────────┘
                              ▼
        ┌─────────────────────────────────────┐
        │    Quality Gates                    │
        │  ✓ All tests pass                   │
        │  ✓ Coverage threshold met           │
        │  ✓ No critical issues               │
        └─────────────────────────────────────┘
                              ▼
        ┌─────────────────────────────────────┐
        │    Notifications                    │
        │  • Success/Failure alerts           │
        │  • Create Issue if failed           │
        └─────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  TRIGGER: Tag push (v*)                                             │
└─────────────────────────────────────────────────────────────────────┘
                              ▼
        ┌─────────────────────────────────────┐
        │      Release Builds                 │
        └─────────────────────────────────────┘
                    ▼           ▼
        ┌─────────────────┐   ┌─────────────────┐
        │  Android Build  │   │   iOS Build     │
        │  • Release APK  │   │  • Release IPA  │
        │  • App Bundle   │   │  • Archive      │
        │  • Signed       │   │  • Signed       │
        └─────────────────┘   └─────────────────┘
                    ▼           ▼
        ┌─────────────────────────────────────┐
        │    Create GitHub Release            │
        │  • Upload APK                       │
        │  • Upload AAB                       │
        │  • Upload IPA                       │
        │  • Release notes                    │
        └─────────────────────────────────────┘
                              ▼
        ┌─────────────────────────────────────┐
        │    Notify Team                      │
        │  • Slack announcement               │
        │  • Email notification               │
        └─────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│  NOTIFICATION SYSTEM (Always Active)                                │
└─────────────────────────────────────────────────────────────────────┘

        Every Workflow Completion
                  ▼
        ┌──────────────────┐
        │  Check Status    │
        │  • success       │
        │  • failure       │
        │  • cancelled     │
        └──────────────────┘
                  ▼
        ┌──────────────────┐
        │  Send to:        │
        │  • Slack         │
        │  • Email         │
        │  • GitHub Issues │
        └──────────────────┘

════════════════════════════════════════════════════════════════════

WORKFLOW SUMMARY
════════════════════════════════════════════════════════════════════

┌─────────────────────┬───────────────┬──────────────────────────┐
│ Workflow            │ Trigger       │ Duration                 │
├─────────────────────┼───────────────┼──────────────────────────┤
│ Backend CI          │ PR, Push      │ ~3 minutes               │
│ Flutter CI          │ PR, Push      │ ~5 minutes               │
│ Android Build       │ PR, Push, Tag │ ~8 minutes               │
│ iOS Build           │ PR, Push, Tag │ ~12 minutes              │
│ Deploy Staging      │ Push develop  │ ~5 minutes               │
│ PR Checks           │ PR only       │ ~5 minutes               │
│ Notifications       │ On completion │ ~30 seconds              │
└─────────────────────┴───────────────┴──────────────────────────┘

════════════════════════════════════════════════════════════════════

SECRETS CONFIGURATION
════════════════════════════════════════════════════════════════════

Essential (Recommended):
  • CODECOV_TOKEN

For Release Builds:
  • ANDROID_KEYSTORE_PASSWORD
  • ANDROID_KEY_PASSWORD  
  • ANDROID_KEY_ALIAS
  • IOS_MATCH_PASSWORD
  • IOS_FASTLANE_PASSWORD

For Staging Deployment:
  • STAGING_DATABASE_URL
  • STAGING_HOST / STAGING_USER / STAGING_SSH_KEY
  • STAGING_API_URL
  • STAGING_WEB_HOST / STAGING_WEB_USER / STAGING_WEB_SSH_KEY

For Notifications:
  • SLACK_WEBHOOK
  • MAIL_SERVER / MAIL_PORT / MAIL_USERNAME / MAIL_PASSWORD
  • NOTIFICATION_EMAIL

════════════════════════════════════════════════════════════════════
```

## Legend

```
┌─────┐
│ Box │  = Workflow / Job / Step
└─────┘

   ▼     = Flow direction

  ═══    = Section separator
```

## Quick Status Reference

| Symbol | Meaning |
|--------|---------|
| ✓ | Required check passed |
| ✗ | Check failed |
| ⚠ | Warning / Optional |
| 🚀 | Deployment triggered |
| 📧 | Notification sent |
| 📱 | Mobile build |
| 🌐 | Web build |

## Workflow Files Location

```
.github/
├── workflows/
│   ├── backend-ci.yml         # Backend continuous integration
│   ├── flutter-ci.yml         # Flutter continuous integration
│   ├── android-build.yml      # Android app builds
│   ├── ios-build.yml          # iOS app builds
│   ├── deploy-staging.yml     # Staging deployment
│   ├── pr-checks.yml          # Pull request automation
│   └── notifications.yml      # Status notifications
├── CI_CD_DOCUMENTATION.md     # Complete documentation
└── CI_CD_QUICKSTART.md        # Quick reference guide
```
