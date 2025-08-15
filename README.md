# Conflux Builder

This repository provides a trusted build system for the [conflux-rust](https://github.com/Conflux-Chain/conflux-rust) project.

It uses GitHub Actions, triggered by an external API call, to compile binaries for various platforms and architectures.



## Troubleshooting
### Windows
Issue: Missing DLL files like VCRUNTIME140.dll or MSVCP140.dll
When trying to run the program on Windows, you may encounter one of the following errors:

- The program can't start because MSVCP140.dll is missing from your computer.
- The code execution cannot proceed because VCRUNTIME140.dll was not found.
- The code execution cannot proceed because VCRUNTIME140_1.dll was not found.


You need to install the latest [Microsoft Visual C++ Redistributable Version](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170#latest-microsoft-visual-c-redistributable-version)

## Security

Each build artifact is accompanied by a provenance file. This attestation provides a verifiable guarantee that the artifact was built from the specified source within this trusted GitHub Actions workflow.

## License

This project is licensed under the GPLv3 License. See the [LICENSE](LICENSE) file for details.
