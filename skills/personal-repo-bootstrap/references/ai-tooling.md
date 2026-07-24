# AI/LLM tooling - add only as needed

These are not part of the default bootstrap. Every one of them is a real cost - a new dependency, an account, a config surface, something to keep updated - so don't scaffold any of them until the project has an actual, concrete need. Adding them speculatively contradicts the frugal-by-default principle in `SKILL.md`.

## Evals - DeepEval or promptfoo

Add once the project has an LLM prompt or pipeline whose output quality you need to guard against regressions - i.e. once you're tempted to eyeball outputs before every release. Pick one:

- **[DeepEval](https://github.com/confident-ai/deepeval)** - Python-native, pytest-style assertions, best fit if the rest of the stack is Python. Install with `uv add --dev deepeval`, not bare `pip install`.
- **[promptfoo](https://github.com/promptfoo/promptfoo)** - config-driven (YAML), language-agnostic, better fit for TypeScript/Node stacks or when comparing prompts/models side by side.

Wire it into the CI workflow (`references/workflows.md`) as its own job once added, not into the pre-commit hook - evals typically call a real model and are too slow/costly for every commit.

## Memory - supermemory

Add only once the project needs persistent, cross-session memory for an agent or assistant feature - not for a stateless request/response LLM call. [Supermemory](https://supermemory.ai) fits the frugal-hosted-service principle (generous free tier, managed).

## Observability - Langfuse

Add once there's a production LLM call whose latency, cost, or output you need to actually observe - not during initial development. [Langfuse](https://langfuse.com) has a generous free tier and can self-host later if usage outgrows it.

## MCP tools

Add an MCP server only when the agent needs to reach a specific external system (a database, an API, a SaaS product) that isn't already reachable through existing tools. Don't add MCP servers preemptively "in case an agent needs them later."
