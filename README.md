# catch-me-if-you-can

A Claude Code plugin that crash-courses you on any profession, so you can (a) direct Claude better within that domain and (b) know what a real practitioner would actually do on Monday morning. Inspired by the Spielberg film — con artist's crash course, not a textbook.

Run `/catch-me`, name the role, and get back 6 role artifacts generated and saved in **your current project**:

- `persona.md` — the voice, defaults, opinions a real one holds
- `lexicon.md` — 40–60 shibboleths with realistic usage and common misuses
- `signaling.md` — 3 opinions a real one always has, tool preferences, what they laugh at
- `anti-patterns.md` — instant tells, prompts that out you, phrases to swap
- `monday.md` — 5-day concrete action plan (commands, files, people, decisions)
- `project-playbook.md` — decision rules tied to *your specific project*

A passive `active-role` skill then quietly folds that domain perspective into the main chat whenever your questions are role-relevant.

## Why it's a plugin but still project-local

The plugin is installed globally (once), but every role it generates is saved inside the project you run it in, at `.claude/catch-me/`. Different projects get independent personas — `game-dev` in Project A and `data-eng` in Project B never bleed into each other.

## Install

Add the marketplace in Claude Code:

```
/plugin marketplace add junjunjunbong/catch-me-if-you-can
```

Install the plugin:

```
/plugin install catch-me-if-you-can@junjunjunbong
```

Reload plugins:

```
/reload-plugins
```

## Use

Open any project in Claude Code and run:

```
/catch-me
```

Optionally pass a role hint:

```
/catch-me game developer — indie Unity 2D
```

The onboarder asks up to three short questions (role + flavor, depth, current project context), generates the 6 artifacts + `meta.json`, and saves them to `.claude/catch-me/roles/<slug>/` **inside the project you're in**. It also writes `.claude/catch-me/active-role.json` pointing at the new role.

After that, any domain-relevant question you ask should come back shaped by the role's persona and playbook — without any explicit "activate persona" step on your part.

Depth levels:
- **dinner-party** — hold a 10-min conversation
- **week-one** — survive first week on the job (default)
- **month-one** — lead a small decision within a month

## Status

v0.1.0 — Phase 1 implemented. Project-local state, plugin packaging.

Implemented:
- `/catch-me` — onboarding + artifact generation + activation
- `active-role` — hidden auto-invoked persona loader

Planned:
- Phase 2: `/catch-switch`, `/catch-list`, `/catch-forget`
- Phase 3: `/catch-deepen`, `/catch-quiz`, role export
- v1.1: optional `UserPromptSubmit` hook if auto-invocation proves unreliable

## Plugin layout

```
catch-me-if-you-can/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── skills/
│   ├── catch-me/
│   │   ├── SKILL.md                            # /catch-me entry (forks → role-onboarder)
│   │   ├── templates/
│   │   │   └── role-generation-prompt.md       # Quality lever
│   │   └── scripts/
│   │       └── write_role_files.sh             # Atomic artifact writer
│   └── active-role/
│       └── SKILL.md                            # Hidden auto persona loader
├── agents/
│   └── role-onboarder.md                       # Onboarding + generation subagent
├── README.md
└── LICENSE
```

Bundled files are referenced at runtime via `${CLAUDE_PLUGIN_ROOT}`. State writes go to `$(pwd)/.claude/catch-me/` (the user's project).

## Design principles

- **Con artist, not textbook.** Every sentence teaches a shibboleth, installs an opinion, prevents a tell, or triggers an action. Wikipedia-style overviews get cut.
- **Specificity is the whole product.** If a sentence would be true for any technical role, it's dead weight.
- **Passive persona.** `active-role` attaches the lens on relevant turns. No role-play preamble, no CLAUDE.md auto-injection, no SessionStart hooks in v1.
- **One-level delegation.** `/catch-me` → `role-onboarder` subagent → done. No nested skills or subagent chains.
- **Project-local state.** Nothing is written outside the user's project `.claude/` folder, even though the plugin itself is installed globally.

## License

MIT — see [LICENSE](LICENSE).
