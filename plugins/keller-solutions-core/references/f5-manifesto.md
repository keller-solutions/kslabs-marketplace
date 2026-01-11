# The F5 Principle: One Command to Running

## The Core Principle

**After cloning a project and running the setup script, you should be able to start the application and have it work.**

No magic incantations. No tribal knowledge. No hunting down a senior developer for the secret steps. Clone, setup, run.

---

## Inspiration

This philosophy is adapted from Khalid Abuhakmeh's **"The F5 Manifesto For .NET Developers"** (January 16, 2014).

> **Note**: The original article at `http://www.khalidabuhakmeh.com/the-f5-manifesto-for-net-developers` can be accessed via the [Internet Archive's Wayback Machine](https://web.archive.org/web/20190826201538/http://www.khalidabuhakmeh.com/the-f5-manifesto-for-net-developers).

The original manifesto established a simple but powerful idea for .NET developers: after pulling from source control and running your build script, hitting F5 (Start Debugging) should give you a functioning application. This principle transcends any single framework or language.

---

## The Rules

### 1. No Special Tools Required

Never force your workflow or toolset on other developers. If you decide to use a particular IDE, editor plugin, or productivity tool, that's your choice. It should never be a requirement to work on the project.

**The test**: Can a developer with only the standard language runtime and a text editor get the project running?

**Examples of violations**:

- Requiring RubyMine-specific features
- Needing a $2000 piece of software to compile
- Assuming everyone has the same shell aliases

### 2. Application Awareness (Self-Healing Setup)

If the project depends on folders existing, databases having particular schemas, or services being installed, the setup script should be smart enough to create them automatically.

**The setup script should**:

- Create necessary directories
- Set up the database (create, migrate, seed)
- Install dependencies
- Copy environment file templates
- Check for required system dependencies

**Examples by framework**:

| Framework | Setup Script | What It Should Handle |
|-----------|--------------|----------------------|
| Rails | `bin/setup` | Bundle install, database setup, asset compilation |
| Node.js | `npm run setup` | npm install, env file creation, database setup |
| Laravel | `composer setup` | Composer install, key generation, database setup |
| .NET | `dotnet restore` + setup script | NuGet restore, database migrations |
| WordPress | `wp-env start` or DDEV | Docker setup, database import |

### 3. Tests Run Without Special Tools

Tests are part of the application. They should run with the standard testing framework, not require proprietary test runners or expensive CI/CD platforms for local execution.

```bash
# These should just work
bin/rails test           # Rails
npm test                 # Node.js
php artisan test         # Laravel
dotnet test              # .NET
```

### 4. Package Manager Dependencies

Dependencies should come from the language's standard package manager. No zip files in a `lib/` folder. No manual downloads. No installers.

| Language | Package Manager | Lock File |
|----------|----------------|-----------|
| Ruby | Bundler | `Gemfile.lock` |
| Node.js | npm/yarn/pnpm | `package-lock.json` / `yarn.lock` |
| PHP | Composer | `composer.lock` |
| .NET | NuGet | `packages.lock.json` |
| Python | pip/poetry | `requirements.txt` / `poetry.lock` |

### 5. Script the Setup Process

If your app needs X to happen before running, script it. If it isn't scripted, it's magic—bad magic.

**Every project should have**:

- A setup script for first-time setup
- A dev script for starting the application
- Clear documentation of any manual steps (which should be minimal)

**Rails pattern** (the gold standard):

```bash
bin/setup   # First-time setup: bundle, database, seed
bin/dev     # Start development: Rails server + CSS watcher + etc.
```

**Node.js pattern**:

```bash
npm run setup   # First-time setup
npm run dev     # Start development
```

**Laravel pattern**:

```bash
composer install && php artisan migrate:fresh --seed
php artisan serve
```

### 6. Seed Data Available

The application requires data to be useful. Make sure sample data is easily loadable and the process is scripted.

**Good patterns**:

```bash
# Rails
bin/rails db:seed

# Laravel
php artisan db:seed

# Node.js with Prisma
npx prisma db seed
```

**What seed data should include**:

- Representative sample data for all major features
- Test user accounts with known credentials
- Edge cases that are hard to create manually

**Never acceptable**:

- Fighting with the DBA for a database dump
- Manual data entry to test features
- Production data exports (security risk)

---

## The Keller Solutions Adaptation

### For Development Environments

Every Keller Solutions project should support this workflow:

```bash
git clone [repo]
cd [repo]
bin/setup         # or: npm run setup, composer install, etc.
bin/dev           # or: npm run dev, php artisan serve, etc.
# Application is now running and usable
```

### For CI/CD

The same principle applies to continuous integration. If it works locally with the setup script, it should work in CI without additional magic.

### For New Team Members

A new developer should be able to:

1. Clone the repository
2. Run the setup script
3. Start working

If onboarding takes more than 30 minutes of setup, something is wrong.

---

## Diagnosing F5 Violations

When the F5 principle is violated, you'll see symptoms like:

| Symptom | Likely Cause |
|---------|--------------|
| "It works on my machine" | Undocumented dependencies or environment variables |
| "Ask [person] for the database" | No automated seed data |
| "You need to install X manually" | Missing from setup script |
| "Run these 5 commands first" | Setup script doesn't exist or is incomplete |
| "Check the wiki for setup steps" | Setup should be scripted, not documented |

---

## Enforcement

### In Code Review

Before approving a PR that adds dependencies or setup steps:

- [ ] Does `bin/setup` still work from a clean slate?
- [ ] Are new dependencies in the package manager?
- [ ] Is seed data updated if needed?
- [ ] Can a new developer still clone and run?

### In CI/CD

Consider adding a "fresh clone" test that:

1. Clones the repo to a clean directory
2. Runs setup script
3. Runs test suite
4. Starts the application
5. Hits a health check endpoint

If any step fails, the build fails.

---

## Quick Reference

| Principle | Question to Ask |
|-----------|-----------------|
| No special tools | Can someone with just the runtime get this running? |
| Application awareness | Does setup handle everything automatically? |
| Tests run simply | Can I run tests with standard commands? |
| Package manager | Are all dependencies in the lock file? |
| Scripted setup | Is there a `bin/setup` or equivalent? |
| Seed data | Can I get useful data with one command? |

---

## The Bottom Line

**If it isn't scripted, it's magic—bad magic.**

Every step between "clone" and "running application" should be automated. Manual steps are bugs in your setup process. Fix them by scripting them.

Your future self, your teammates, and every developer who joins the project will thank you.

---

## Further Reading

- [The F5 Manifesto For .NET Developers](https://web.archive.org/web/20190826201538/http://www.khalidabuhakmeh.com/the-f5-manifesto-for-net-developers) - Khalid Abuhakmeh (via Wayback Machine)
- [Rails bin/setup Convention](https://guides.rubyonrails.org/getting_started.html) - Rails Guides
- [The Twelve-Factor App: Dev/Prod Parity](https://12factor.net/dev-prod-parity) - Heroku
