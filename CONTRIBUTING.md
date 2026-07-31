# Contributing

Thank you for contributing to this module.

## Development workflow

1. Create a feature branch from main.
2. Make focused changes.
3. Run checks locally.
4. Open a pull request with a clear summary.

## Local checks

Run the following before submitting a pull request:

```bash
terraform fmt -recursive
terraform init
terraform validate
```

If examples are updated, validate example plans in:

- examples/virtual_network_gateway
- examples/virtual_wan

## Documentation updates

When changing inputs, behaviour, or module dependencies, update:

- README module usage and behaviour notes
- examples if interface or expected structure changes

## Pull request expectations

- Keep changes small and purposeful.
- Include rationale for behaviour changes.
- Ensure naming and key conventions remain consistent.

## Security

Do not commit secrets, connection PSKs, or tenant-specific credentials.
