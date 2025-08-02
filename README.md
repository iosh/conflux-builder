# Conflux Builder

This repository provides a trusted build system for the [conflux-rust](https://github.com/Conflux-Chain/conflux-rust) project.

It uses GitHub Actions, triggered by an external API call, to compile binaries for various platforms and architectures.

## Security

Each build artifact is accompanied by a provenance file. This attestation provides a verifiable guarantee that the artifact was built from the specified source within this trusted GitHub Actions workflow.

## License

This project is licensed under the GPLv3 License. See the [LICENSE](LICENSE) file for details.
