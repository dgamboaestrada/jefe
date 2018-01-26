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

# Remove alpha version of jefe
if [ -f ~/.zshrc ]; then
    puts "Removing alpha version of jefe..."
    sudo rm /usr/local/bin/jefe
    puts "Done." GREEN
fi

puts "Cloning repositorie..."
git clone git@github.com:dgamboaestrada/jefe.git -b development ~/.jefe-cli/
chmod +x ~/.jefe-cli/jefe-cli.sh
chmod +x ~/.jefe-cli/install.sh
chmod +x ~/.jefe-cli/uninstall.sh
puts "Done." GREEN

# Set jefe alias in .zshrc file
if [ -f ~/.zshrc ]; then
    puts "Setting zsh configuration..."
    sed -i "/# ----- Begin jefe-cli -----/,/# ----- End jefe-cli -----/ d" ~/.zshrc
    echo "# ----- Begin jefe-cli -----" >> ~/.zshrc
    echo "alias jefe=~/.jefe-cli/jefe-cli.sh" >> ~/.zshrc
    echo "# ----- End jefe-cli -----" >> ~/.zshrc
    puts "Done." GREEN
fi

# Set jefe alias in .zshrc file
if [ -f ~/.bashrc ]; then
    puts "Setting bash configuration..."
    sed -i "/# ----- Begin jefe-cli -----/,/# ----- End jefe-cli -----/ d" ~/.bashrc
    echo "# ----- Begin jefe-cli -----" >> ~/.bashrc
    echo "alias jefe=~/.jefe-cli/jefe-cli.sh" >> ~/.bashrc
    echo "# ----- End jefe-cli -----" >> ~/.bashrc
    puts "Done." GREEN
fi

puts "JEFE-CLI was installed successfully!!!" GREEN
puts "Reload your configuration .zshrc('\$source ~/.zshrc') or .bashrc('\$source ~/.bashrc')" YELLOW
