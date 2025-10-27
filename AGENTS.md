# Overview

This document provides essential context for AI when working with the PrivateBin project. It contains project-specific information, conventions, and important details that should be considered in all interactions.

## Project Overview

**PrivateBin** is a minimalist, open-source online pastebin where the server has zero knowledge of stored data. Data is encrypted and decrypted in the browser using 256-bit AES in Galois Counter mode (GCM).

### Key Characteristics

- **Zero-knowledge**: Server never sees unencrypted data
- **Client-side encryption**: All encryption/decryption happens in the browser
- **Multiple storage backends**: Filesystem, Database (PDO), S3, Google Cloud Storage
- **Multi-language support**: Full internationalization
- **Security-focused**: End-to-end encryption, secure configurations
- **Self-hosted**: Designed for independent deployment

## Technical Stack

### Backend (PHP)

- **PHP Version**: 7.4+ (current development uses 8.2)
- **Framework**: Custom MVC architecture
- **Dependencies**: Managed via Composer
- **Key Libraries**:
  - `jdenticon/jdenticon`: Icon generation
  - `mlocati/ip-lib`: IP address handling
  - `symfony/polyfill-php80`: PHP compatibility
  - `yzalis/identicon`: User identicons

### Frontend (JavaScript)

- **Main Application**: `js/privatebin.js` (~6000 lines)
- **Legacy Support**: `js/legacy.js` for older browsers
- **Dependencies**: jQuery, Bootstrap, Showdown (Markdown), DOMPurify
- **Testing**: Mocha with NYC for coverage
- **Build Process**: No complex build system, direct file serving

### Storage Backends

1. **Filesystem** (default): File-based storage in `data/` directory
2. **Database**: PDO-compatible databases (MySQL, PostgreSQL, SQLite)
3. **S3Storage**: AWS S3 or S3-compatible (CEPH RadosGW)
4. **GoogleCloudStorage**: Google Cloud Storage integration

## Project Structure

```text
PrivateBin/
├── index.php                 # Application entry point
├── lib/                      # Core PHP classes
│   ├── Controller.php        # Main application controller
│   ├── Configuration.php     # Configuration management
│   ├── View.php             # Template rendering
│   ├── I18n.php             # Internationalization
│   ├── Model/               # Data models
│   ├── Data/                # Storage backend implementations
│   └── Persistence/         # Data persistence classes
├── tpl/                     # HTML templates
│   ├── bootstrap5.php       # Default modern template
│   └── bootstrap.php        # Legacy template
├── js/                      # JavaScript files
│   ├── privatebin.js        # Main application logic
│   ├── legacy.js           # Legacy browser support
│   ├── test/               # JavaScript tests
│   └── package.json        # Node.js dependencies
├── css/                     # Stylesheets
├── cfg/                     # Configuration
│   └── conf.sample.php     # Configuration template
├── i18n/                    # Translation files
├── doc/                     # Documentation
├── tst/                     # PHP unit tests
├── composer.json           # PHP dependencies
├── Makefile               # Build and development commands
└── Docker files           # Container environment
```

## Pull request review

Following are instructions for handling pull request code review request:

1. In 2–3 sentences, describe a high level summary of changes in the pull request:  
   – **Product impact**: What does this change deliver for users or customers?  
   – **Engineering approach**: Key patterns, frameworks, or best practices in use.

2. Identify the scope of the pull request:
   - Get existing comments: gh pr view --json comments
   - Get diff: gh pr diff
   - If a previously reported issue appears fixed by nearby changes, reply: ✅ This issue appears to be resolved by the recent changes
   - Avoid duplicates: skip if similar feedback already exists on or near the same lines  

3. For each new or changed file, evaluate the changes in the context of the existing codebase. Understand how the modified code interacts with surrounding logic and related files—such as how input variables are derived, how return values are consumed, and whether the change introduces side effects or breaks assumptions elsewhere. Assess each change against the following principles:
   - **Design & Architecture**: Verify the change fits your system’s architectural patterns, avoids unnecessary coupling or speculative features, enforces clear separation of concerns, and aligns with defined module boundaries.
   - **Complexity & Maintainability**: Ensure control flow remains flat, cyclomatic complexity stays low, duplicate logic is abstracted (DRY), dead or unreachable code is removed, and any dense logic is refactored into testable helper methods.
   - **Functionality & Correctness**: Confirm new code paths behave correctly under valid and invalid inputs, cover all edge cases, maintain idempotency for retry-safe operations, satisfy all functional requirements or user stories, and include robust error-handling semantics.
   - **Readability & Naming**: Check that identifiers clearly convey intent, comments explain *why* (not *what*), code blocks are logically ordered, and no surprising side-effects hide behind deceptively simple names.
   - **Best Practices & Patterns**: Validate use of language- or framework-specific idioms, adherence to SOLID principles, proper resource cleanup, consistent logging/tracing, and clear separation of responsibilities across layers.
   - **Test Coverage & Quality**: Verify unit tests for both success and failure paths, integration tests exercising end-to-end flows, appropriate use of mocks/stubs, meaningful assertions (including edge-case inputs), and that test names accurately describe behavior.
   - **Standardization & Style**: Ensure conformance to style guides (indentation, import/order, naming conventions), consistent project structure (folder/file placement), and zero new linter or formatter warnings.
   - **Documentation & Comments**: Confirm public APIs or complex algorithms have clear in-code documentation, and that README, Swagger/OpenAPI, CHANGELOG, or other user-facing docs are updated to reflect visible changes or configuration tweaks.
   - **Security & Compliance**: Check input validation and sanitization against injection attacks, proper output encoding, secure error handling, dependency license and vulnerability checks, secrets management best practices, enforcement of authZ/authN, and relevant regulatory compliance (e.g. GDPR, HIPAA).
   - **Performance & Scalability**: Identify N+1 query patterns or inefficient I/O (streaming vs. buffering), memory management concerns, heavy hot-path computations, or unnecessary UI re-renders; suggest caching, batching, memoization, async patterns, or algorithmic optimizations.
   - **Observability & Logging**: Verify that key events emit metrics or tracing spans, logs use appropriate levels, sensitive data is redacted, and contextual information is included to support monitoring, alerting, and post-mortem debugging.
   - **Accessibility & Internationalization**: For UI code, ensure use of semantic HTML, correct ARIA attributes, keyboard navigability, color-contrast considerations, and that all user-facing strings are externalized for localization.
   - **CI/CD & DevOps**: Validate build pipeline integrity (automated test gating, artifact creation), infra-as-code correctness, dependency declarations, deployment/rollback strategies, and adherence to organizational DevOps best practices.
   - **AI-Assisted Code Review**: For AI-generated snippets, ensure alignment with your architectural and naming conventions, absence of hidden dependencies or licensing conflicts, inclusion of tests and docs, and consistent style alongside human-authored code.

4. Produce a report of issues in nested bullets:
   For each validated issue, output a nested bullet like this:  
   - File: `<path>:<line-range>`  
     - Issue: [One-line summary of the root problem]  
     - Fix: [Concise suggested change or code snippet]  

5. Produce a section titled `## Prioritized Issues` listing issues grouped by priority. Present all bullets from step 3 grouped by severity in the order listed below with no extra prose:

   - ### Critical

   - ### Major

   - ### Minor

   - ### Enhancement

Throughout the code review, maintain a polite, professional tone; keep comments as brief as possible without losing clarity; and ensure you only analyze files with actual content changes.
