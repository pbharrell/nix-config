{ pkgs }:

with pkgs; [
  # General packages for development and system management
  bat
  coreutils
  neofetch
  openssh
  pandoc
  sqlite
  wget
  zip

  # Encryption and security tools

  # Cloud-related tools and SDKs
  docker
  docker-compose

  # Media-related packages
  ffmpeg

  # Node.js development tools
  nodePackages.npm # globally install npm
  nodejs

  # Text and terminal utilities
  jq
  ripgrep
  tmux
  unzip
  neovim
  nb
  lazygit

  # C and C++
  gcc

  # Python packages
  python3
  virtualenv

  # Go packages
  go
]
