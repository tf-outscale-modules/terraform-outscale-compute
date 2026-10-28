## ADDED Requirements

### Requirement: Flexible GPU tags not applied
The `tags` field of a `flexible_gpus` entry SHALL be accepted but not applied, because the provider's flexible GPU resource has no tags; its description SHALL say so.

#### Scenario: Tags on a GPU entry
- **WHEN** an entry sets `tags = { Team = "ml" }`
- **THEN** the plan succeeds and the flexible GPU carries no tags
