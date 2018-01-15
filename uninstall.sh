#!/bin/bash
puts() {
#     Num  Colour    #define         R G B
#     0    black     COLOR_BLACK     0,0,0
#     1    red       COLOR_RED       1,0,0
#     2    green     COLOR_GREEN     0,1,0
#     3    yellow    COLOR_YELLOW    1,1,0
#     4    blue      COLOR_BLUE      0,0,1
#     5    magenta   COLOR_MAGENTA   1,0,1
#     6    cyan      COLOR_CYAN      0,1,1
#     7    white     COLOR_WHITE     1,1,1
    text=$1
    case $2 in
        "black"|"BLACK")
            output_color=0
        ;;
        "red"|"RED")
            output_color=1
        ;;
        "green"|"GREEN")
            output_color=2
        ;;
        "yellow"|"YELLOW")
            output_color=3
        ;;
        "blue"|"BLUE")
            output_color=4
        ;;
        "magenta"|"MAGENTA")
            output_color=5
        ;;
        "cyan"|"CYAN")
            output_color=6
        ;;
        "white"|"WHITE")
            output_color=7
        ;;
    esac
    if [ -z "$output_color" ]; then
        echo "$text"
    else
        echo "$(tput setaf $output_color)$text $(tput sgr 0)"
    fi
    unset output_color
}

# Remove jefe alias from .zshrc file
if [ -f ~/.zshrc ]
then
    puts " Removing jefe alias from .zshrc file..."
    sed -i "/# ----- Begin jefe-cli -----/,/# ----- End jefe-cli -----/ d" ~/.zshrc
    puts "Done." GREEN
fi

# Remove jefe alias from .zshrc file
if [ -f ~/.bashrc ]
then
    puts "Removing jefe alias from .zshrc file"
    sed -i "/# ----- Begin jefe-cli -----/,/# ----- End jefe-cli -----/ d" ~/.bashrc
    puts "Done." GREEN
fi

# Delete instalation of jefe-cli
puts "Deleting instalation of jefe-cli..."
rm -rf ~/.jefe/
puts "Done." GREEN
puts "Uninstalled successfully!" GREEN
