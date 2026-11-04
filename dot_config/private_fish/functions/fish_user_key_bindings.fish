function fish_user_key_bindings
    # fzf
    bind \cf fzf_change_directory

    # vim-like
    bind \cl forward-char

    # prevent iterm2 from closing when typing Ctrl-D (EOF)
    bind \cd delete-char

    # block tab completion when no input
    bind \t '
        if test -z (commandline -b | string trim)
            commandline -f repaint
        else
            commandline -f complete
        end
    '

    # close the current tab
    bind \cd exit
end

# fzf plugin
fzf_configure_bindings --directory=\co
