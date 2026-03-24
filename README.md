# Skyline Accounting — AML/CTF Client Onboarding Form

A prototype adaptive client onboarding form built for Skyline Accounting's AML/CTF compliance program (AUSTRAC Tranche 2, effective 1 July 2026).

## What this is

An interactive HTML form that adapts based on the client's entity type:

- **Individual** — personal details, occupation, source of funds
- **Sole Trader** — personal details + ABN and business info
- **Company** — company details, directors, beneficial owners (25%+)
- **Trust** — trust details, individual or corporate trustee, beneficiaries
- **Partnership** — partnership details, repeatable partner blocks
- **Association** — association details, governing committee members

All entity types then complete: services requested, source of funds & wealth, PEP declaration, additional entities, and a formal declaration.

## Live demo

View the form: [GitHub Pages link](https://beancounting.github.io/skyline-onboarding/)

## How it works

- Single HTML file — no dependencies except Tailwind CSS (CDN) and Google Fonts
- Conditional logic via vanilla JavaScript — sections show/hide based on entity type selection
- Repeatable person blocks (directors, partners, trustees, etc.)
- Progress bar, PEP toggle, additional entities flag, success screen
- Mobile responsive

## Context

Built as part of Skyline Accounting's AML/CTF program build for AUSTRAC Tranche 2 compliance.
This prototype is intended to be implemented in Typeform, JotForm, or Seamlss.
The Initial CDD assessment (risk rating, sanctions check, PEP check, adverse media) is always completed internally by staff after the client submits this form.

## Contact

dhimesh@skylineaccounting.com.au
