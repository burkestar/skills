# Default web app deployment stack

Only relevant when the repo is a web app that will actually be deployed (not a library, CLI, or internal tool). Use this as the default; deviate only when the project has a specific reason to.

| Concern | Default choice | Cheaper alternative |
| --- | --- | --- |
| DNS / CDN | Cloudflare (has CDN built in) | GoDaddy (DNS only) |
| App hosting | Vercel | Railway, Fly.io |
| Storage backend | Supabase | |
| Auth / social login | Supabase | |
| Payments (subscriptions, tax handling) | Stripe or Lemon Squeezy | |
| Analytics | PostHog | |
| Feature flags | PostHog | |
| Email | Resend | Postmark |
| Error monitoring | Sentry | |

## Minimal viable stack

Vercel + Supabase (covers storage and auth) + a merchant of record (Lemon Squeezy or Polar) + Resend + Sentry + Cloudflare.

## Business setup (one-time, outside the codebase)

- Register an LLC (Massachusetts: ~$500/yr with required annual report).
- Register an EIN.
- Open a business bank account (Mercury).

## Where this goes

Append the relevant rows to the tech stack table in `docs/ARCHITECTURE.md` and note the deploy targets in `docs/DEVELOPMENT.md`'s Deploy section.
