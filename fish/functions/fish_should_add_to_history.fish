function fish_should_add_to_history --description "Exclude certain commands from Fish history"
    # Get the command line as a string
    set -l cmdline (string trim $argv[1])
    
    # List of commands to exclude from history
    set -l excluded_commands clear cls
    
    # Check if the command (first word) is in the excluded list
    set -l command_name (string split -m 1 ' ' $cmdline)[1]
    
    if contains $command_name $excluded_commands
        return 1  # Don't add to history
    end
    
    return 0  # Add to history
end
