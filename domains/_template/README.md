# Creating a Domain Pack

A domain pack provides field-specific knowledge that Scholar Flow uses to customize skills for your research area.

## Files

| File | Purpose | Required |
|------|---------|----------|
| `domain.yaml` | Field metadata and core topics | Yes |
| `theories.yaml` | Major theoretical frameworks (8-12) | Yes |
| `methods.yaml` | Common research methods (6-8) | Yes |
| `topics.yaml` | Subfields and application areas (8-10) | Yes |
| `social-issues.yaml` | Relevant societal dimensions (5-7) | Yes |
| `journals.md` | Tiered list of top venues | Yes |
| `keyword-mapping.md` | Search term synonyms and translations | Recommended |

## YAML Format

For `theories.yaml`, `methods.yaml`, `topics.yaml`, and `social-issues.yaml`:

```yaml
- name: "Theory/Method Name"
  description: "Brief description of what it is and when it applies"
```

## Contributing

1. Copy this `_template/` directory to `domains/{your-field}/`
2. Fill in all required files
3. Test with `/init` to verify the domain pack works
4. Submit a PR

Note: If your field isn't available as a pre-built pack, `/init` can generate one automatically using AI. Pre-built packs are higher quality since they're community-reviewed.
