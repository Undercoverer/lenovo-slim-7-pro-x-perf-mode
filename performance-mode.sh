#!/bin/bash

# Define ACPI calls for each mode
declare -A MODES=( ["ic"]="0x000FB001" ["ep"]="0x0012B001" ["bs"]="0x0013B001" )

# Check if valid mode is provided
if [[ -z $1 || -z ${MODES[$1]} ]]; then
    echo "Invalid mode. Please choose between 'ic' (Intelligent Cooling), 'ep' (Extreme Performance), or 'bs' (Battery Saving)."
    exit 1
fi

# Check if acpi_call is installed and load it
CMD="if ! modprobe acpi_call > /dev/null 2>&1; then echo 'acpi_call module not found. Installing acpi-call-dkms...'; apt-get install -y acpi-call-dkms; modprobe acpi_call; fi"

# Add the command to set the mode and verify the setting
CMD+=" && echo '\_SB.PCI0.LPC0.EC0.VPC0.DYTC ${MODES[$1]}' > /proc/acpi/call && echo '\_SB.PCI0.LPC0.EC0.SPMO' > /proc/acpi/call && cat /proc/acpi/call"

# Run the command with pkexec
OUTPUT=$(command_line="performance-mode" pkexec bash -c "$CMD" | tr -d '\0')

# Handle the output from cat /proc/acpi/call
RESULT=$(echo "$OUTPUT" | tail -n 1)
if [ "$RESULT" == "0x0" ]; then
    echo "Mode set to Intelligent Cooling"
elif [ "$RESULT" == "0x1" ]; then
    echo "Mode set to Extreme Performance"
elif [ "$RESULT" == "0x2" ]; then
    echo "Mode set to Battery Saving"
else
    echo "Error in setting mode."
    exit 1
fi

