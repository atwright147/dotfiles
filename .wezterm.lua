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
    
    if success and wsl_list then
      local wsl_envs = {}
      for line in string.gmatch(wsl_list, '([^\r\n]+)') do
        table.insert(wsl_envs, line)
      end
      return wsl_envs
    else
      wezterm.log_error("Failed to list WSL distributions")
      return {}
    end
  end
  return {}
end

-- Set up a keybinding or launcher to start WSL distributions (optional)
config.launch_menu = config.launch_menu or {}
local wsl_envs = list_wsl_distributions()
for _, distro in ipairs(wsl_envs) do
  table.insert(config.launch_menu, {
    label = "WSL: " .. distro,
    args = {"wsl.exe", "-d", distro },
  })
end

-- and finally, return the configuration to wezterm
return config
