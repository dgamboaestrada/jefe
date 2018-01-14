#!/bin/bash
# Remove jefe alias from .zshrc file
if [ -f ~/.zshrc ]
then
    echo " Removing jefe alias from .zshrc file..."
    sed -i "/# ----- Begin jefe-cli -----/,/# ----- End jefe-cli -----/ d" ~/.zshrc
    echo "Done."
fi

# Remove jefe alias from .zshrc file
if [ -f ~/.bashrc ]
then
    echo "Removing jefe alias from .zshrc file"
    sed -i "/# ----- Begin jefe-cli -----/,/# ----- End jefe-cli -----/ d" ~/.bashrc
    echo "Done."
fi

# Delete instalation of jefe-cli
echo "Deleting instalation of jefe-cli..."
rm -rf ~/.jefe/
echo "Done."
echo "Uninstalled successfully!"
