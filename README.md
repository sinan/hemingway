# hemingway

A plugin and skill that makes your coding agent write like Hemingway.

It uses short sentences and plain words instead of long, hard to follow paragraphs. The answer comes first. The reply ends with one line that names what it left out, so you know there is more and can ask for it.

It works in Claude Code. The same rule text is packaged for Codex, Cursor, Antigravity, and Gemini CLI, but I only tested in Claude Code so far, should be fine on others as well. If not please report.

## What a reply looks like

> Fixed. The cache key in `session.py` used the user id but not the tenant, so two tenants could share a session. It now includes both. Tests pass, 41 of 41.
>
> Below the surface: why the old tests missed it, the two other places that build cache keys, the keys already sitting in Redis.

Say `below` to get those three parts. Name one of them to get only that one. Say `normal style` to turn the style off for the session.

## How it works

The style is a short list of rules in [hemingway.md](hemingway.md). Your agent reads them at the start of every session, so every reply follows them. The rules cover two things:

- The surface: what every reply looks like. Answer first, short sentences, plain words, no preamble, no recap of edits, under 100 words not counting code.
- Below the surface: the closing line that names what was left out, and what happens when you ask for it.

Two skills come with it. `hemingway` is the same rules packaged as a skill, for tools that install skills. `below` expands the items on the closing line.

It is not a token saver. Replies get shorter, but the goal is that you can read them. When an answer needs 300 words, you get 100 and a line that says where the rest is. It does not ban technical terms. Filler words go, real names stay.

## The rules

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

## Install

### Paste the rules

The rules go into the file your agent reads at the start of every session. That is the whole install.

| Tool                    | File                          |
| ----------------------- | ----------------------------- |
| Claude Code             | `~/.claude/CLAUDE.md`         |
| Codex                   | `~/.codex/AGENTS.md`          |
| Antigravity, Gemini CLI | `~/.gemini/GEMINI.md`         |
| Cursor                  | Settings > Rules > User Rules |

Or run the script. It appends the rules between two markers, so running it twice replaces the block instead of adding a second one.

```bash
git clone https://github.com/sinan/hemingway && cd hemingway && ./install.sh
```

`./install.sh --remove` takes the block out again. `./install.sh cursor` writes the rule into the current project's `.cursor/rules/`.

### Install the `below` skill

The closing line works without any skill. The `below` skill makes the expansion consistent across tools. This installs it into every agent you pick:

```bash
npx skills add sinan/hemingway -g
```

In Claude Code and Cursor you can also type `/below`. In Codex, `@below`.

### Plugins

A plugin gives you one install that stays on and updates itself.

Claude Code. The plugin includes an output style that turns on for every reply while the plugin is enabled. It keeps Claude Code's own coding instructions.

```text
/plugin marketplace add sinan/hemingway
/plugin install hemingway@hemingway
```

To try it without installing: `claude --plugin-dir ./hemingway`. To turn it off: `/plugin disable hemingway`.

Cursor. The plugin includes an always-on rule and the `below` skill. Until it is listed on the Cursor Marketplace, clone the repo and run `./install.sh cursor` inside your project, or paste the rules into User Rules.

Codex. `codex plugin marketplace add sinan/hemingway`, then install it from `/plugins`. This installs the skills. The always-on part is still the paste into `~/.codex/AGENTS.md`.

Gemini CLI. `gemini extensions install https://github.com/sinan/hemingway`. The extension's context file is the rules, so they load every session.

Antigravity. Paste the rules into `~/.gemini/GEMINI.md`, then `npx skills add sinan/hemingway -g -a antigravity`.

## Where the name comes from

Hemingway wrote that an iceberg moves with dignity because only one-eighth of it is above water. The reader feels the rest without seeing it. AI replies tend to put the whole iceberg above water. This keeps the surface short and says what is below it.

## Related work

[iceberg](https://github.com/hellohelen-ai/iceberg) by David Hanlon uses the same idea to make agents terse: a four-line cap, tables and arrows, and a `-a` flag for the long form. hemingway keeps prose and names what is missing. [SimpleEnglish](https://github.com/AminBlg/SimpleEnglish) enforces Simplified Technical English. [plain-writing-skill](https://github.com/shreyashankar/plain-writing-skill) is a plain-language editor for text you give it.

## Develop

`hemingway.md` is the only place the rule text is edited. `scripts/build.sh` rewrites the Claude output style, the Cursor rule, the `hemingway` skill, and the rule block above from it. `scripts/build.sh --check` fails if they drift. `claude plugin validate .` checks the Claude plugin.

## License

MIT
