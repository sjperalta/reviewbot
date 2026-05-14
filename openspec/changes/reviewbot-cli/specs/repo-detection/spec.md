## ADDED Requirements

### Requirement: System detects Ruby on Rails projects
The system SHALL identify a project as Ruby on Rails when it contains a `Gemfile` with `rails` gem and has `config/application.rb`.

#### Scenario: Detect Rails project
- **WHEN** the system inspects the repository root
- **AND** a `Gemfile` exists with `gem 'rails'`
- **AND** `config/application.rb` exists
- **THEN** the system sets stack to `rails`

### Requirement: System detects Ruby projects
The system SHALL identify a project as Ruby when it contains a `Gemfile` but does not match Rails detection criteria.

#### Scenario: Detect Ruby project
- **WHEN** the system inspects the repository root
- **AND** a `Gemfile` exists but Rails is not detected
- **THEN** the system sets stack to `ruby`

### Requirement: System detects JavaScript/TypeScript projects
The system SHALL identify a project as JavaScript or TypeScript when it contains `package.json`.

#### Scenario: Detect JS/TS project
- **WHEN** the system inspects the repository root
- **AND** `package.json` exists
- **THEN** the system checks for `react` dependency and sets React flag if present
- **THEN** the system checks for `tsconfig.json` and sets TypeScript flag if present

### Requirement: System detects React projects
The system SHALL detect React specifically when `package.json` contains `react` or `react-dom` as a dependency.

#### Scenario: Detect React
- **WHEN** `package.json` exists
- **AND** it includes `react` or `react-dom` in dependencies or devDependencies
- **THEN** the system sets the React flag

### Requirement: System detects TypeScript usage
The system SHALL detect TypeScript when a `tsconfig.json` exists or `.ts`/`.tsx` files are present.

#### Scenario: Detect TypeScript
- **WHEN** a `tsconfig.json` file exists in the repository root
- **OR** there are `.ts` or `.tsx` files in the source tree
- **THEN** the system sets the TypeScript flag

### Requirement: System detects Flutter/Dart projects
The system SHALL detect Flutter projects by the presence of `pubspec.yaml` with a Flutter SDK dependency.

#### Scenario: Detect Flutter project
- **WHEN** `pubspec.yaml` exists
- **AND** it contains `sdk: flutter` under dependencies
- **THEN** the system sets stack to `flutter`

#### Scenario: Detect pure Dart project
- **WHEN** `pubspec.yaml` exists
- **AND** it does NOT contain `sdk: flutter`
- **AND** there are `.dart` files in the source tree
- **THEN** the system sets stack to `dart`

### Requirement: System detects Go projects
The system SHALL detect Go projects by the presence of `go.mod`.

#### Scenario: Detect Go project
- **WHEN** `go.mod` exists in the repository root
- **THEN** the system sets stack to `go`

### Requirement: System detects monorepos with multiple stacks
The system SHALL detect and report multiple stacks in a single repository.

#### Scenario: Detect monorepo
- **WHEN** multiple stack indicators are found (e.g., both `Gemfile` and `package.json`)
- **THEN** the system records all detected stacks
- **THEN** the primary stack is determined by the most relevant indicators

### Requirement: System produces a repository profile
The system SHALL create a structured repository profile object with detected languages, frameworks, and configuration.

#### Scenario: Build repository profile
- **WHEN** detection completes
- **THEN** the system returns a profile with detected stacks, languages, frameworks, and config paths
- **THEN** the profile is used to select appropriate reviewers and analyzers
