function tkdir -d "Create directory and change into it"
    if test (count $argv) -eq 0
        echo "Usage: tkdir <directory>"
        return 1
    end
    
    mkdir -p $argv[1]
    and cd $argv[1]
end
