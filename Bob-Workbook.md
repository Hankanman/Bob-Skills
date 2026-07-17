# The Bobathon Workbook
### Trustmarque & Ultima Developer Day — Building with IBM Bob

**Who this is for:** Internal Trustmarque/Ultima developers new to Bob, working hands-on for the day.
**Goal:** By the end, you'll have shipped something real with Bob, tried every headline capability at least once, and be able to explain — in your own words — where Bob genuinely earns its place next to Copilot, Claude Code, and Cursor.

---

## 1. Objectives for the day

- [ ] Get Bob installed, authenticated, and connected to a real project
- [ ] Build something working — not a toy "hello world," an actual small service or tool
- [ ] Touch every capability module below at least once
- [ ] Leave with one custom Mode or Skill you'll actually reuse next week
- [ ] Be able to give a 2-minute "why Bob" pitch without reading off a slide

---

## 2. Before you start — setup checklist

- [ ] Bob IDE installed and signed in
- [ ] A repo to work in — either bring one, or clone the day's starter repo (ask your table lead)
- [ ] Bob Shell installed (`bob --version` to confirm) for the CLI module
- [ ] MCP Servers enabled: **⋯ menu → MCP Servers → Enable MCP Servers**
- [ ] Confirm your Bobcoin allocation shows up in Bobalytics — flag your table lead if it doesn't

---

## 3. How today runs

| Time | Block |
|---|---|
| Welcome, objectives, pick your project |
| Module 1 — Literate Coding |
| Module 2 — Custom Modes |
| Module 3 — Agentic Orchestration |
| Module 4 — MCP Integration |
| Module 5 — Bob Shell / DevOps Automation |
| Module 6 — Skills |
| Module 7 — Shift-Left Security |
| Module 8 — Bobalytics: cost & token visibility |
| Show & tell |
| Wrap, feedback, pints |

Modules are sequential but self-contained — if your table gets stuck or races ahead, skip forward or loop back. The only hard requirement is: **touch every module once.**

---

## 4. Pick your build

Choose one, or bring your own idea (clear it with your table lead so it's scoped to a day):

1. **Internal tool tracker** — a small API + UI that logs requests for internal tooling access (fits naturally with an M365/Azure-hosted stack)
2. **PR triage bot** — something that pulls open PRs, summarises risk, and flags ones needing security review
3. **Legacy modernisation mini-demo** — take a small COBOL/Java 8 sample and have Bob explain it, then refactor a slice of it to Java 21 (good one if you work Z/i modernisation deals)
4. **Bring your own** — any small greenfield service, provided it's real enough to touch every module

Write your pick here: `_________________________`

---

## 5. Capability modules

Each module has: what to do, a prompt or two to get moving, and a **why this matters** note tying it back to how Bob stacks up against the tools your clients are already using or evaluating.

### Module 1 — Literate Coding

**Do:** Describe a feature of your build in plain language and have Bob turn it into production-ready code in context — not a snippet, a real change to your repo.

**Try:**
> "Add an endpoint that [does X for your project]. Follow the existing patterns in this repo for error handling and tests."

**Checkpoint:** the change compiles, has tests, and you didn't hand-write any of it.

**Why this matters:** this is table stakes — every competitor does inline suggestion. The differentiator shows up in the next few modules, where Bob goes from suggesting code to owning outcomes across the SDLC.

---

### Module 2 — Custom Modes

**Do:** Create a custom mode scoped to a role relevant to your build (e.g. a "Docs Writer" mode restricted to `.md` files, or a "Test Engineer" mode that only touches test directories).

**Try:**
- Global: `~/.bob/settings/custom_modes.yaml`
- Project: `.bob/custom_modes.yaml`

```yaml
customModes:
  - slug: test-engineer
    name: 🧪 Test Engineer
    description: Writes and maintains tests only.
    roleDefinition: You are a test engineer focused on coverage and edge cases.
    whenToUse: Use when writing or reviewing tests.
    customInstructions: Prefer table-driven tests. Flag untested branches.
    groups:
      - read
      - - edit
        - fileRegex: ".*\\.(test|spec)\\.[jt]s$"
          description: Test files only
```

**Checkpoint:** switch into your mode and ask it to do something outside its file scope — confirm it refuses or redirects.

**Why this matters:** GitHub Copilot has no equivalent role/scope concept — it's one undifferentiated assistant. This is guardrails and governance by design, not by prompt discipline.

---

### Module 3 — Agentic Orchestration

**Do:** Give Bob a multi-step, outcome-level task rather than a single code change — something that spans planning, implementation, and validation.

**Try:**
> "Plan and implement [a small end-to-end feature for your build], including tests and a short summary of what changed and why."

**Checkpoint:** Bob produces a plan before touching code, then executes it, then reports back — not just a diff.

**Why this matters:** this is the "code generator → orchestrator" shift. Claude Code and Cursor are strong at execution but leave coordination and validation to you. Bob is designed to own the loop.

---

### Module 4 — MCP Integration

**Do:** Connect Bob to one live external tool relevant to your build (GitHub, an internal API, Azure, whatever your table has creds for) and use it in a real prompt.

**Try:**
> "Using [connected tool], pull [real data] and use it to [inform a decision in your build]."

**Checkpoint:** Bob actually calls the tool and the response shapes what it does next — not just a description of what it *would* do.

**Why this matters:** this is what turns Bob from "assistant with context" into "agent with reach" — it's the same protocol GitHub Copilot, Cursor, and Claude Desktop all support, so it's worth being fluent in explaining *why* Bob's governed, policy-aware use of MCP is different from a raw connection.

---

### Module 5 — Bob Shell / DevOps Automation

**Do:** Step out of the IDE and run a Bob Shell task from the terminal — something CI/CD- or pipeline-shaped.

**Try:**
```bash
bob "run the test suite, and if anything fails, propose a fix"
```

**Checkpoint:** you get a result without opening the IDE at all.

**Why this matters:** none of the mainstream competitors have a first-class CLI/Shell layer built for pipeline automation — this is Bob working where DevOps actually lives, not just where developers type.

---

### Module 6 — Skills

**Do:** Package something you did earlier today as a reusable Skill, so the next person doesn't have to re-derive it.

**Try:** create `.bob/skills/<skill-name>/SKILL.md` (project) or `~/.bob/skills/<skill-name>/SKILL.md` (global):

```markdown
---
name: your-skill-name
description: What it does and when Bob should activate it — be specific about trigger phrases.
---
Step-by-step instructions for the workflow, written as if briefing a colleague.
```

**Checkpoint:** ask Bob a question that should trigger your skill, unprompted, and confirm it activates on the description alone.

**Why this matters:** this is how you turn today's one-off wins into standing organisational capability — write once, every dev on every project gets it.

---

### Module 7 — Shift-Left Security

**Do:** Ask Bob to review your build's most recent change for security issues before it ever reaches a PR.

**Try:**
> "Review the last change for secrets, injection risks, and missing input validation. Fix what you find."

**Checkpoint:** Bob catches at least one real or planted issue and explains *why* it's a problem, not just what it changed.

**Why this matters:** Cursor and Claude Code have no native secrets scanning or PR-level policy enforcement — you'd bolt on SonarQube/Snyk separately. Bob's guardrails are embedded at authoring time, not after the fact.

---

### Module 8 — Bobalytics: cost & token visibility

**Do:** After a full morning of building, open Bobalytics and look at your actual token/Bobcoin spend for the day.

**Discuss at your table:**
- Which module burned the most tokens, and why?
- Did the model routing feel appropriate for the task, or did it feel like overkill for something simple?

**Why this matters:** this is the one competitors genuinely can't match easily — Copilot's premium-request multipliers and Claude Code's input/output-ratio-driven pricing are both harder to predict and harder to explain to a client's CFO than Bob's flat per-token model with centralised visibility.

---

## 6. Stretch goals (if you're ahead of schedule)

- [ ] Get your build's test suite running end-to-end via Bob Shell in one command
- [ ] Chain two Skills together in a single request
- [ ] Try the same task in Ask mode vs Agent mode and compare
- [ ] If you touched the legacy modernisation build: get Bob to explain *why* it made a specific refactor choice, in terms a non-technical reviewer could follow (this is "Literate Code" — try to notice it happening)

---

## 7. Show & tell (15:15)

Each table gets **3 minutes**. Cover:
1. What you built
2. The one moment Bob genuinely surprised you
3. The one thing that felt clunky or you'd push back on

Be honest about the clunky bits — that feedback goes straight back to the product team, and "it's all brilliant" isn't a useful Bobathon outcome.

---

## 8. Quick-reference: why Bob, vs what's in front of you

Use this if a client conversation echoes something a dev raises today.

| If they're evaluating... | What they value in it | Where Bob's edge is |
|---|---|---|
| **GitHub Copilot** | Tight GitHub/IDE integration, easy rollout, admin controls | System-level reasoning across complex/legacy codebases, transparent cost model vs Copilot's premium-request multipliers, modernisation depth (Java/RPG/COBOL) |
| **Claude Code** | Large context, strong iterative debugging, CI/CD awareness | Model flexibility (not locked to one provider), predictable cost via Bobalytics, on-prem/hybrid deployment options, built-in secrets/security scanning |
| **Cursor** | Deep codebase context, fast single-prompt multi-file edits | No IP indemnification gap, native security scanning, simpler and more transparent pricing, flexible deployment (not cloud-only) |
| **OpenAI Codex** | Async parallel task delegation, good for well-scoped repetitive work | Better suited to ambiguous/architecture-heavy work, built-in audit trail ("Literate Code"), less setup overhead per repo |

The common thread across all four: Bob's differentiation isn't "better autocomplete," it's **governance, cost predictability, and modernisation depth** — none of which show up in a five-minute demo unless you go looking for them. That's what today was for.

---

## 9. Feedback

Before you leave, jot down:

- One thing that should be a Skill in the shared team library: `_____________________`
- One thing that felt harder than it should: `_____________________`
- One client/deal where today's build pattern would actually help: `_____________________`

Hand this to your table lead or drop it in the Bobathon channel.