#!/usr/bin/env python3

import json
import subprocess
import sys
import platform

def get_os_info():
    """Determines the operating system and returns a key and package manager."""
    platform_name = sys.platform
    if platform_name == "darwin":
        return "macOS", "brew"
    elif platform_name.startswith("win"):
        return "Windows", "winget"
    elif platform_name.startswith("linux"):
        return "Linux", "apt"
    else:
        return None, None

def check_and_install_manager(package_manager):
    """Checks if a package manager is installed and installs it if possible."""
    try:
        if package_manager == "apt":
            return True
        elif package_manager == "brew":
            subprocess.run(["brew", "--version"], check=True, capture_output=True)
            return True
        elif package_manager == "winget":
            subprocess.run(["winget", "--version"], check=True, capture_output=True)
            return True
        else:
            return False
    except (subprocess.CalledProcessError, FileNotFoundError):
        print(f"❌ '{package_manager}' not found.")
        if package_manager == "brew":
            print("Installing Homebrew...")
            subprocess.run(["/bin/bash", "-c", "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"], check=True)
            print("✅ Homebrew installed.")
            return True
        return False

def check_and_install_cargo():
    """Checks if Cargo is installed and installs Rust if needed."""
    try:
        subprocess.run(["cargo", "--version"], check=True, capture_output=True)
        print("✅ Cargo is already installed.")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Cargo not found. Installing Rust...")
        try:
            subprocess.run(["curl", "--proto", "=https", "--tlsv1.2", "-sSf", "https://sh.rustup.rs", "|", "sh"], check=True, shell=True)
            print("✅ Rust and Cargo installed.")
            return True
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to install Rust/Cargo. Error: {e}")
            return False

def install_with_manager(packages, package_manager):
    """Installs packages using the specified manager."""
    print(f"\nInstalling packages with {package_manager}...")
    for package in packages:
        try:
            print(f"  - Installing {package}...")
            if package_manager == "brew":
                command = ["brew", "install", package]
            elif package_manager == "winget":
                command = ["winget", "install", "--id", package, "--silent", "--exact"]
            elif package_manager == "apt":
                command = ["sudo", "apt", "install", "-y", package]

            subprocess.run(command, check=True)
            print(f"  ✅ Successfully installed {package}")
        except subprocess.CalledProcessError as e:
            print(f"  ❌ Failed to install {package}. Error: {e}")
            break

def install_cargo_packages(packages):
    """Installs packages using Cargo."""
    print("\nInstalling Cargo packages...")
    for package in packages:
        try:
            print(f"  - Installing {package} with cargo...")
            command = ["cargo", "install", package]
            subprocess.run(command, check=True)
            print(f"  ✅ Successfully installed {package}")
        except subprocess.CalledProcessError as e:
            print(f"  ❌ Failed to install {package}. Error: {e}")

def main():
    """Main function to run the installation process."""
    try:
        with open("packages.json", "r") as f:
            config = json.load(f)
    except FileNotFoundError:
        print("Error: 'packages.json' not found.")
        return

    os_key, package_manager = get_os_info()

    if os_key and os_key in config:
        os_config = config[os_key]

        # Install packages via the standard package manager
        if "pkg" in os_config:
            if check_and_install_manager(package_manager):
                install_with_manager(os_config["pkg"], package_manager)

        # Install packages via Cargo
        if "cargo" in os_config:
            if check_and_install_cargo():
                install_cargo_packages(os_config["cargo"])

    else:
        print("Unsupported operating system or no package list found.")

if __name__ == "__main__":
    main()
