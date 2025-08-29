# Custom fish_title function to prevent Fish from setting title
# This allows Oh My Posh to fully control the console title
function fish_title
    # Return empty string to prevent Fish from setting any title
    echo ""
end
