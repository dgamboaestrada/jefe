#!/bin/bash
echo "Cloning repositorie..."
git clone git@github.com:dgamboaestrada/jefe.git -b development ~/.jefe/
chmod +x ~/.jefe/jefe-cli.sh
chmod +x ~/.jefe/install.sh
chmod +x ~/.jefe/uninstall.sh
echo "Done."

# Set jefe alias in .zshrc file
if [ -f ~/.zshrc ]; then
    echo "Setting zsh configuration..."
    sed -i "/# ----- Begin jefe-cli -----/,/# ----- End jefe-cli -----/ d" ~/.zshrc
    echo "# ----- Begin jefe-cli -----" >> ~/.zshrc
    echo "alias jefe=~/.jefe/jefe-cli.sh" >> ~/.zshrc
    echo "# ----- End jefe-cli -----" >> ~/.zshrc
    echo "Done."
fi

# Set jefe alias in .zshrc file
if [ -f ~/.bashrc ]; then
    echo "Setting bash configuration..."
    sed -i "/# ----- Begin jefe-cli -----/,/# ----- End jefe-cli -----/ d" ~/.bashrc
    echo "# ----- Begin jefe-cli -----" >> ~/.bashrc
    echo "alias jefe=~/.jefe/jefe-cli.sh" >> ~/.bashrc
    echo "# ----- End jefe-cli -----" >> ~/.bashrc
    echo "Done."
fi

echo "JEFE-CLI was installed successfully!!!"
echo "Reload your configuration .zshrc('\$source ~/.zshrc') or .bashrc('\$source ~/.bashrc')"
