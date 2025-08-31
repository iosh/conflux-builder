import yargs from "yargs/yargs";
import { hideBin } from "yargs/helpers";
import fs from "fs-extra";
import path from "path";
import archiver from "archiver";
import * as core from "@actions/core";

async function main() {
  const packagingDir = "packaging_temp";

  try {
    const argv = await yargs(hideBin(process.argv))
      .option("os", {
        type: "string",
        required: true,
        description: "Operating System (linux, darwin, windows)",
      })
      .option("arch", {
        type: "string",
        required: true,
        description: "CPU Architecture",
      })
      .option("version-tag", {
        type: "string",
        required: true,
        description: "Version tag (e.g., v3.0.0)",
      })
      .option("build-path", {
        type: "string",
        required: true,
        description: "Path to the build artifacts",
      })
      .option("source-dir", {
        type: "string",
        required: true,
        description:
          "Directory containing files to package (e.g., the `run` folder)",
      })
      .option("output-dir", {
        type: "string",
        required: true,
        description: "Directory to place the final archive",
      })
      // Linux specific options
      .option("glibc-version", {
        type: "string",
        default: "2.39",
        description: "Glibc version",
      })
      .option("openssl-version", {
        type: "string",
        default: "3",
        description: "OpenSSL version",
      })
      .option("static-openssl", {
        type: "boolean",
        default: true,
        description: "Statically link OpenSSL",
      })
      .option("compatibility-mode", {
        type: "boolean",
        default: false,
        description: "Enable compatibility mode",
      })
      .parseAsync();

    const versionTagCleaned = argv.versionTag.startsWith("v")
      ? argv.versionTag.substring(1)
      : argv.versionTag;

    const platform = argv.os === "macos" ? "apple-darwin" : argv.os;

    let baseName = `conflux-v${versionTagCleaned}-${platform}-${argv.arch}`;

    let suffix = "";

    if (platform === "linux") {
      suffix += `-glibc${argv.glibcVersion}`;
      if (argv.opensslVersion !== "3") {
        suffix += `-${argv.opensslVersion}`;
      }
    }

    if (!argv.staticOpenssl) {
      suffix += `-dynamic-openssl`;
    }

    if (argv.compatibilityMode) {
      suffix += "-portable";
    }

    const artifactBaseName = `${baseName}${suffix}`;
    const archiveExtension = platform === "windows" ? "zip" : "tar.gz";
    const archiveName = `${artifactBaseName}.${archiveExtension}`;
    // Normalize the archive path for the current platform
    const archivePath = path.posix.join(argv.outputDir, archiveName);

    core.info(`Artifact base name: ${artifactBaseName}`);
    core.info(`Archive name: ${archiveName}`);
    core.info(`Archive path: ${archivePath}`);

    await fs.ensureDir(packagingDir);

    const binaryName = platform === "windows" ? "conflux.exe" : "conflux";
    const binaryPath = path.join(argv.buildPath, binaryName);
    if (!(await fs.pathExists(binaryPath))) {
      throw new Error(`Binary not found at ${binaryPath}`);
    }

    await fs.copy(binaryPath, path.join(packagingDir, binaryName));
    await fs.copy(argv.sourceDir, packagingDir);

    if (platform === "windows" && !argv.staticOpenssl) {
      // Copy the OpenSSL DLLs to the packaging directory
      const dllSuffix = argv.arch === "aarch64" ? "arm64" : "x64";
      const cryptoDll = `libcrypto-3-${dllSuffix}.dll`;
      const sslDll = `libssl-3-${dllSuffix}.dll`;
      await fs.copy(
        path.join(argv.buildPath, cryptoDll),
        path.join(packagingDir, cryptoDll)
      );
      await fs.copy(
        path.join(argv.buildPath, sslDll),
        path.join(packagingDir, sslDll)
      );
    }

    const output = fs.createWriteStream(archivePath);
    const archive = archiver(platform === "windows" ? "zip" : "tar", {
      gzip: platform !== "windows",
      zlib: { level: 9 },
    });

    archive.pipe(output);
    archive.directory(packagingDir, false);
    await archive.finalize();

    await fs.remove(packagingDir);

    const stats = await fs.stat(archivePath);
    core.info(`Successfully created archive: ${archivePath}`);
    core.info(`Archive size: ${(stats.size / 1024 / 1024).toFixed(2)} MB`);

    core.setOutput("artifact_base_name", artifactBaseName);
    core.setOutput("archive_name", archiveName);
    core.setOutput("archive_path", archivePath);
  } catch (error) {
    core.error(
      `Build failed: ${error instanceof Error ? error.message : String(error)}`
    );

    // Clean up temporary directory on error
    try {
      await fs.remove(packagingDir);
      core.info(`Cleaned up temporary directory: ${packagingDir}`);
    } catch (cleanupError) {
      core.warning(`Failed to cleanup ${packagingDir}: ${cleanupError}`);
    }

    throw error;
  }
}

main().catch((error) => {
  core.setFailed(error instanceof Error ? error.message : String(error));
});
