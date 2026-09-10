@../hemingway.md

## Maintainers

- `hemingway.md` is the only place the rule text is edited. After changing it, run `scripts/build.sh`. It rewrites `output-styles/`, `rules/`, `skills/hemingway/`, and the rule block in `README.md`.
- `scripts/build.sh --check` fails when a derived file drifts. Run it before committing.
- `claude plugin validate .` before a release.
