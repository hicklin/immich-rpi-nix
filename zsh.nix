{ config, pkgs, ... }:

{
    environment.systemPackages = [
        pkgs.zsh
    ];

    environment.shells = [ pkgs.zsh ];

    # Enable zsh and the oh-my-zsh module
    programs.zsh = {
        enable = true;
        autosuggestions.enable = true;
        autosuggestions.highlightStyle = "fg=cyan";

        histSize = 1000;

        # Using the dedicated 'shellAliases' option.
        shellAliases = {
            switch = "sudo nixos-rebuild switch";

            ll = "ls -l";
            la = "ls -la";

            mv="mv -iv";
            cp="cp -iv";
            rm="rm -iv";
            df="df -h";
            du="du -h";
            mkdir="mkdir -p";

            k9="kill -9";
        };
    };

    users.defaultUserShell = pkgs.zsh;
}
