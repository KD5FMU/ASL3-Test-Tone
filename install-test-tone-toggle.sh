#!/bin/bash
#
# ASL3 Test Tone Toggle Installer
# This Script was created by Freddie Mac - KD5FMU and ChaptGPT OpenAI - June 2026
#
# This installer creates:
#   /etc/asterisk/local/test-tone.sh
#
# The installed script toggles the AllStarLink test tone using:
#   rpt fun NODE *904
#
# Intended for AllStarLink 3 on Debian 12 / Debian 13
#

set -e

SCRIPT_PATH="/etc/asterisk/local/test-tone.sh"
DTMF_COMMAND="*904"

echo "======================================"
echo " ASL3 Test Tone Toggle Installer"
echo "======================================"
echo

# Must be run as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Please run this installer with sudo."
    echo
    echo "Example:"
    echo "  sudo ./install-test-tone-toggle.sh"
    exit 1
fi

# Make sure Asterisk exists
if ! command -v asterisk >/dev/null 2>&1; then
    echo "WARNING: The asterisk command was not found."
    echo "This script is intended for an AllStarLink 3 system."
    echo
fi

# Ask for node number
while true; do
    read -rp "Enter your AllStarLink node number: " NODE_NUMBER

    if [[ "$NODE_NUMBER" =~ ^[0-9]+$ ]]; then
        break
    else
        echo "Please enter numbers only."
        echo
    fi
done

echo
echo "Installing test tone script for node: $NODE_NUMBER"
echo

# Make sure local directory exists
mkdir -p /etc/asterisk/local

# Create the test-tone.sh script
cat > "$SCRIPT_PATH" <<EOF
#!/bin/bash
#
# ASL3 Test Tone Toggle Script
#
# This script toggles the AllStarLink app_rpt test tone on/off.
#
# Installed node number:
#   $NODE_NUMBER
#
# Command used:
#   asterisk -rx "rpt fun $NODE_NUMBER $DTMF_COMMAND"
#
# To use:
#   sudo /etc/asterisk/local/test-tone.sh
#
# Run it once to turn the tone on.
# Run it again to turn the tone off.
#

set -e

NODE_NUMBER="$NODE_NUMBER"
DTMF_COMMAND="$DTMF_COMMAND"

if ! command -v asterisk >/dev/null 2>&1; then
    echo "ERROR: asterisk command not found."
    echo "Make sure AllStarLink 3 / Asterisk is installed."
    exit 1
fi

echo "Toggling ASL3 test tone on node \$NODE_NUMBER..."
asterisk -rx "rpt fun \$NODE_NUMBER \$DTMF_COMMAND"

echo
echo "Done."
echo "Run this same script again to toggle the test tone back off."
EOF

# Make executable
chmod +x "$SCRIPT_PATH"

# Set ownership if asterisk user exists
if id "asterisk" >/dev/null 2>&1; then
    chown asterisk:asterisk "$SCRIPT_PATH"
else
    chown root:root "$SCRIPT_PATH"
fi

echo "Installation complete."
echo
echo "Test tone toggle script installed at:"
echo "  $SCRIPT_PATH"
echo
echo "To run it:"
echo "  sudo $SCRIPT_PATH"
echo
echo "Remember:"
echo "  Running it once turns the test tone on."
echo "  Running it again turns the test tone off."
echo
echo "Your rpt.conf should contain something like:"
echo "  904 = cop,4"
echo
