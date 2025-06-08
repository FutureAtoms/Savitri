# Database Schema and Migration Documentation

## Overview

The Ashray Psychology App uses MongoDB as its primary database with a comprehensive schema design optimized for clinical psychology workflows, HIPAA compliance, and high-performance queries.

## Database Models

### 1. User Model (`src/models/user.model.ts`)
- **Purpose**: Stores user account information, preferences, and clinical data
- **Key Features**:
  - Secure password storage with bcrypt
  - Role-based access control (user/therapist/admin)
  - Voice biometric authentication support
  - Emergency contact information
  - HIPAA-compliant consent tracking

### 2. Session Model (`src/models/session.model.ts`)
- **Purpose**: Manages therapy sessions with detailed interaction tracking
- **Key Features**:
  - Real-time interaction logging
  - Clinical notes (SOAP format)
  - Risk assessment tracking
  - Billing information with CPT codes
  - Audio data storage capability

### 3. EmotionData Model (`src/models/emotion-data.model.ts`)
- **Purpose**: Stores detailed emotion analysis from voice and text
- **Key Features**:
  - Plutchik's emotion wheel (8 basic emotions)
  - Clinical markers (anxiety, depression indicators)
  - Voice prosody metrics
  - ML model metadata and confidence scores
  - Clinician review workflow

### 4. CrisisEvent Model (`src/models/crisis-event.model.ts`)
- **Purpose**: Tracks and manages crisis events with intervention details
- **Key Features**:
  - Multi-level crisis severity tracking
  - Risk and protective factors assessment
  - Safety plan documentation
  - Intervention tracking with outcomes
  - Mandatory reporting compliance
  - Comprehensive audit trail

### 5. TreatmentPlan Model (`src/models/treatment-plan.model.ts`)
- **Purpose**: Manages personalized treatment plans with goals and progress
- **Key Features**:
  - Clinical assessment with DSM-5/ICD-10 codes
  - SMART goals with progress tracking
  - Evidence-based intervention planning
  - Medication management
  - Crisis management integration
  - Outcome metrics (PHQ-9, GAD-7)
  - Care team collaboration

## Database Indexes

### Performance Optimization Strategy

All collections have compound indexes optimized for common query patterns:

#### User Indexes:
- `email_unique`: Unique index for authentication
- `role_active`: Role-based queries with active status
- `recent_active_users`: Recent user activity tracking

#### Session Indexes:
- `user_sessions_recent`: User's recent sessions
- `risk_level`: High-risk session identification
- `billing_code`: Financial reporting

#### EmotionData Indexes:
- `user_emotions_timeline`: Time-series emotion analysis
- `anxiety_timeline`: Clinical marker tracking
- `review_queue`: Clinician review workflow

#### CrisisEvent Indexes:
- `user_crisis_severity`: Critical event monitoring
- `mandatory_reporting`: Compliance tracking
- `follow_up_due`: Follow-up management

#### TreatmentPlan Indexes:
- `user_active_plans`: Active treatment plans
- `risk_plans`: High-risk patient monitoring
- `review_schedule`: Plan review scheduling

## Migration System

### Features
- **Version Control**: Each migration has a unique timestamp-based version
- **Rollback Support**: All migrations include up() and down() methods
- **Checksum Validation**: Ensures migration integrity
- **Batch Processing**: Groups related migrations
- **Transaction Safety**: Migrations run in MongoDB transactions

### Usage

```bash
# Run all pending migrations
npm run migrate:up

# Run migrations up to specific version
npm run migrate up 20250602000001

# Rollback last migration
npm run migrate:down

# Rollback last 3 migrations
npm run migrate down 3

# Check migration status
npm run migrate:status

# Create new migration
npm run migrate:create add_user_field

# Development only - reset all migrations
npm run migrate reset

# Development only - reset and re-run all
npm run migrate refresh
```

### Migration Files

Migrations are stored in `src/migrations/` with the naming convention:
`YYYYMMDDHHMMSS_description.ts`

Example migration structure:
```typescript
import { MigrationFile } from '../services/migration-runner.service';

const migration: MigrationFile = {
  version: '20250602000001',
  name: 'Add user field',
  description: 'Adds new field to user collection',
  
  async up(db) {
    // Forward migration logic
  },
  
  async down(db) {
    // Rollback logic
  }
};

export default migration;
```

## Data Validation

### Validation Middleware

Located in `src/middleware/validation.middleware.ts`, provides:

1. **Joi Schema Validation**: Comprehensive input validation for all models
2. **Custom Validators**: Business rule validation (age, phone, CPT codes)
3. **Request Sanitization**: Removes MongoDB operators from user input
4. **HIPAA Compliance**: Ensures audit logging for PHI access

### Usage Example

```typescript
import { validationMiddleware } from '../middleware/validation.middleware';

router.post('/users',
  validationMiddleware.sanitizeRequest,
  validationMiddleware.validateRequest(
    validationMiddleware.schemas.user.create
  ),
  validationMiddleware.validateHIPAACompliance,
  createUser
);
```

## Schema Hooks and Methods

### Pre-save Hooks
- **User**: Account locking after failed attempts
- **Session**: Duration calculation
- **EmotionData**: Auto-flag high-risk indicators
- **CrisisEvent**: Mandatory reporting checks
- **TreatmentPlan**: Goal completion tracking

### Instance Methods
- `user.isLocked()`: Check account lock status
- `session.addInteraction()`: Add therapy interaction
- `emotionData.getClinicalSeverity()`: Calculate severity score
- `crisisEvent.calculateRiskScore()`: Compute risk assessment
- `treatmentPlan.calculateProgress()`: Track goal progress

### Static Methods
- `CrisisEvent.getActiveHighRiskEvents()`: Find critical events
- `TreatmentPlan.getPlansForReview()`: Due for review
- `Migration.getLastBatch()`: Migration batch tracking

## Best Practices

### 1. Always Use Transactions
```typescript
const session = await mongoose.startSession();
await session.withTransaction(async () => {
  // Multiple operations
});
```

### 2. Leverage Indexes
```typescript
// Good - uses index
await User.find({ email: 'user@example.com' });

// Bad - no index
await User.find({ 'profile.middleName': 'John' });
```

### 3. Implement Proper Error Handling
```typescript
try {
  await model.save();
} catch (error) {
  if (error.code === 11000) {
    // Handle duplicate key error
  }
  throw error;
}
```

### 4. Use Projection for Performance
```typescript
// Only fetch needed fields
await Session.find({ userId })
  .select('startTime endTime status')
  .lean();
```

## Security Considerations

1. **Encryption**: All PHI fields should be encrypted at rest
2. **Audit Trail**: All data modifications are logged
3. **Access Control**: Role-based permissions enforced
4. **Data Retention**: Implement 7-year retention policy
5. **Backup Strategy**: Regular automated backups with encryption

## Monitoring and Maintenance

### Key Metrics to Monitor:
- Query performance (use explain())
- Index usage statistics
- Collection sizes and growth
- Connection pool utilization
- Slow query log analysis

### Regular Maintenance Tasks:
1. Index optimization (monthly)
2. Database statistics update
3. Orphaned data cleanup
4. Backup verification
5. Security audit log review

## Troubleshooting

### Common Issues:

1. **Slow Queries**: Check index usage with explain()
2. **Connection Issues**: Verify connection string and network
3. **Migration Failures**: Check migration logs and rollback if needed
4. **Validation Errors**: Review Joi schema definitions
5. **Duplicate Key Errors**: Ensure unique constraints are appropriate

## Future Enhancements

1. **Sharding**: For horizontal scaling at 1M+ users
2. **Read Replicas**: For reporting workloads
3. **Change Streams**: Real-time data synchronization
4. **Time Series Collections**: For emotion data optimization
5. **Full-Text Search**: Enhanced clinical note searching
