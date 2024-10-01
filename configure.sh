#!/bin/sh

check_OS() {
    OS=$(uname)
    if [ "$OS" = "Linux" ]; then
        DISTRO=$(grep '^NAME=' /etc/os-release | cut -d '=' -f 2 | tr -d '"')
    elif [ "$OS" = "Darwin" ]; then
        DISTRO="macOS" 
    else
        echo "Only Linux and macOS operating systems are allowed."
        return 1
    fi
}

update() {
    echo "Updating package manager..."
    case "$DISTRO" in
        "Ubuntu"|"Debian")
            sudo apt-get update
            ;;
        "Fedora")
            sudo dnf check-update
            ;; 
        "macOS")
            brew update
            ;; 
        *)
            echo "Unsupported distribution for package manager update."
            return 1
            ;;
    esac
}

check_deps() {
    dev_deps=""
    docker_deps=""
    prod_deps=""
    case "$1" in
        "dev")
            if ! command -v curl > /dev/null; then
                dev_deps="install_curl"
            fi
            if ! command -v gcc > /dev/null || ! command -v make > /dev/null; then
                dev_deps="$dev_deps install_gcc"
            fi
            if ! command -v g++ > /dev/null; then
                dev_deps="$dev_deps install_gpp"
            fi
            if ! command -v python3 > /dev/null; then
                dev_deps="$dev_deps install_python"
            fi
            if [ -z "$NVM_DIR" ]; then
                dev_deps="$dev_deps install_nvm install_node"
            fi
            ;;

        "docker")
            if ! command -v grep > /dev/null; then
                docker_deps="install_grep"
            fi
            if ! command -v docker > /dev/null; then
                docker_deps="$docker_deps install_docker"
            fi
            ;;

        "prod")
            if ! command -v grep > /dev/null; then
                prod_deps="install_grep"
            fi
            if ! command -v minikube > /dev/null; then
                prod_deps="$prod_deps install_minikube"
            fi
            if ! command -v kubectl > /dev/null; then
                prod_deps="$prod_deps install_kubectl"
            fi
            ;;

        *)
            echo "Invalid argument for check_deps"
            return 1
            ;;
    esac
}

install_curl() {
    echo "Installing curl..."
    case "$DISTRO" in
        "Ubuntu"|"Debian")
            sudo apt-get install -y curl
            ;;
        "Fedora")
            sudo dnf install -y curl
            ;; 
        "macOS")
            brew install curl
            ;; 
        *)
            echo "Unsupported distribution for curl installation."
            return 1
            ;;
    esac
}

install_gcc() {
    echo "Installing gcc and make..."
    case "$DISTRO" in
        "Ubuntu"|"Debian")
            sudo apt-get install -y build-essential
            ;;
        "Fedora")
            sudo dnf groupinstall -y "Development Tools"
            ;; 
        "macOS")
            xcode-select --install
            ;; 
        *)
            echo "Unsupported distribution for GCC installation."
            return 1
            ;;
    esac
}

install_gpp() {
    echo "Installing g++..."
    case "$DISTRO" in
        "Ubuntu"|"Debian")
            sudo apt-get install -y g++
            ;;
        "Fedora")
            sudo dnf install -y gcc-c++
            ;; 
        "macOS")
            xcode-select --install
            ;; 
        *)
            echo "Unsupported distribution for g++ installation."
            return 1
            ;;
    esac
}

install_python() {
    echo "Installing python 3..."
    case "$DISTRO" in
        "Ubuntu"|"Debian")
            sudo apt-get install -y python3
            ;;
        "Fedora")
            sudo dnf install -y python3
            ;; 
        "macOS")
            brew install python3
            ;;
        *)
            echo "Unsupported distribution for Python installation."
            return 1
            ;;
    esac
}

install_nvm() {
    echo "Installing nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    . "$HOME/.nvm/nvm.sh"
}

install_node(){
    echo "Installing the node's lts version..."
    nvm install --lts
    nvm alias default node
}

install_grep() {
    echo "Installing grep..."
    case "$DISTRO" in
        "Ubuntu"|"Debian")
            sudo apt-get install -y grep
            ;;
        "Fedora")
            sudo dnf install -y grep
            ;;
        "macOS")
            brew install grep
            ;;
        *)
            echo "Unsupported distribution for Python installation."
            return 1
            ;;
    esac
}

install_docker() {
    echo "Installing docker..."
    case "$DISTRO" in
        "Ubuntu"|"Debian"|"Fedora")
            curl -fsSL https://get.docker.com -o get-docker.sh
            sh get-docker.sh
            ;; 
        "macOS")
            brew install --cask docker
            ;; 
        *)
            echo "Unsupported distribution for Docker installation."
            return 1
            ;;
    esac
}

install_minikube() {
    echo "Installing minikube..."
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) MINIKUBE_ARCH="amd64" ;;
        aarch64) MINIKUBE_ARCH="arm64" ;;
        arm*) MINIKUBE_ARCH="arm" ;;
        *)
            echo "Unsupported architecture: $ARCH"
            return 1
            ;;
    esac
    curl -LO "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-${MINIKUBE_ARCH}"
    sudo install "minikube-linux-${MINIKUBE_ARCH}" /usr/local/bin/minikube
    rm "minikube-linux-${MINIKUBE_ARCH}"
}

install_kubectl() {
    echo "Installing kubectl..."
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64) KUBECTL_ARCH="amd64" ;;
        aarch64) KUBECTL_ARCH="arm64" ;;
        arm*) KUBECTL_ARCH="arm" ;;
        *)
            echo "Unsupported architecture: $ARCH"
            return 1
            ;;
    esac
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/${KUBECTL_ARCH}/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
}

install_deps() {
    if [ "$1" = "dev" ]; then
        check_deps dev
        if [ -z "$dev_deps" ]; then
            echo "info: All dev dependencies are already installed."
            return 2
        else
            update
            if [ $? -ne 0 ]; then
                echo "error: Could not update the system."
                return 1
            fi
            for dep in $dev_deps; do
                $dep
            done
        fi
    elif [ "$1" = "docker" ]; then
        check_deps docker
        if [ -z "$docker_deps" ]; then
            echo "info: All docker dependencies are already installed."
            return 2
        else
            for dep in $docker_deps; do
                $de
            done
        fi
    elif [ "$1" = "prod" ]; then
        check_deps prod
        if [ -z "$prod_deps" ]; then
            echo "info: All prod dependencies are already installed."
            return 2
        else
            for dep in $prod_deps; do
                $dep 
            done
        fi
    else
        echo "error: Option not defined for install_deps."
        return 1
    fi
}

fix_path() {
    has_local_bin=$(echo $PATH | grep "/usr/local/bin")
    if [ -z "$has_local_bin" ]; then
        echo "info: Fixing the PATH..."
        echo "export PATH=$PATH:/usr/local/bin" >> $HOME/.profile
        source $HOME/.profile > /dev/null 2>&1
        if [ $? -eq 1 ]; then
            echo "error: Some problem while sourcing $HOME/.profile."
            return 1
        fi
    fi
}

help() {
    echo "Usage: $0 [option]
Options:
    dev ............... manage deps for dev mode
    docker ............ manage deps for docker mode
    prod .............. manage deps for dev mode
    [none] ............ manage all deps
"
}

main() {
    check_OS
    if [ $? -eq 1 ]; then
        return 1
    fi
    if [  -z "$1" ]; then
        install_deps dev
        if [ $? -eq 1 ]; then
            return 1
        fi
        install_deps docker
        if [ $? -eq 1 ]; then
            return 1
        fi
        install_deps prod
        if [ $? -eq 1 ]; then
            return 1
        fi
        echo "info: Checking the PATH..."
        fix_path
        if [ $? -eq 1 ]; then
            return 1
        fi
        echo "done: The dependencies have been and installed and configured."
    elif [ "$1" = "dev" ]; then
        install_deps dev
        if [ ! $? -eq 0 ]; then
            return $?
        fi
        echo "done: The dev dependencies have been and installed and configured."
    elif [ "$1" = "docker" ]; then
        install_deps docker
        if [ $? -eq 1 ]; then
            return 1
        fi
        echo "info: Checking the PATH..."
        fix_path
        if [ $? -eq 1 ]; then
            return 1
        fi
        echo "done: The docker dependencies have been and installed and configured."
    elif [ "$1" = "prod" ]; then
        core prod
        if [ $? -eq 1 ]; then
            return 1
        fi
        echo "info: Fixing the PATH..."
        fix_path
        if [ $? -eq 1 ]; then
            return 1
        fi
        echo "done: The prod dependencies have been and installed and configured."
    elif [ "$1" = "help" ] || [ "$1" = "--help" ]; then
        help 
    else
        help
    fi
}

main "$@"
if [ $? -eq 1 ]; then
    exit 1
fi
