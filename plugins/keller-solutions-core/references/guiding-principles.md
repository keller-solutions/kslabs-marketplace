# The Keller Solutions Guiding Principles

## The Measure of Quality

**Can someone unfamiliar with this code understand what it does and why, without asking the author?**

Code is read far more often than it is written. We optimize for the reader—the future maintainer who may be you, six months from now, without the benefit of current context.

---

## The Six Principles

These principles govern every pull request and every commit.

### 1. Don't Repeat Yourself (DRY)

Duplication is the root of maintenance nightmares. Functionality should be maintained in exactly one place.

**Key guideline**: Extract to a method/function the *second* time code is needed, not the first.

```ruby
# Bad: duplicated logic in each action
class ProjectsController < ApplicationController
  def show
    @project = Project.find(params[:id])
    redirect_to root_path unless @project.accessible_by?(current_user)
  end

  def edit
    @project = Project.find(params[:id])
    redirect_to root_path unless @project.accessible_by?(current_user)
  end
end

# Good: extracted once, reused everywhere
class ProjectsController < ApplicationController
  before_action :set_project
  before_action :authorize_project

  def show; end
  def edit; end
end
```

### 2. Separate Code From Content

View code should contain structure, not strings. Content changes shouldn't require code changes.

```erb
<!-- Bad: hardcoded content -->
<h1>Welcome to A11y Audit</h1>
<button>Get Started</button>

<!-- Good: externalized content -->
<h1><%= t('home.hero.title') %></h1>
<button><%= t('home.hero.cta') %></button>
```

### 3. Avoid Pre-Optimization

Build what you need now, not what you might need later. Wait for the pattern to emerge before abstracting it.

**Key guideline**: Never add placeholder UI for features that don't exist yet.

```erb
<!-- Bad: link to feature that doesn't exist yet -->
<nav>
  <%= link_to "Dashboard", dashboard_path %>
  <%= link_to "Articles", "#" %>  <!-- Coming in Q2 -->
</nav>

<!-- Good: only working links -->
<nav>
  <%= link_to "Dashboard", dashboard_path %>
</nav>
```

### 4. Keep the Code Tidy

Every commit should leave the codebase cleaner than it was found. Dead code is a liability.

**Never commit**:

- Commented-out code (explain removal in commit message)
- Debug traces (`console.log`, `puts`, `binding.pry`)
- Incomplete or inoperable features
- Orphaned assets

### 5. Maintain Consistency

The codebase should look like it was written by one person. Patterns, once established, should be followed everywhere.

**Key guideline**: When renaming something, rename all related items (classes, partials, routes, tests).

### 6. Make It Easily Understandable

Code should be self-documenting. Variable names are not the place to save keystrokes.

```ruby
# Bad: abbreviated, unclear
def proc_scn(s)
  r = s.res
  i = r.map { |x| x.iss }.flatten
end

# Good: intention-revealing names
def process_scan(scan)
  results = scan.results
  issues = results.flat_map(&:issues)
end
```

---

## Comments Explain Why, Not What

If you need a comment to explain *what* code does, the code isn't clear enough. Rewrite it with better names.

```ruby
# Bad: comment explains what
# Loop through each issue and increment the count
issues.each { |issue| count += 1 }

# Good: comment explains why
# Fingerprints exclude dynamic attributes because the same accessibility
# issue may have different IDs across pages
def normalize_html(html)
  html.gsub(/\s(id|class|data-[\w-]+)="[^"]*"/, "")
end
```

---

## Commits Tell the Story

Each commit is a focused, atomic change that is independently functional.

**Subject line**: Active voice, imperative mood ("Add", "Update", "Remove"), under 50 characters.

**Body**: Explains *why* the change was made, references the ticket.

```text
Add issue deduplication via fingerprinting

Issues are now deduplicated within a scan using a fingerprint
computed from rule ID, CSS selector, and normalized HTML. This
reduces noise in reports where the same problem appears on
multiple pages.

Refs #147
```

---

## Quick Reference

| Principle | Ask Yourself |
|-----------|--------------|
| **DRY** | Is this code repeated elsewhere? |
| **Separate Content** | Is there a literal string in my view code? |
| **Avoid Pre-Optimization** | Am I building for a hypothetical future? |
| **Keep Tidy** | Is there dead code, debug traces, or commented-out code? |
| **Maintain Consistency** | Does this follow the existing patterns? |
| **Make Understandable** | Will future-me understand this in 6 months? |

---

## The Bottom Line

Code quality isn't about cleverness—it's about kindness to future maintainers. Every line you write is a gift (or burden) to someone who will read it later.

Write code that explains itself. Keep it simple. Keep it consistent. Future you will thank present you.
