function up -d "Navigate up directories: 'up' for one level, 'up N' for N levels"
    if test (count $argv) -lt 1
        cd ..
    else
        set cdstr ""
        for i in (seq 1 $argv[1])
            set cdstr "../$cdstr"
        end
        cd $cdstr
    end
end
