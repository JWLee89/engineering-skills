# EARS requirement syntax (optional)

Use when the user or ticket asks for **Easy Approach to Requirements Syntax (EARS)** instead of
narrative acceptance criteria. Not a handle-task gate — default specs still use
[templates.md](../templates.md).

## Patterns

| Keyword | Template | Example |
| ------- | -------- | ------- |
| Ubiquitous | The `<system>` shall `<response>` | The API shall return 404 when the resource id is unknown. |
| Event-driven | When `<trigger>`, the `<system>` shall `<response>` | When payment fails, the checkout shall show a retry action. |
| State-driven | While `<state>`, the `<system>` shall `<response>` | While maintenance mode is on, the app shall serve a static banner. |
| Unwanted | If `<condition>`, then the `<system>` shall `<response>` | If the token is expired, then the API shall reject the request with 401. |
| Optional | Where `<feature>`, the `<system>` shall `<response>` | Where dark mode is enabled, the UI shall persist the user preference. |

## Mapping to our spec

In `{local_specs}/.../SPEC-*.md`:

1. **Objective** — unchanged  
2. **Success criteria** — one numbered EARS line per criterion  
3. **Spec adherence** — each line maps to a test or explicit deferral ([spec-adherence.md](../spec-adherence.md))

## References

- [feature-forge](https://github.com/Jeffallan/claude-skills/tree/main/skills/feature-forge) (MIT)
