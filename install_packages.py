#!/usr/bin/env python3

import os
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

def check_package_installed(package, package_manager):
    """Checks if a package is already installed."""
    try:
        if package_manager == "winget":
            result = subprocess.run(["winget", "list", "--id", package],
                                  capture_output=True, text=True)
            return result.returncode == 0 and package in result.stdout
        elif package_manager == "brew":
            result = subprocess.run(["brew", "list", package],
                                  capture_output=True, text=True)
            return result.returncode == 0
        elif package_manager == "apt":
            result = subprocess.run(["dpkg", "-l", package],
                                  capture_output=True, text=True)
            return result.returncode == 0
    except FileNotFoundError:
        pass
    return False

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
        elif package_manager == "winget":
            print("❌ WinGet is not available. Please update Windows or install the App Installer from Microsoft Store.")
            print("   You can also install WinGet manually from: https://github.com/microsoft/winget-cli")
            return False
        return False

def check_and_install_cargo():
    """Checks if Cargo is installed and installs Rust/Cargo silently if needed, then sources env."""
    try:
        # Check if cargo is already installed by running in a subprocess (standard check)
        subprocess.run(["cargo", "--version"], check=True, capture_output=True)
        print("✅ Cargo is already installed.")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print("❌ Cargo not found. Installing Rust and sourcing environment...")
        try:
            # CORRECTED COMMAND: Use the TILDE (~) for the path and use double quotes.
            # We must pass this as a single string and set shell=True to handle the pipe (|).
            # Note: Rustup creates the .cargo/env file *after* it runs, so sourcing immediately may fail.
            # The most reliable method is to perform the PATH update after installation.

            # --- Phase 1: Install Rust ---
            install_command = "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
            subprocess.run(install_command, check=True, shell=True)
            print("✅ Rust and Cargo installed.")

            # --- Phase 2: Manually Update Python's PATH ---
            # Now that Rust is installed, we force a bash shell to source the env file
            # and print the resulting PATH to update Python's environment.

            # Use Tilde (~) expansion for robustness
            path_command = "bash -c '. \"$HOME/.cargo/env\" && echo $PATH'"

            # Using 'bash -c' ensures the command is run in an environment that understands 'source'/'dot'
            new_path = subprocess.run(path_command, shell=True, capture_output=True, text=True, check=True).stdout.strip()

            # Update the PATH in the current Python environment
            os.environ['PATH'] = new_path

            print(f"✅ Python's OS environment PATH updated. Cargo should now be available.")
            return True
        except subprocess.CalledProcessError as e:
            print(f"❌ Failed to install Rust/Cargo or source environment. Error: {e}")
            return False
        except FileNotFoundError:
            print("❌ Error: 'curl' or 'bash' not found. Cannot install Rust.")
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

            result = subprocess.run(command, capture_output=True, text=True)

            # Handle different exit codes
            if result.returncode == 0:
                print(f"  ✅ Successfully installed {package}")
            elif package_manager == "winget" and result.returncode == 1:
                # WinGet returns 1 when package is already installed
                print(f"  ℹ️  {package} is already installed (up to date)")
            elif package_manager == "winget" and result.returncode == -1978335189:
                # Another common WinGet "already installed" code
                print(f"  ℹ️  {package} is already installed")
            else:
                # Other error codes - let's be more helpful
                error_msg = result.stderr.strip() if result.stderr else result.stdout.strip()
                if "already installed" in error_msg.lower() or "no newer package versions" in error_msg.lower():
                    print(f"  ℹ️  {package} is already up to date")
                else:
                    print(f"  ❌ Failed to install {package}. Exit code: {result.returncode}")
                    if error_msg:
                        print(f"    Details: {error_msg}")

        except FileNotFoundError:
            print(f"  ❌ Package manager '{package_manager}' not found. Please install it first.")
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

def install_oh_my_posh():
    """Installs oh-my-posh using the official installation script for Linux."""
    print("\nInstalling oh-my-posh...")
    try:
        # Download and install oh-my-posh using the official script
        command = "curl -s https://ohmyposh.dev/install.sh | bash -s"
        subprocess.run(command, shell=True, check=True)
        print("✅ oh-my-posh installed successfully")

        # Add oh-my-posh to PATH in shell rc files if needed
        home = os.path.expanduser("~")
        shell_files = [
            os.path.join(home, ".bashrc"),
            os.path.join(home, ".zshrc")
        ]

        omp_path = '/usr/local/bin'
        path_export = f'export PATH="{omp_path}:$PATH"'

        for shell_file in shell_files:
            if os.path.exists(shell_file):
                with open(shell_file, "r") as f:
                    content = f.read()

                # Check if PATH is already configured for oh-my-posh
                if omp_path not in content and "oh-my-posh" not in content:
                    with open(shell_file, "a") as f:
                        f.write(f'\n# Added by dotfiles installer for oh-my-posh\n{path_export}\n')
                    print(f"✅ Added oh-my-posh to PATH in {shell_file}")

        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Failed to install oh-my-posh. Error: {e}")
        return False
    except FileNotFoundError:
        print("❌ Error: 'curl' or 'bash' not found. Cannot install oh-my-posh.")
        return False

def main():
    """Main function to run the installation process."""
    # Change to script directory to ensure we find packages.json
    script_dir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(script_dir)

    try:
        with open("packages.json", "r") as f:
            config = json.load(f)
    except FileNotFoundError:
        print("Error: 'packages.json' not found.")
        print(f"Current directory: {os.getcwd()}")
        print("Make sure both install_packages.py and packages.json are in the same directory.")
        if sys.platform.startswith("win"):
            input("Press Enter to exit...")
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

        # Install oh-my-posh on Linux only
        if os_key == "Linux" and "oh_my_posh" in os_config and os_config["oh_my_posh"]:
            install_oh_my_posh()

        print("\n✅ Installation process completed!")
    else:
        print("Unsupported operating system or no package list found.")

    # On Windows, pause before closing when run directly
    if sys.platform.startswith("win"):
        input("Press Enter to exit...")

if __name__ == "__main__":
    main()
