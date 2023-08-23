{ config, pkgs, ... }:

let
    username = "balder";
    theme = (import ./themes.nix { builtins = builtins; } ).lake;
in
rec {
    home.homeDirectory = "/home/${username}";
    home.username = username;

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    home.stateVersion = "23.05"; # Please read the comment before changing.

    # The home.packages option allows you to install Nix packages into your
    # environment.
    home.packages = with pkgs; [
        # # It is sometimes useful to fine-tune packages, for example, by applying
        # # overrides. You can do that directly here, just don't forget the
        # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
        # # fonts?
        # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

        # # You can also create simple shell scripts directly inside your
        # # configuration. For example, this adds a command 'my-hello' to your
        # # environment:
        # (pkgs.writeShellScriptBin "my-hello" ''
        #     echo "Hello, ${config.home.username}!"
        # '')
        neofetch
    ];

    # Config files
    home.file = {

    # Powerlevel10k zsh prompt
    ".p10k.zsh".source = ./configs/p10k.zsh;

    # Rofi config
    ".config/rofi/config.rasi".source = ./configs/rofi.rasi;
    ".config/rofi/theme.rasi".text = ''
        * {
            bg: ${theme.background}80;
            bg-alt: ${theme.background};
            fg: ${theme.foreground};
            fg-alt: ${theme.primary};
        }
    '';

    # Waybar config
    ".config/waybar/config".source = ./configs/waybar/config;
    ".config/waybar/style.css".text = ''
        @define-color background ${theme.background};
        @define-color foreground ${theme.foreground};
        @define-color primary ${theme.primary};
        @define-color secondary ${theme.secondary};
        @define-color alert ${theme.alert};
        @define-color disabled ${theme.disabled};
        '' + builtins.readFile ./configs/waybar/style.css;

    # Hyprland config
    ".config/hypr/hyprland.conf".source = ./configs/hyprland.conf;

    ".config/hypr/hyprpaper.conf".text = ''
    preload = ${theme.wallpaper}
    wallpaper = eDP-1, ${theme.wallpaper}
    '';

    ".config/zathura/zathurarc".text = ''
        set statusbar-h-padding 0
        set statusbar-v-padding 0
        set page-padding 1
        map d scroll half-down
        map u scroll half-up
        map R rotate
        map J zoom in
        map K zoom out
        map i recolor
        map p print
        set selection-clipboard clipboard
    '';

    # Kitty config
    ".config/kitty/kitty.conf".source = ./configs/kitty.conf;

    # Utility scripts
    ".myutils".source = ./utils;

    };

    programs.git = {
        enable = true;
        userName = "BalderHolst";
        userEmail = "balderwh@gmail.com";
        aliases = {
            l = "log --oneline --graph";
        };
        diff-so-fancy.enable = true;
        extraConfig = {
            init.defaultBranch = "main";
            pull.rebase = true;
        };
    };

    programs.zsh = {
        enable = true;
        localVariables = {
            POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true;
        };
        shellAliases = {

            ll = "exa -l";
            ls = "exa";
            r = "ranger";
            t = "kitty --detach";

            # Git
            gs = "git status";
            gc = "git commit";
            gp = "git push";
            gaa = "git add .";
            gca = "git add . && git commit";

            hdmi-dublicate = "xrandr --output DisplayPort-0 --auto --same-as eDP";
        };
        history = {
            size = 10000;
            path = "${config.xdg.dataHome}/zsh/history";
        };

        # zsh plugins
        zplug = {
            enable = true;
            plugins = [
                    { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
                    { name = "zsh-users/zsh-syntax-highlighting"; }
            ];
        };
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" "pass" ];
          theme = "robbyrussell";
        };

        initExtra = ''

        # Extra navigation aliases
        alias ..='cd ..'
        alias ...='cd ../..'

        # Source bookmarks file if it exists
        [ -f ~/.local/share/bmark/aliases.sh ] && source ~/.local/share/bmark/aliases.sh

        source ~/.p10k.zsh # Initialize powerlevel10k prompt

        # Add utils to PATH
        PATH="$PATH"":${home.homeDirectory}/.myutils"
        '';
    };

    gtk.iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus";
    };

    home.pointerCursor = {
        gtk.enable = true;
        x11.enable = true;
        name = "Bibata-Original-Classic";
        size = 18;
        package = pkgs.bibata-cursors;
    };

    gtk = {
        enable = true;
        font.name = "FiraCode Nerd Font";
        theme = {
            name = "Sierra-compact-dark";
            package = pkgs.sierra-gtk-theme;
        };
    };

    home.sessionVariables = {
        EDITOR = "nvim";
        PAGER = "bat";
        POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD = "true";
    };

    xdg.mimeApps.defaultApplications = {
        "text/plain" = [ "nvim" ];
        "application/pdf" = [ "zathura.desktop" ];
        "image/*" = [ "sxiv.desktop" ];
        "audio/*" = [ "mpv.desktop" ];
        "video/*" = [ "mpv.desktop" ];
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
}
