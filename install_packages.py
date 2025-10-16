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

def is_wsl():
    """Detects if running in Windows Subsystem for Linux (WSL)."""
    try:
        # Check for WSL-specific files/environment variables
        if os.path.exists('/proc/version'):
            with open('/proc/version', 'r') as f:
                version_info = f.read().lower()
                if 'microsoft' in version_info or 'wsl' in version_info:
                    return True

        # Check WSL environment variable
        if os.environ.get('WSL_DISTRO_NAME'):
            return True

        return False
    except:
        return False

def is_firacode_installed(os_key):
    """Checks if FiraCode font is already installed on the system."""
    try:
        if os_key == "Windows":
            # Check Windows font directories
            font_dirs = [
                os.path.expanduser("~\\AppData\\Local\\Microsoft\\Windows\\Fonts"),
                "C:\\Windows\\Fonts"
            ]
            firacode_patterns = ['firacode', 'fira code', 'fira_code']

            for font_dir in font_dirs:
                if os.path.exists(font_dir):
                    for file in os.listdir(font_dir):
                        file_lower = file.lower()
                        if any(pattern in file_lower for pattern in firacode_patterns):
                            return True

        elif os_key == "macOS":
            # Check macOS font directories
            font_dirs = [
                os.path.expanduser("~/Library/Fonts"),
                "/Library/Fonts",
                "/System/Library/Fonts"
            ]
            firacode_patterns = ['firacode', 'fira code', 'fira_code']

            for font_dir in font_dirs:
                if os.path.exists(font_dir):
                    for file in os.listdir(font_dir):
                        file_lower = file.lower()
                        if any(pattern in file_lower for pattern in firacode_patterns):
                            return True

        elif os_key == "Linux":
            # Check Linux font directories
            font_dirs = [
                os.path.expanduser("~/.local/share/fonts"),
                os.path.expanduser("~/.fonts"),
                "/usr/share/fonts",
                "/usr/local/share/fonts"
            ]
            firacode_patterns = ['firacode', 'fira code', 'fira_code']

            for font_dir in font_dirs:
                if os.path.exists(font_dir):
                    for root, dirs, files in os.walk(font_dir):
                        for file in files:
                            file_lower = file.lower()
                            if any(pattern in file_lower for pattern in firacode_patterns):
                                return True

        return False
    except Exception:
        # If there's any error checking, assume font is not installed
        return False

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

def install_oh_my_posh_linux():
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

        omp_path = os.path.join(home, '.local/bin')
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

def setup_fish_post_install(os_key):
    """Set up fish shell after all packages are installed."""
    print("\nSetting up fish shell post-installation...")
    
    try:
        # Check if fish is available
        fish_check = subprocess.run(["fish", "--version"], capture_output=True, text=True)
        if fish_check.returncode != 0:
            print("❌ Fish shell is not available")
            return False
        
        # Update PATH to include oh-my-posh if it was installed
        home = os.path.expanduser("~")
        omp_path = os.path.join(home, '.local/bin')
        
        if os.path.exists(os.path.join(omp_path, 'oh-my-posh')):
            print(f"  ✅ Found oh-my-posh at {omp_path}")
            
            # Check if fish config exists and can be sourced
            fish_config_path = os.path.expanduser("~/.config/fish")
            if os.path.exists(fish_config_path):
                print("  ✅ Fish configuration directory exists")
                
                # Try to run a simple fish command to verify configuration works
                test_cmd = f'fish -c "echo \\"Fish configuration test\\""'
                test_result = subprocess.run(test_cmd, shell=True, capture_output=True, text=True)
                
                if test_result.returncode == 0:
                    print("  ✅ Fish configuration is working")
                    print("\n🎉 Fish shell setup complete!")
                    print("⚠️  Please start a new fish shell session or run 'exec fish' to load the new configuration")
                    print("   Your aliases and functions will be available in the new session")
                    return True
                else:
                    print(f"  ⚠️  Fish configuration test failed: {test_result.stderr.strip()}")
            else:
                print(f"  ❌ Fish configuration directory not found at {fish_config_path}")
        else:
            print(f"  ⚠️  oh-my-posh not found at {omp_path}")
            
        return False
        
    except Exception as e:
        print(f"❌ Error setting up fish shell: {e}")
        return False

def install_fish_config():
    """Installs fish shell configuration by running fish/install.fish script."""
    print("\nInstalling fish shell configuration...")
    
    script_dir = os.getcwd()
    fish_dir = os.path.join(script_dir, "fish")
    script_path = os.path.join(fish_dir, "install.fish")
    
    if not os.path.exists(script_path):
        print(f"❌ Fish install script not found at: {script_path}")
        return False
    
    try:
        # Check if fish is installed
        fish_check = subprocess.run(["fish", "--version"], capture_output=True, text=True)
        if fish_check.returncode != 0:
            print("❌ Fish shell is not installed. Please install fish first.")
            return False
        
        print(f"  Running fish install script: {script_path}")
        # Change to fish directory before running the script to ensure proper symlink creation
        result = subprocess.run(["fish", script_path], capture_output=True, text=True, cwd=fish_dir)
        
        if result.returncode == 0:
            print("✅ Fish shell configuration installed successfully")
            if result.stdout:
                print(f"  Output: {result.stdout.strip()}")
            
            # Verify the symlink was created correctly
            fish_config_path = os.path.expanduser("~/.config/fish")
            if os.path.islink(fish_config_path):
                link_target = os.readlink(fish_config_path)
                print(f"  ✅ Fish config symlinked: {fish_config_path} -> {link_target}")
            else:
                print(f"  ⚠️  Fish config symlink verification failed")
            
            # Check gitconfig symlink too
            gitconfig_path = os.path.expanduser("~/.gitconfig")
            if os.path.islink(gitconfig_path):
                link_target = os.readlink(gitconfig_path)
                print(f"  ✅ Gitconfig symlinked: {gitconfig_path} -> {link_target}")
            else:
                print(f"  ⚠️  Gitconfig symlink verification failed")
                
            return True
        else:
            print(f"❌ Failed to install fish configuration. Exit code: {result.returncode}")
            if result.stderr:
                print(f"  Error: {result.stderr.strip()}")
            return False
            
    except FileNotFoundError:
        print("❌ Fish shell is not installed or not in PATH")
        return False
    except Exception as e:
        print(f"❌ Unexpected error installing fish configuration: {e}")
        return Falsedef install_omp_font(os_key):
    """Installs FiraCode font using oh-my-posh for all platforms."""
    print("\nInstalling FiraCode font...")

    # Skip font installation in WSL
    if os_key == "Linux" and is_wsl():
        print("⚠️  Skipping font installation in WSL environment")
        print("   Fonts should be installed from Windows host, not WSL")
        print("   Run 'oh-my-posh font install firacode' from Windows PowerShell/Command Prompt")
        return True  # Return True since this is expected behavior

    # Check if FiraCode font is already installed
    if is_firacode_installed(os_key):
        print("ℹ️  FiraCode font is already installed, skipping installation")
        return True

    # Add a small delay to ensure package installation has completed
    import time
    time.sleep(2)

    try:
        # Prepare environment based on OS
        updated_env = os.environ.copy()
        omp_binary_path = None

        if os_key == "Linux":
            # Update PATH for current session to include oh-my-posh
            home = os.path.expanduser("~")
            omp_path = os.path.join(home, '.local/bin')
            omp_binary_path = os.path.join(omp_path, 'oh-my-posh')
            updated_env['PATH'] = f"{omp_path}:{updated_env.get('PATH', '')}"

            # Debug: Check if binary exists
            print(f"  Checking for oh-my-posh at: {omp_binary_path}")
            if os.path.exists(omp_binary_path):
                print(f"  ✅ Found oh-my-posh binary")
            else:
                print(f"  ❌ oh-my-posh binary not found at expected location")

        elif os_key == "macOS":
            # Add common Homebrew paths for oh-my-posh
            homebrew_paths = ['/opt/homebrew/bin', '/usr/local/bin']
            current_path = updated_env.get('PATH', '')
            for path in homebrew_paths:
                if path not in current_path:
                    updated_env['PATH'] = f"{path}:{current_path}"
                    current_path = updated_env['PATH']
        elif os_key == "Windows":
            # On Windows, find oh-my-posh installed via WinGet
            possible_paths = [
                os.path.expanduser("~\\AppData\\Local\\Programs\\oh-my-posh\\bin"),
                "C:\\Program Files\\oh-my-posh\\bin",
                os.path.expanduser("~\\AppData\\Local\\Microsoft\\WinGet\\Packages\\JanDeDobbeleer.OhMyPosh_Microsoft.Winget.Source_8wekyb3d8bbwe")
            ]
            current_path = updated_env.get('PATH', '')
            omp_binary_path = None

            print("  Checking WinGet installation paths for oh-my-posh...")
            for path in possible_paths:
                omp_exe = os.path.join(path, 'oh-my-posh.exe')
                print(f"    Checking: {omp_exe}")
                if os.path.exists(omp_exe):
                    print(f"    ✅ Found oh-my-posh.exe at: {path}")
                    omp_binary_path = omp_exe
                    if path not in current_path:
                        updated_env['PATH'] = f"{path};{current_path}"
                    break
                else:
                    print(f"    ❌ Not found at: {path}")

            if not omp_binary_path:
                print("  ❌ oh-my-posh.exe not found in any expected WinGet locations")

        # Debug: Show the PATH we're using
        print(f"  Using PATH: {updated_env['PATH'][:100]}...")

        # Try to run oh-my-posh version first to verify it's accessible
        print("  Checking oh-my-posh accessibility...")
        version_result = subprocess.run(["oh-my-posh", "--version"],
                                       capture_output=True, text=True, env=updated_env)

        if version_result.returncode == 0:
            print(f"  ✅ oh-my-posh is accessible, version: {version_result.stdout.strip()}")
        else:
            print(f"  ❌ oh-my-posh version check failed: {version_result.stderr.strip()}")
            raise FileNotFoundError("oh-my-posh not accessible")

        # Try to run oh-my-posh font install
        print("  Running font installation...")
        try:
            result = subprocess.run(["oh-my-posh", "font", "install", "firacode"],
                                  capture_output=True, text=True, env=updated_env, timeout=60)

            print(f"  Font installation exit code: {result.returncode}")
            if result.stdout:
                print(f"  Stdout: {result.stdout.strip()}")
            if result.stderr:
                print(f"  Stderr: {result.stderr.strip()}")

            if result.returncode == 0:
                print("✅ FiraCode font installed successfully")
                return True
            else:
                # If it fails, provide helpful message
                print(f"❌ Failed to install FiraCode font. Exit code: {result.returncode}")
                print("You can install it manually later with: oh-my-posh font install firacode")
                return False

        except subprocess.TimeoutExpired:
            print("❌ Font installation timed out after 60 seconds")
            print("You can install it manually later with: oh-my-posh font install firacode")
            return False

    except FileNotFoundError as e:
        print("❌ Error: 'oh-my-posh' command not found. Make sure oh-my-posh is installed and in PATH.")
        print("You can install it manually later with: oh-my-posh font install firacode")
        return False
    except Exception as e:
        print(f"❌ Unexpected error installing font: {e}")
        print("You can install it manually later with: oh-my-posh font install firacode")
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

        # Install fish shell configuration if on macOS/Linux
        if os_key in ["macOS", "Linux"]:
            install_fish_config()

        # Install oh-my-posh on Linux only
        if os_key == "Linux" and "oh_my_posh" in os_config and os_config["oh_my_posh"]:
            install_oh_my_posh_linux()

        # Install FiraCode font for oh-my-posh on all platforms (after packages are installed)
        omp_installed = False
        if os_key == "Linux" and "oh_my_posh" in os_config and os_config["oh_my_posh"]:
            omp_installed = True
        elif os_key in ["macOS", "Windows"] and "pkg" in os_config:
            # Check if oh-my-posh is in the package list
            omp_packages = ["oh-my-posh", "JanDeDobbeleer.OhMyPosh"]
            omp_installed = any(pkg in os_config["pkg"] for pkg in omp_packages)

        if omp_installed:
            font_success = install_omp_font(os_key)
            if not font_success:
                print("\n⚠️  Installation completed with issues: FiraCode font installation failed")
            else:
                print("\n✅ Installation process completed successfully!")
                
            # Set up fish shell after everything is installed
            if os_key in ["macOS", "Linux"]:
                setup_fish_post_install(os_key)
        else:
            print("\n✅ Installation process completed!")
            
            # Still try to set up fish even if oh-my-posh wasn't installed
            if os_key in ["macOS", "Linux"]:
                setup_fish_post_install(os_key)
    else:
        print("Unsupported operating system or no package list found.")

    # On Windows, pause before closing when run directly
    if sys.platform.startswith("win"):
        input("Press Enter to exit...")

if __name__ == "__main__":
    main()
