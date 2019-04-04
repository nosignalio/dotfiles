#!/bin/bash

set -o errexit

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[1;33m"
NC="\033[0m"

function preferences () {
    echo -e "${YELLOW}Setting up preferences...${NC}"
    echo

    echo -n "Please provide your sudo "
    sudo ls > /dev/null 2>&1        # There's gotta be a better way, right?

    echo -n "Setting finder to list view: "
    defaults write com.apple.Finder FXPreferredViewStyle Nlsv
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
    fi

    echo -n "Enabling firewall: "
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 2
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
    fi

    echo -n "Checking filevault status: "
    FVSTATUS="$(fdesetup status)"
    if [[ $FVSTATUS != "FileVault is On." ]]; then
        sudo fdesetup enable
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}Filevault enabled! [OK]${NC}"
        else
            echo -e "${RED}Errors enabling Filevault. [FAILED]${NC}"
        fi
    else
        echo -e "${GREEN}Filevault enabled! [OK]"
    fi
}

function installer () {
    echo
    echo -e "${YELLOW}Installing software...${NC}"
    
    echo
    brew bundle
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}All brews and casks successfully installed. [OK]${NC}"
    else
        echo -e "${RED}Errors found while installing from Brewfile. Should have died at point of error. [FAILED]${NC}"
    fi
}

function sshkeys () {
    echo
    echo -e "${YELLOW}Getting SSH keys and settings permissions...${NC}"

    echo -n "Creating SSH directory: "
    if [[ -d ~/.ssh ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        mkdir ~/.ssh
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}[OK]${NC}"
        else
            echo -e "${RED}Error creating SSH directory. [FAILED]"
            exit 1
        fi
    fi

    echo -n "Copying keys and config from backup: "
    cp ~/Documents/Backups/SSH/* ~/.ssh/
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
    fi

    echo -n "Setting directory permissions: "
    chmod 0700 ~/.ssh
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
    fi

    echo -n "Setting file permissions: "
    find ~/.ssh/ -type f -exec chmod 600 {} \;
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
    fi
}

preferences
installer
sshkeys