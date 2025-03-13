{ config, pkgs, lib, ... }:

let name = "pbharrell";
    user = "prestonharrell";
    email = "backstroker2001@gmail.com"; in
{
  # Shared shell configuration
  zsh = {
    enable = true;
    autocd = false;
    plugins = [
    ];

    initExtraFirst = ''
      if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        . /nix/var/nix/profiles/default/etc/profile.d/nix.sh
      fi

      export PS1="%B%F{72}% %d%b %F{grey}%1 %# "
      export PATH="$PATH:$HOME/.local/bin"
      export PATH="$PATH:$HOME/.scripts"
      export PATH="$HOME/Library/Android/sdk/ndk/27.0.12077973/toolchains/llvm/prebuilt/darwin-x86_64/bin:$PATH"

      alias vim="nvim"

      export ANDROID_NDK_ROOT="$HOME/Library/Android/sdk/ndk/27.0.12077973"

      export BROWSER='/Applications/Firefox.app/Contents/MacOS/firefox'
      alias dr="darwin-rebuild switch --flake ~/nix"
      alias nr="prev=$cwd && cd ~/nixos-config && nix run .#build-switch && cd $prev"
      alias ne="nvim ~/nixos-config"

      export CLICOLOR=1
      export TERM=xterm-256color 

      export NIX_CONFIG="experimental-features = nix-command flakes"


      # Neovim is my editor
      export EDITOR="nvim"

      # nix shortcuts
      shell() {
          nix-shell '<nixpkgs>' -A "$1"
      }

      # Always color ls and group directories
      alias ls='ls --color=auto'
    '';
  };

  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
	    editor = "nvim";
        autocrlf = "input";
      };
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  vim = {
    enable = true;
    settings = { ignorecase = true; };
    extraConfig = ''
      '';
     };

  ssh = {
    enable = true;
    includes = [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        "/home/${user}/.ssh/config_external"
      )
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        "/Users/${user}/.ssh/config_external"
      )
    ];
  };

  tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      prefix-highlight
    ];
    terminal = "xterm-256color";
    prefix = "C-Space";
    historyLimit = 20000;
    extraConfig = ''
      set-option -g prefix C-Space
      unbind C-Space
      bind C-Space send-prefix
      set-window-option -g mode-keys vi

      set -g mouse on
      set-option -g history-limit 5000
      set -g default-terminal "xterm-256color"
      set-option -sa terminal-overrides ",xterm-256color:Tc"
      set-option -g default-terminal "tmux-256color"
      set-option -ga terminal-features ",xterm-256color:usstyle"
      set-option -g xterm-keys on
      set-option -g status-position top

      # THEME
      set -g status-bg black
      # need to override the bg color to account for ghostty color scheme weirdness
      if-shell "uname | grep -q Darwin" "set -g status-bg '#333333'"
      set -g status-fg red
      set -g status-interval 60
      set -g status-left-length 30
      set -g status-right '#[fg=yellow]#(cut -d " " -f 1-3 /proc/loadavg)#[default] #[fg=green]%H:%M#[default]'

      bind \` switch-client -t'{marked}'
 
      set -g renumber-windows on
      set-option -g set-titles on

      bind | split-window -hc "#{pane_current_path}"
      bind-key "\\" split-window -fh -c "#{pane_current_path}"
      bind - split-window -vc "#{pane_current_path}"
      bind-key "_" split-window -fv -c "#{pane_current_path}"

      bind -r "<" swap-window -d -t -1
      bind -r ">" swap-window -d -t +1

      bind c new-window -c "#{pane_current_path}"

      bind Space last-window

      bind-key C-Space switch-client -l

      bind -r C-j resize-pane -D 15
      bind -r C-k resize-pane -U 15
      bind -r C-h resize-pane -L 15
      bind -r C-l resize-pane -R 15

      # Vim style pane selection
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # Floating window bindings
      # bind g display-popup -d "#{pane_current_path}" -xC -yC -w92% -h92% -E "lazygit"

      bind g run-shell '
        if [ "$(tmux display-message -p -F "#{session_name}")" = "popup" ];then 
          return
        elif [ "$(tmux display-message -p -F "#{session_name}")" = "lazygit" ];then
          tmux switch -l
        else
          tmux switch -t lazygit || (tmux new -d -s lazygit -c "#{pane_current_path}" "tmux set-option status off; lazygit" && tmux switch -t lazygit)
          tmux set-option -t lazygit detach-on-destroy off
        fi
      '

      bind -n C-\\ run-shell '
        session_name="$(tmux display-message -p -F "#{session_name}")"
        if [ "$session_name" = "popup" ]; then
          tmux detach-client
        elif [ "$session_name" = "lazygit" ]; then
          tmux switch-client -l
        else
          tmux popup -d "#{pane_current_path}" -xC -yC -w92% -h92% -E "tmux attach -t popup || tmux new -s popup"
        fi
      '

      set -sg escape-time 0

      # Reload tmux config
      bind r source-file ~/.tmux.conf

      # Binding to open tmux in command line editor (vim/nvim)
      bind-key v run-shell '
        file=$(mktemp).sh
        tmux capture-pane -pS -32768 > "$file"
        tmux new-window "$EDITOR \"+ normal G \$\" \"$file\""
      '
      '';
    };
}
