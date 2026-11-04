function ide
    tmux split-window -h -l 30%
    tmux select-pane -L
    tmux split-window -v -l 30%
    tmux split-window -h -l 50%
    tmux select-pane -U
    # wt.exe -w 0 split-pane -V -s .3 -d $PWD -p $WT_PROFILE_ID
    # wt.exe -w 0 move-focus previous
    # wt.exe -w 0 split-pane -H -s .3 -d $PWD -p $WT_PROFILE_ID
    # wt.exe -w 0 split-pane -V -s .5 -d $PWD -p $WT_PROFILE_ID
    # wt.exe -w 0 move-focus up
end
