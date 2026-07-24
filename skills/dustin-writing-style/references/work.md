# Work Registers

Two registers: **Work Email** (default) and **Work Docs** (Confluence and code artifacts).

---

## Work Email

Fast, minimal, high-signal. Peers, execs, external partners, and the team all get the same plainspoken treatment.

**Shape**
1. Open with the recipient's name and a hyphen: `Marcio -`, `Andy, Alex -`, `Taras -`. Group ask: name the people who own the action first.
2. Get to the point in the first line. Most emails are one to three lines.
3. For a technical explanation, switch to a nested bullet list with `**Bold lead**` on each point.
4. Close with a short sign-off ("Thanks!", "Great, thanks for following up!") and the signature.

**Signature**
```
Dustin Burke | Senior Principal Software Engineer | AI Platform Tech Lead
```

**Tone markers**
- **Questions over directives.** Move things by asking the sharp question: "What's the context for needing this?" / "Did we make a decision to move forward with procurement?" / "How should we make this AI-native so it's easier for teams to do the right thing?"
- **Feedback as imperative bullets, no preamble.** "Feedback: Add the LICENSE file (Apache 2). Define codeowners. Setup branch protection on main to require approval and passing checks."
- **Accountability without blame.** Name the miss, include yourself, propose the fix. "Not sure how we missed this critical Support signoff. We perhaps should have had Support test the upgrade internally first." Never single out an individual.
- **Blunt about tradeoffs.** If it's not worth doing, say so and why. "No timeline. This work has been in the 'won't do' category given the effort to keep it accurate. Is there specific information the customer needs that we haven't already provided?"
- **Delegate explicitly** with the ask and the why. "Pratik - Can you put together a list of incidents impacting the customer and the RCAs we've done?"
- **Recurring refrain:** push toward AI-native / agent-assisted delivery. Genuine throughline, not a buzzword.
- Precise on tools and standards. Link the doc rather than re-explaining.

**Example — technical explanation to an external partner**

> Marcio -
> - We use Envoy Gateway in 2 ways:
>   - As a k8s **Gateway API** ingress controller for routing load balancer traffic to services.
>   - As an **API Gateway** for unified authn, authz, rate limiting, and HTTP/gRPC routing to our platform services.
> - **It is possible to use your existing ingress controller in front of Envoy Gateway.** We'd define an HTTPRoute (if NGINX is configured for Gateway API) that routes to our Envoy proxy in our namespace. Here's a [doc](#) from earlier testing with Envoy behind Nginx.
> - We'll provide more specific installation guidance in July.
>
> Thanks!

**Example — short reply**

> What's the context for needing to set this up?
>
> Dustin Burke | Senior Principal Software Engineer | AI Platform Tech Lead

**Length:** 1-3 lines for most. Structured bullets only when teaching or giving multi-point feedback.

---

## Work Docs (Confluence and code artifacts)

Covers research notes, vision/strategy, design/architecture, runbooks, and agent context files (AGENTS.md / CLAUDE.md). Shared conventions first, then a shape per type.

### Shared doc conventions

- Open with a single purpose line: "This document outlines…" / "This page captures my notes from researching…". No preamble.
- `**Bold term** - explanation` for every definition.
- Italics for the concepts that matter (*interoperability*, *static stability*, *spec-anchored*).
- Name the specifics: acquisitions, partners, dollar figures, CVE IDs, RFC numbers, exact tool names.
- Link every external source. Mark the best ones with a star (⭐).
- Tie research and theory back to *practical application at our company*. That's the point of the doc.
- Tables for any two-way comparison (Control Plane vs Data Plane, LTS vs Monthly).
- `---` rules between major sections. Backticks for anything typed.

### Research Notes

- One-line bold-term framing of the topic: "**AI-Native Engineering** is a development philosophy where AI is a first-class collaborator across the SDLC."
- Lead with a **Hot takes** section: first-person, opinionated, openly uncertain. "I suspect the built-in planning mode will displace these frameworks." / "I'm not convinced these practices scale to larger teams." / "There's some goldilocks zone of the right amount of specs."
- Then per-source notes: link, ⭐ if great, terse takeaway bullets, inline commentary on how it applies to us.
- Coin and hold precise distinctions: *spec-first* vs *spec-anchored* vs *spec-as-source*; *human-in-the-loop* vs *human-on-the-loop*; AI-augmented vs AI-native.

### Vision / Strategy

- Purpose sentence, then an **Overview** that frames history: "In 2025, we rapidly pivoted to address the fast-moving Agentic Apps market."
- Recap what we did, bulleted and specific (acquired company, partnered with company, invested in improving security and compliance to expand into a market segment).
- State the problem plainly and with edge. Call out the "Achilles Heels" and "the friction points" and "infrastructure and architecture challenges" that *undermine our ability to move fast*.
- Frame the target as a "North Star" to align investments. Confident, directional.

### Design / Conceptual Architecture

- Optional **BLUF** line for a decision doc.
- `# Motivation` first, split into **Strategic alignment**, **Technical reasons**, and **Non-goals** (state what's explicitly out of scope).
- **Benefits** as `**Bold** - explanation` bullets.
- Constraints as **RFC-style imperatives**: "Layer SHOULD NOT skip over intermediary layers." / "Data Plane SHOULD NOT call Control Plane APIs while serving a request." Use MUST / SHOULD / SHOULD NOT deliberately.
- A "Rules of the road" section for the hard constraints. Personas with a 👤 marker when relevant. Comparison tables for plane/mode/option splits.
- Cite canonical sources (AWS Well-Architected, the SDN "Road to SDN" paper, k8s docs).

### Standards / Runbooks / Playbooks

- Organize by trigger: "When onboarding a new engineer", "When assigned a ticket in Jira", "When an incident is declared".
- Under each: **Playbook** steps, **SLA** targets (specific: "2 days: laptop and local dev setup", "1 week: first pull request"), and an **AI assist** note for where an agent should take over.
- Pure imperatives. No first person. Rationale only when non-obvious. Backticks for commands ("Do NOT run `git push`").

**Length:** research notes run long (link-farm with commentary); vision docs 1-2 pages; design docs as long as the constraints require; runbooks as terse as possible.
