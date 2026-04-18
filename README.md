# catch-me-if-you-can

A project-local Claude Code tool that crash-courses you on any profession, so you can (a) direct Claude better within that domain and (b) know what a real practitioner would actually do on Monday morning. Inspired by the Spielberg film — con artist's crash course, not a textbook.

Run `/catch-me`, name the role, and get back 6 role artifacts generated and saved under your project:

- `persona.md` — the voice, defaults, opinions a real one holds
- `lexicon.md` — 40–60 shibboleths with realistic usage and common misuses
- `signaling.md` — 3 opinions a real one always has, tool preferences, what they laugh at
- `anti-patterns.md` — instant tells, prompts that out you, phrases to swap
- `monday.md` — 5-day concrete action plan (commands, files, people, decisions)
- `project-playbook.md` — decision rules tied to *your specific project*

A passive `active-role` skill then quietly folds that domain perspective into the main chat whenever your questions are role-relevant.

## Status

v1 Phase 1 — project-local, skill-centric. Not a marketplace plugin yet.

Implemented:
- `/catch-me` — onboarding + artifact generation + activation
- `active-role` — hidden auto-invoked persona loader

Planned:
- Phase 2: `/catch-switch`, `/catch-list`, `/catch-forget`
- Phase 3: `/catch-deepen`, `/catch-quiz`, role export, plugin packaging
- v1.1: optional `UserPromptSubmit` hook if auto-invocation proves unreliable

## Install (project-local)

1. Clone this repo somewhere.
   ```bash
   git clone https://github.com/junjunjunbong/catch-me-if-you-can.git
   ```
2. Copy the `.claude/` folder into the target project you want to try it on:
   ```bash
   cp -R catch-me-if-you-can/.claude /path/to/your/project/
   ```
   (or symlink it if you want updates to flow through)
3. Open that project in Claude Code.

That's it. No install step, no package manager.

## Use

In your target project, run:

```
/catch-me
```

Optionally pass a role hint:

```
/catch-me game developer — indie Unity 2D
```

The onboarder asks up to three short questions (role + flavor, depth, current project context), generates the 6 artifacts + `meta.json`, and saves them to `.claude/catch-me/roles/<slug>/`. It also writes `.claude/catch-me/active-role.json` pointing at the new role.

After that, any domain-relevant question you ask should come back shaped by the role's persona and playbook — without any explicit "activate persona" step on your part.

Depth levels:
- **dinner-party** — hold a 10-min conversation
- **week-one** — survive first week on the job (default)
- **month-one** — lead a small decision within a month

## Layout

```
.claude/
├── skills/
│   ├── catch-me/                 # /catch-me entry (forks to role-onboarder)
│   │   ├── SKILL.md
│   │   ├── templates/
│   │   │   └── role-generation-prompt.md
│   │   └── scripts/
│   │       └── write_role_files.sh
│   └── active-role/              # hidden auto persona loader
│       └── SKILL.md
├── agents/
│   └── role-onboarder.md         # the onboarding + generation subagent
└── catch-me/                     # project-local state (gitignored by default)
    ├── active-role.json
    └── roles/
        └── <slug>/
            ├── meta.json
            ├── persona.md
            ├── lexicon.md
            ├── signaling.md
            ├── anti-patterns.md
            ├── monday.md
            └── project-playbook.md
```

`.claude/catch-me/` is gitignored — generated content is per-project and personal.

## Design principles

- **Con artist, not textbook.** Every sentence teaches a shibboleth, installs an opinion, prevents a tell, or triggers an action. Wikipedia-style overviews get cut.
- **Specificity is the whole product.** If a sentence would be true for any technical role, it's dead weight.
- **Passive persona.** `active-role` attaches the lens on relevant turns. No role-play preamble, no CLAUDE.md auto-injection, no hooks.
- **One-level delegation.** `/catch-me` → `role-onboarder` subagent → done. No nested skills or subagent chains.
- **Project-local state.** Nothing is written outside the project's `.claude/` folder.

## License

MIT — see [LICENSE](LICENSE).
