function portkill
  if test (count $argv) -eq 0
    echo "Usage: portkill <port_number>"
    return 1
  end
  
  # Check if lsof is available
  if not command -v lsof >/dev/null 2>&1
    echo "Error: lsof command not found"
    return 1
  end
  
  set pids (lsof -ti TCP:$argv[1] 2>/dev/null)
  
  if test -z "$pids"
    echo "No processes found listening on port $argv[1]"
    return 1
  end
  
  echo "Found processes on port $argv[1]: $pids"
  
  # Kill the processes if pids is not empty
  if test -n "$pids"
    echo $pids | xargs kill -9
    echo "Port $argv[1] processes killed."
  end
end
