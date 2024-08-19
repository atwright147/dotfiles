-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

-- Set the color scheme
config.color_scheme = 'Monokai Remastered'
config.font = wezterm.font 'FiraCode Nerd Font'

-- Function to detect the shell based on the operating system
local function detect_shell()
  if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    -- Windows: Use PowerShell by default
    return { 'pwsh.exe', '-NoLogo' }
  elseif wezterm.target_triple == "x86_64-apple-darwin" then
    -- macOS: Use the default shell
    return { os.getenv("SHELL") or "/bin/zsh" }
  else
    -- Linux: Use the default shell
    return { os.getenv("SHELL") or "/bin/bash" }
  end
end

-- Set the default program based on the detected shell
config.default_prog = detect_shell()

-- Function to list WSL distributions on Windows
local function list_wsl_distributions()
  if wezterm.target_triple == "x86_64-pc-windows-msvc" then
    -- Attempt to run the WSL command and capture the output
    local success, wsl_list = pcall(wezterm.run_child_process, {"wsl.exe", "-l", "-q"})

    if success and type(wsl_list) == "string" then
      local wsl_envs = {}
      for line in string.gmatch(wsl_list, '([^\r\n]+)') do
        table.insert(wsl_envs, line)
      end
      return wsl_envs
    else
      wezterm.log_error("Failed to list WSL distributions or invalid output received")
      return {}
    end
  end
  return {}
end

-- Set up a keybinding or launcher to start WSL distributions
config.launch_menu = config.launch_menu or {}

-- Add WSL distributions to the launch menu if on Windows
local wsl_envs = list_wsl_distributions()
for _, distro in ipairs(wsl_envs) do
  table.insert(config.launch_menu, {
    label = "WSL: " .. distro,
    args = {"wsl.exe", "-d", distro },
  })
end

-- Add cmd.exe to the launch menu if on Windows
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
  table.insert(config.launch_menu, {
    label = "Command Prompt",
    args = {"cmd.exe"},
  })
end

-- Function to check if PowerShell is available
local function is_powershell_available()
  local success, result = pcall(wezterm.run_child_process, {"pwsh", "-Command", "echo 'PowerShell Available'"})
  
  -- Ensure result is a string before attempting to use it
  if success and type(result) == "string" and result:match("PowerShell Available") then
    return true
  end
  return false
end

-- Add PowerShell to the launch menu if available
if is_powershell_available() then
  table.insert(config.launch_menu, {
    label = "PowerShell",
    args = {"pwsh", "-NoLogo"},
  })
end

-- and finally, return the configuration to wezterm
return config
