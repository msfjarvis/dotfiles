#!/usr/bin/env python

import os
import subprocess
import sys
import argparse
from typing import List


def run_command(command: List[str], shell: bool = False) -> int:
    """
    Runs a command, prints the command being run, and prints stdout and stderr to the screen.
    Returns the return code of the command.
    """
    print(f"Running command: {' '.join(command)}")
    try:
        result = subprocess.run(command, check=True, shell=shell, text=True)
        if result.stdout:
            print(result.stdout, end="")
        if result.stderr:
            print(result.stderr, end="", file=sys.stderr)
        return result.returncode
    except subprocess.CalledProcessError as e:
        print(f"Command failed: {e}", file=sys.stderr)
        print(f"Return Code: {e.returncode}", file=sys.stderr)
        if e.stdout:
            print(e.stdout, end="")
        if e.stderr:
            print(e.stderr, end="", file=sys.stderr)
        raise


def get_hostname() -> str:
    """
    Gets the current hostname using the 'hostname' command.
    """
    try:
        result = subprocess.run(
            ["hostname"], check=True, capture_output=True, text=True
        )
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        print("Error: Unable to fetch hostname.", file=sys.stderr)
        sys.exit(1)


def nom_build(flake: str, local: bool = False) -> None:
    """
    Builds a Nix flake using nom.
    """
    command: List[str] = [
        "nom",
        "build",
        "--option",
        "always-allow-substitutes",
        "true",
    ]
    cpu_count = os.cpu_count()
    if cpu_count is not None:
        max_jobs = cpu_count // 2
        command.extend(["--option", "max-jobs", str(max_jobs)])

    if local:
        command.extend(["--builders", "''"])

    command.append(f".#nixosConfigurations.{flake}.config.system.build.toplevel")
    run_command(command)


def cleanup_generations() -> None:
    """
    Deletes old Nix generations and switches to the new configuration.
    """
    run_command(
        [
            "sudo",
            "nix-env",
            "--delete-generations",
            "--profile",
            "/nix/var/nix/profiles/system",
            "old",
        ]
    )
    run_command(
        [
            "nix-env",
            "--delete-generations",
            "--profile",
            os.path.expanduser("~/.local/state/nix/profiles/home-manager"),
            "old",
        ]
    )
    run_command(
        ["sudo", "/nix/var/nix/profiles/system/bin/switch-to-configuration", "switch"]
    )


def gradle_hash(version: str) -> None:
    """
    Calculates the Nix hash for a Gradle distribution and writes it to a file.
    """
    prefetch_url_command: List[str] = [
        "nix-prefetch-url",
        "--type",
        "sha256",
        f"https://services.gradle.org/distributions/gradle-{version}-bin.zip",
    ]
    run_command(prefetch_url_command)


def bash_completion(args: List[str]) -> None:
    """
    Outputs possible completions for the script arguments.
    """
    # Simulate command-line arguments for completion
    partial = args[-1] if args else ""
    commands = [
        "boot",
        "chart",
        "check",
        "darwin-check",
        "darwin-switch",
        "gradle-hash",
        "test",
        "switch",
    ]

    # If the user has already provided a command, complete its arguments
    if len(args) > 1 and args[0] in commands:
        command = args[0]
        if command == "check":
            options = []
            # Suggest --local only if not already in args
            if "--local" not in args:
                options.append("--local")
            print("\n".join(o for o in options if o.startswith(partial)))
        elif command == "gradle-hash":
            print("Provide a Gradle version (e.g., 7.5)")
    else:
        # Complete the main commands
        print("\n".join(c for c in commands if c.startswith(partial)))


if __name__ == "__main__":
    # Check if the script is invoked for Bash completion
    if "--bash-completion" in sys.argv:
        bash_completion(sys.argv[sys.argv.index("--bash-completion") + 1 :])
        sys.exit(0)

    parser: argparse.ArgumentParser = argparse.ArgumentParser(
        description="Nix helper script"
    )
    subparsers = parser.add_subparsers(dest="command", help="Sub-command help")

    # boot
    boot_parser = subparsers.add_parser("boot", help="Boot the system")

    # chart
    chart_parser = subparsers.add_parser("chart", help="Build the topology chart")

    # check
    check_parser = subparsers.add_parser("check", help="Check a Nix flake")
    check_parser.add_argument("target", nargs="?", help="Target flake to check")
    check_parser.add_argument("--local", action="store_true", help="Use local builders")

    # darwin-check
    darwin_check_parser = subparsers.add_parser(
        "darwin-check", help="Check a Darwin system"
    )

    # darwin-switch
    darwin_switch_parser = subparsers.add_parser(
        "darwin-switch", help="Switch a Darwin system"
    )

    # gradle-hash
    gradle_hash_parser = subparsers.add_parser(
        "gradle-hash", help="Calculate Gradle hash"
    )
    gradle_hash_parser.add_argument("version", help="Gradle version")

    # test
    test_parser = subparsers.add_parser("test", help="Run tests")

    # switch
    switch_parser = subparsers.add_parser("switch", help="Switch the system")

    args: argparse.Namespace = parser.parse_args()

    match args.command:
        case "boot":
            run_command(["nh", "os", "boot", "."])
        case "chart":
            run_command(["nix", "build", ".#topology.x86_64-linux.config.output"])
        case "check":
            # Use the 'hostname' command to get the default target if none is provided
            target = args.target if args.target else get_hostname()
            nom_build(target, args.local)
        case "darwin-check":
            hostname = get_hostname()
            run_command(["nom", "build", f".#darwinConfigurations.{hostname}.system"])
        case "darwin-switch":
            run_command(
                [
                    "sudo",
                    "darwin-rebuild",
                    "switch",
                    "--option",
                    "sandbox",
                    "false",
                    "--print-build-logs",
                    "--flake",
                    ".",
                ]
            )
        case "gradle-hash":
            gradle_hash(args.version)
        case "test":
            run_command(["nh", "os", "test", "."])
        case "switch":
            run_command(["nh", "os", "switch", "."])
            cleanup_generations()
        case None:
            parser.print_help()
            sys.exit(1)
        case _:
            print(f"Invalid command: {args.command}")
            sys.exit(1)
