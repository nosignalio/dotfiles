#!/bin/bash

set -o errexit

GREEN="\033[32m"
RED="\033[31m"
YELLOW="\033[1;33m"
NC="\033[0m"

##############################################################################
# Stuff
##############################################################################
GODEPS=(
    github.com/ramya-rao-a/go-outline
    github.com/acroca/go-symbols
    github.com/mdempsky/gocode
    github.com/rogpeppe/godef
    golang.org/x/tools/cmd/godoc
    github.com/zmb3/gogetdoc
    golang.org/x/lint/golint
    github.com/fatih/gomodifytags
    golang.org/x/tools/cmd/gorename
    sourcegraph.com/sqs/goreturns
    golang.org/x/tools/cmd/goimports
    github.com/cweill/gotests/...
    golang.org/x/tools/cmd/guru
    github.com/josharian/impl
    github.com/haya14busa/goplay/cmd/goplay
    github.com/uudashr/gopkgs/cmd/gopkgs
    github.com/davidrjenni/reftools/cmd/fillstruct
    github.com/alecthomas/gometalinter
    github.com/kisielk/errcheck
    gitlab.com/opennota/check/cmd/aligncheck
    gitlab.com/opennota/check/cmd/structcheck
    gitlab.com/opennota/check/cmd/varcheck
    github.com/gordonklaus/ineffassign
    github.com/mdempsky/maligned
    github.com/tsenart/deadcode
    github.com/spf13/cobra/cobra
    github.com/spf13/viper
    github.com/gorilla/mux
    github.com/gorilla/websocket
    github.com/gin-gonic/gin
)

function pause () {
    read -p "$*"
}

##############################################################################
# Functions
##############################################################################

function preferences () {
    echo -e "${YELLOW}Setting up preferences...${NC}"
    echo

    echo -n "Invalidating cached sudo credentials: "
    sudo -k
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
    fi
    
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
    echo -e "${YELLOW}Homebrew setup...${NC}"

    echo
    echo -n "Checking Homebrew installation: "
    which brew > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
        echo -n "Installing Homebrew: "
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}[OK]${NC}"
        else
            echo -e "${RED}[FAILED]${NC}"
        fi
    fi

    echo
    echo -e "${YELLOW}OhMyZSH setup...${NC}"

    echo
    echo -n "Checking OhMyZSH installation: "
    if [[ -d ~/.oh-my-zsh ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
        echo -n "Installing OhMyZSH: "
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}[OK]${NC}"
        else
            echo -e "${RED}[FAILED]${NC}"
        fi
    fi

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

    echo
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

function actualdotfiles () {
    echo
    echo -e "${YELLOW}Copying in dotfiles...${NC}"

    echo
    echo -n "Copying dotfiles: "
    cp ~/Documents/Backups/Dotfiles/zshrc ~/.zshrc > /dev/null 2>&1
    cp ~/Documents/Backups/Dotfiles/gitconfig ~/.gitconfig > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
    fi

    # Well this was a fucking stupid idea...
    # echo -n "Sourcing .zshrc: "
    # source ~/.zshrc
    # if [[ $? -eq 0 ]]; then
    #     echo -e "${GREEN}[OK]${NC}"
    # else
    #     echo -e "${RED}[FAILED]${NC}"
    # fi
}

function pythonista () {
    echo
    echo -e "${YELLOW}Installing Python and prepping virtualenv...${NC}"

    echo
    echo -n "Checking CCPFLAGS environment variable: "
    if [[ -z "${CPPFLAGS}" ]]; then
        echo -e "${RED}[FAILED]${NC}"
        echo -n "Creating environment variables: "
        export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/sqlite/lib"
        export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/sqlite/include"
        export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"
        export PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/local/opt/sqlite/lib/pkgconfig"
        if [[ -z "${CPPFLAGS}" && -z "${LDFLAGS}" && -z "${PKG_CONFIG_PATH}" ]]; then
            echo -e "${GREEN}[OK]${NC}"
        else
            echo -e "${RED}[FAILED]${NC}"
        fi
    else
        echo -e "${GREEN}[OK]${NC}"
    fi

    echo -n "Checking installed Python 3: "
    which python3 > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
        echo -n "Installing Python 3: "
        pyenv install 3.7.3
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}[OK]${NC}"
        else
            echo -e "${RED}[FAILED]${NC}"
        fi
    fi

    echo -n "Checking virtualenvs: "
    pyenv virtualenvs --skip-aliases > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
        echo -n "Creating virtualenv: "
        pyenv virtualenv 3.7.3 py37
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}[OK]${NC}"
        else
            echo -e "${RED}[FAILED]${NC}"
        fi
    fi
}

function goforbroke () {
    echo
    echo -e "${YELLOW}Installing Go packages and modules...${NC}"

    echo
    echo -n "Setting PATH to include GOPATH: "
    export PATH=$PATH:$(go env GOPATH)/bin
    if [[ -z "${PATH}" ]]; then
        echo -e "${RED}[FAILED]${NC}"
    else
        echo -e "${GREEN}[OK]${NC}"
    fi

    echo -n "Setting GOPATH: "
    export GOPATH=$(go env GOPATH)
    if [[ -z "${GOPATH}" ]]; then
        echo -e "${RED}[FAILED]${NC}"
    else
        echo -e "${GREEN}[OK]${NC}"
    fi

    export GOPATH=$PATH:~/go
    for dep in ${GODEPS[@]}; do
        echo -n "Installing $dep: "
        go get -u $dep > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}[OK]${NC}"
        else
            echo -e "${RED}[FAILED]${NC}"
        fi
    done

    echo -n "Running gometalinter installer: "
    ~/go/bin/gometalinter --install > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
    fi
}

function iterm2 () {
    echo
    echo -e "${YELLOW}Pulling in iTerm2 assets...${NC}"

    echo
    echo -n "Downloading PowerLine patched font set: "
    if [[ -d ~/Downloads/fonts ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        pushd ~/Downloads > /dev/null 2>&1
        git clone git@github.com:powerline/fonts.git > /dev/null 2>&1
        if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
        else
            echo -e "${RED}[FAILED]${NC}"
        fi
    fi
    popd > /dev/null 2>&1

    echo -n "Installing PowerLine patched font set: "
    pushd ~/Downloads/fonts > /dev/null 2>&1
    ./install.sh > /dev/null 2>&1
    if [[ $? -eq 0 ]]; then
        echo -e "${GREEN}[OK]${NC}"
    else
        echo -e "${RED}[FAILED]${NC}"
    fi
    popd > /dev/null 2>&1

    echo -n "Import DimmedMonokai theme from backups: "
    echo -e "${GREEN}[OK]${NC}"

    echo -n "Set font to 14pt Melso LG L DZ Regular for PowerLine"
    echo -e "${GREEN}[OK]${NC}"

}

##############################################################################
# Runtime
##############################################################################

preferences
installer
sshkeys
actualdotfiles
pythonista
goforbroke
iterm2

##############################################################################
# The long goodbye
##############################################################################
echo
echo -e "${YELLOW}We're done. Should you add anything else, don't forget to update me. Thanks.${NC}"