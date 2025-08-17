# Conflux Builder

This repository provides a trusted build system for the [conflux-rust](https://github.com/Conflux-Chain/conflux-rust) project.  It leverages GitHub Actions to automatically compile ready-to-use binaries for multiple platforms and architectures.

## Downloading Binaries

Binaries compiled by this workflow are published on this repository's [Releases Page](https://github.com/iosh/conflux-builder/releases). Each release includes a variety of assets for different operating systems and CPU architectures.



## CPU Compatibility

The x64 binaries provided here target the Haswell CPU architecture. For broader compatibility, a portable version (with a -portable suffix) is also available.

If you encounter an "Illegal Instruction" error when running conflux, please try using the portable version instead.

If you still get an error, please open an issue.



## Troubleshooting

### Windows

Issue: Missing DLL files like VCRUNTIME140.dll or MSVCP140.dll
When trying to run the program on Windows, you may encounter one of the following errors:

- The program can't start because MSVCP140.dll is missing from your computer.
- The code execution cannot proceed because VCRUNTIME140.dll was not found.
- The code execution cannot proceed because VCRUNTIME140_1.dll was not found.

You need to install the latest [Microsoft Visual C++ Redistributable Version](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170#latest-microsoft-visual-c-redistributable-version)

## Security

Every build artifact is accompanied by a `-attestation.json
` file. This attestation provides a verifiable guarantee that the artifact was built from the specified source code entirely within this trusted GitHub Actions workflow, ensuring transparency and security.

## License

This project is licensed under the GPLv3 License. See the [LICENSE](LICENSE) file for details.
