#!/bin/bash

# Install Helm.
#
# https://helm.sh/
# https://github.com/helm/helm
# 
# https://docs.helm.sh/using_helm/#installing-helm
# https://github.com/helm/helm/releases


# Get the latest Helm release version from github.
function hvm::latest() {
    curl -s "https://api.github.com/repos/helm/helm/releases/latest"    \
        | grep '"tag_name":'                                            \
        | sed -E 's/.*"([^"]+)".*/\1/'
}

# Get all Helm release version from github.
function hvm::releases() {
    curl -s "https://api.github.com/repos/helm/helm/releases"   \
        | grep '"tag_name":'                                    \
        | sed -E 's/.*"([^"]+)".*/\1/'
}

# Get all Helm release version from github.
function hvm::versions() {
    ls "${HELM_VERSIONS}"  | cut -d- -f2 | uniq
}

# Get the helm release architecture identifier for this system. 
function hvm::arch() {
    echo "amd64"
}

# Get the helm release OS identifier for this system. 
function hvm::os() {
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin" 
    else
        echo "Usupported OS: $OSTYPE"
        exit 1
    fi
}  

# Add a release version of Helm.
function hvm::add() {
    local version="${1:-${VERSION}}"
    local os="${2:-${OS}}"
    local arch="${3:-${ARCH}}"
    local binary="helm-${version}-${os}-${arch}.tar.gz"
    local expected_sha256=$(curl -s https://storage.googleapis.com/kubernetes-helm/${binary}.sha256)
    local helm_binary="helm-${version}"
    
    curl -O https://storage.googleapis.com/kubernetes-helm/"${binary}"
    local sha256=$(openssl sha256 "${binary}" | awk '{print $2}')
    if [[ "${sha256}" != "${expected_sha256}" ]]; then
        echo "${binary} hash mismatch: ${sha256}"
        exit 1
    fi
    tar xvf "${binary}" > /dev/null
    mv "${os}-${arch}/helm" "${HELM_VERSIONS}/${helm_binary}"
    mv "${binary}" "${HELM_VERSIONS}"
    rm -Rf "${os}-${arch}"

    if [ -z $(hvm::current) ]; then
        hvm::use "${version}"
    fi 
}

# Remove a release version of Helm.
function hvm::remove() {
    local version="${1:-${VERSION}}"
    if [ ! -z $(hvm::versions | grep "${version}") ]; then
        ls "${HELM_VERSIONS}" | grep "${version}" | xargs -I@ echo "${HELM_VERSIONS}/@" | xargs rm
    fi
}

# Switch to use the specified version of the Helm client. It must have been added first.
function hvm::use() {
    local version="${1:-${VERSION}}"
    if [ ! -f "${HELM_VERSIONS}/helm-${version}" ]; then
        echo "Version ${version} unavailable."
        echo "Please run: 'hvm add ${version}'"
        exit 0
    fi  
    cp "${HELM_VERSIONS}/helm-${version}" "${HELM_CURRENT}/helm"
    echo "${version}" > "${HELM_CURRENT_NFO}" 
    echo "Using: $(hvm::current)"
    # helm version -c
}

# Display the current Helm version being used.
function hvm::current() {
    if [ -f "${HELM_CURRENT_NFO}" ]; then
        cat "${HELM_CURRENT_NFO}" 
    fi
}

# Will set the specified version as the system wide client. Requires sudo.
function hvm::install-gobal() {
    local install_dir="/usr/local/bin/"
    sudo mkdir -p "$install_dir"
    sudo mv "${os}-${arch}/helm" "${install_dir}"
}

# Display the current HVM configuration.
function hvm::config() {
    echo "HVM_HOME     : ${HVM_HOME}"
    echo "HELM VERSION : ${VERSION}"
    echo "OS           : ${OS}"
    echo "ARCH         : ${ARCH}"
}

# Initialise required directories, paths, and aliases.
function hvm::init() {
    [ ! -d "${HVM_HOME}" ] && mkdir -p "${HVM_HOME}"
    [ ! -d "${HELM_VERSIONS}" ] && mkdir -p "${HELM_VERSIONS}"
    [ ! -d "${HELM_CURRENT}" ] && mkdir -p "${HELM_CURRENT}"
    [[ ":$PATH:" != *":${HELM_CURRENT}"* ]] && export PATH="${PATH}:${HELM_CURRENT}"
    alias hvm="${HVM_HOME}/hvm.sh"
}

# Clean up and delete HVM resources. 
function hvm::clean() {
    rm -Rf "${HVM_HOME}" 
    export PATH=$(echo $PATH | sed -e "s#:${HELM_CURRENT}##g")
}

# Display help to the user.
function hvm::help() {
    cat << EOF
usage: hvm <command> [version]

commands:
  add      [version] : Add the specified Helm version to HVM. If no version is 
                       specified, the 'latest' github version is used.
  remove   [version] : Remove the specified Helm version from HVM. If no 
                       version is specified, the 'current' NVM version is used.
  use       version  : Select and use an installed HVM Helm version. 
  current            : Display the current Helm version HVM is using.
  versions           : Displays all Helm versions that have been added to HVM.
  latest             : Displays the latest Helm version in the github releases.
  releases           : Displays all the Helm versions available in the github 
                       releases.
EOF
}

# Init ------------------------------------------------------------------------ 

HVM_HOME=${HVM_HOME:-${HOME}/.hvm}
HELM_VERSIONS=${HVM_HOME}/versions
HELM_CURRENT=${HVM_HOME}/current
HELM_CURRENT_NFO=${HELM_CURRENT}/.current

VERSION=${VERSION:-$(hvm::current)}
OS=${OS:-$(hvm::os)}
ARCH=${ARCH:-$(hvm::arch)}

hvm::init

# Main ------------------------------------------------------------------------

if [[ ! -z "$1" ]]; then
    hvm::$@
fi
