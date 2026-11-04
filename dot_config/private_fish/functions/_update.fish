function _update
    sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean
    brew update && brew upgrade -y && brew cleanup --prune=all
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    ya pkg upgrade
    fisher update

    # fnm (Node.js version manager)
    set -l fnm_config "$HOME/.node-versions"
    if test -f "$fnm_config"
        set_color --bold cyan; echo "==> [fnm] Updating Node.js versions from ~/.node-versions..."; set_color normal
        set -l fnm_dir "$HOME/.local/share/fnm"
        if test -n "$FNM_DIR"
            set fnm_dir "$FNM_DIR"
        end

        set -l keep_versions
        set -l default_version
        set -l fallback_default

        for raw_line in (command cat "$fnm_config")
            set -l clean_line (string replace -r "#.*" "" -- "$raw_line" | string trim)
            if test -z "$clean_line"
                continue
            end

            set -l is_default 0
            if string match -rq "\bdefault\b" -- "$clean_line"
                set is_default 1
                set clean_line (string replace -r "\bdefault\b" "" -- "$clean_line" | string trim)
            end

            set -l target_label "$clean_line"
            test $is_default -eq 1; and set target_label "$target_label (default)"
            set_color blue; echo "  -> Resolving $target_label..."; set_color normal

            set -l installed_ver
            set -l install_output
            switch "$clean_line"
                case "lts-latest" "lts"
                    set install_output (fnm install --lts 2>&1)
                    set -l match (string match -r "Installing Node (v\S+)" -- $install_output)
                    if test (count $match) -ge 2
                        set installed_ver $match[2]
                        fnm alias $installed_ver lts-latest >/dev/null 2>&1
                    end
                case "latest"
                    set install_output (fnm install --latest 2>&1)
                    set -l match (string match -r "Installing Node (v\S+)" -- $install_output)
                    if test (count $match) -ge 2
                        set installed_ver $match[2]
                        fnm alias $installed_ver latest >/dev/null 2>&1
                    end
                case "*"
                    set install_output (fnm install $clean_line 2>&1)
                    set -l match (string match -r "Installing Node (v\S+)" -- $install_output)
                    if test (count $match) -ge 2
                        set installed_ver $match[2]
                    end
            end

            if test -n "$installed_ver"
                set -a keep_versions $installed_ver
                if string match -q "*Version already installed*" -- "$install_output"
                    set_color green; echo "     $installed_ver is already up to date"; set_color normal
                else
                    set_color --bold green; echo "     Installed/Updated $installed_ver"; set_color normal
                end

                if test $is_default -eq 1
                    set default_version $installed_ver
                end
                if test "$clean_line" = "lts-latest" -o "$clean_line" = "lts"
                    if test -z "$fallback_default"
                        set fallback_default $installed_ver
                    end
                end
            else
                set_color red; echo "     Failed to install: $clean_line"; set_color normal
            end
        end

        if test (count $keep_versions) -gt 0
            set -l installed_versions (command ls -1 "$fnm_dir/node-versions" 2>/dev/null | command grep -v "^\.")
            for ver in $installed_versions
                if not contains -- $ver $keep_versions
                    set_color yellow; echo "  -> Removing old Node version: $ver..."; set_color normal
                    fnm uninstall $ver >/dev/null 2>&1
                end
            end
        end

        if test -z "$default_version"
            if test -n "$fallback_default"
                set default_version $fallback_default
            else if test (count $keep_versions) -gt 0
                set default_version $keep_versions[1]
            end
        end

        if test -n "$default_version"
            fnm default $default_version >/dev/null 2>&1
            fnm use default >/dev/null 2>&1
            set_color magenta; echo "  -> Default Node set to $default_version"; set_color normal
        end
        set_color --bold cyan; echo "==> [fnm] Done. Current active version: "(node -v); set_color normal
    end

    npm update -g
    # bun update -g
    bun ~/.config/scripts/update-bun-global.mjs

    # Clean caches
    npm cache clean --force
    bun pm cache rm -g
    pnpm store prune

    # Reclaim unused disk space to Windows host
    sudo fstrim -v /
end
