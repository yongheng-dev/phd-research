# Contributing to Scholar Flow

Thank you for your interest in contributing! Scholar Flow is built by researchers, for researchers.

## Ways to Contribute

### Domain Packs

The most impactful contribution is a domain pack for your research field. See [docs/creating-domains.md](docs/creating-domains.md) for the template and instructions.

1. Copy `domains/_template/` to `domains/{your-field}/`
2. Fill in all required files (theories, methods, topics, journals, etc.)
3. Test with `/init` to verify the pack works
4. Submit a PR

### Skills

New research workflow skills are welcome. Place them in `templates/skills/{skill-name}/SKILL.md.tmpl`.

Requirements:
- Use `{{PLACEHOLDER}}` syntax for user-specific values
- Include `generated: true` in frontmatter
- Follow the existing skill structure (trigger description, step-by-step workflow, save instructions)
- Be domain-agnostic (reference domain pack files, not hardcoded content)

### Bug Reports and Features

Open an issue on GitHub with:
- What you expected vs. what happened
- Your research field and setup
- Steps to reproduce

### Translations

To improve support for your language:
- Check that `keyword-mapping.md` in your domain pack includes bilingual terms
- Report translation issues in the generated CLAUDE.md or skill outputs

## Development Setup

1. Clone the repo
2. Run `/init` to set up your own environment
3. Make changes to templates (not generated files)
4. Test by re-running `/init`

## Code Style

- All distributed files (templates, domain packs, docs) must be in English
- Use `{{PLACEHOLDER}}` for user-specific values in templates
- Keep skills domain-agnostic — reference `references/` files, not hardcoded content
- YAML files use `name` and `description` fields for list items

## Pull Request Process

1. Fork the repo and create a branch
2. Make your changes
3. Test with `/init` on a clean setup
4. Submit a PR with a clear description of what and why
