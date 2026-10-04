```markdown
# Capability Map: {TICKET-KEY} — <initiative name>

**Issue:** [{TICKET-KEY}](<url from url_template>)

| Module id | Responsibility | Tracker subtask | Depends on |
|-----------|----------------|-----------------|------------|
| scaffolding | Module scaffold | PROJ-XXX | — |
| core | Core logic | PROJ-YYY | scaffolding |

**Build order:** scaffolding → core → ...

Each module gets its own `SPEC-<module-id>.md` and (usually) its own PR.
```
