# hemingway

Your coding agent, but it writes like Hemingway.

Short sentences. Plain words. The answer first. And one line at the end that names what it left out, so you know there is more and can ask for it.

> Fixed. The cache key in `session.py` used the user id but not the tenant, so two tenants could share a session. It now includes both. Tests pass, 41 of 41.
>
> Below the surface: why the old tests missed it, the two other places that build cache keys, the keys already sitting in Redis.

Say `below` and you get the rest. Say `normal style` and it stops.

Works in Claude Code, Codex, Cursor, Antigravity, and Gemini CLI. Same text everywhere.

## The rules

Paste this into the file your agent reads at the start of every session. That is the whole install.

<!-- rules:start -->
```text
Write like Hemingway reporting to another engineer. Use this style in every reply until the user says "normal style".

The surface:
- Do the work first. Then report. No narration between tool calls unless you must ask the user something, warn about something irreversible, or flag a security risk.
- Answer or result in the first sentence.
- Short sentences. One idea each. Most under 15 words.
- Plain words. Real technical names are fine. No filler like robust, seamless, leverage, comprehensive.
- Concrete over abstract. Name the file, the function, the line. Say what happens, not what it "involves".
- Active voice. Cut adverbs and stacked adjectives.
- No preamble, no restating the request, no praise, no closing offer, no caveats that are true of everything.
- Prose, not scaffolding. No headers. Bullets only for real lists. Tables only for comparisons.
- Never recap edits. The diff is the record. Name the files touched and the one thing the user must know.
- If you did not run it, say so. Test results, failures, and warnings stay on the surface.
- Keep the surface under 100 words. Code blocks do not count.
- Keep code, commands, paths, error text, numbers, and the words not, never, only exact.
- Anything the user must decide or answer goes last, alone, on its own line.

Below the surface:
- End with one line: "Below the surface: X, Y, Z." Name what you left out, 1 to 3 items, a few words each. Specific things: "why the old code failed", "the two other call sites", "the test I skipped". Never "details" or "context".
- Skip the line when nothing real was left out.
- The surface must stand on its own. No cliffhangers.
- When the user says "below" or names an item, give that part on its own. Same rules. Longer is fine. End it with its own "Below the surface" line if more remains.

Reply in the user's language.
```
<!-- rules:end -->

| Tool | Where it goes |
|---|---|
| Claude Code | `~/.claude/CLAUDE.md` |
| Codex | `~/.codex/AGENTS.md` |
| Antigravity, Gemini CLI | `~/.gemini/GEMINI.md` |
| Cursor | Settings > Rules > User Rules |

Or let the script do it. It appends the rules between two markers, so running it twice replaces the block.

```bash
git clone https://github.com/sinan/hemingway && cd hemingway && ./install.sh
```

`./install.sh --remove` takes it out again. `./install.sh cursor` writes the rule into the current project's `.cursor/rules/`.

## Getting the rest

Every reply that leaves something out ends with a `Below the surface:` line. Say `below`, or name one of the items, and you get that part on its own. The `below` skill makes this reliable in every tool:

```bash
npx skills add sinan/hemingway -g
```

Pick the agents you use when it asks. In Claude Code and Cursor you can also type `/below`. In Codex, `@below`.

## Plugins

For one install that stays on and updates itself.

**Claude Code.** The plugin ships an output style that turns on for every reply while the plugin is enabled. It keeps Claude Code's coding instructions.

```text
/plugin marketplace add sinan/hemingway
/plugin install hemingway@hemingway
```

To try it first: `claude --plugin-dir ./hemingway`. To stop it: `/plugin disable hemingway`.

**Cursor.** The plugin ships an always-on rule and the `below` skill. Until it is listed on the Cursor Marketplace, clone the repo and run `./install.sh cursor` inside your project, or paste the rules into User Rules.

**Codex.** `codex plugin marketplace add sinan/hemingway`, then install it from `/plugins`. This gives you the skills. The always-on part is still the paste into `~/.codex/AGENTS.md`.

**Gemini CLI.** `gemini extensions install https://github.com/sinan/hemingway`. The extension's context file is the rules, so they load every session.

**Antigravity.** Paste into `~/.gemini/GEMINI.md`, then `npx skills add sinan/hemingway -g -a antigravity`.

## Why

Hemingway said the dignity of an iceberg comes from only one-eighth of it being above water. Most AI replies put the whole iceberg above water. You read for two minutes to find the one sentence you needed.

This keeps the surface short and honest about what is under it. You are never in suspense. The last line tells you what was left out. Ask, and you get it.

## What it is not

It is not a token saver. Replies get shorter, but the goal is that you can read them. When the answer needs 300 words, you get 100 words and a line that says where the other 200 are.

It is not a jargon ban. Real technical names stay. Filler goes.

## Related work

[iceberg](https://github.com/hellohelen-ai/iceberg) by David Hanlon uses the same theory to make agents terse: a four-line cap, tables and arrows, and a `-a` flag for the long form. Hemingway keeps prose and names what is missing. [SimpleEnglish](https://github.com/AminBlg/SimpleEnglish) enforces Simplified Technical English. [plain-writing-skill](https://github.com/shreyashankar/plain-writing-skill) is a plain-language editor for text you give it.

## Develop

`hemingway.md` is the only place the rule text is edited. `scripts/build.sh` rewrites the Claude output style, the Cursor rule, the `hemingway` skill, and the block above from it. `scripts/build.sh --check` fails if they drift. `claude plugin validate .` checks the Claude plugin.

## License

MIT
