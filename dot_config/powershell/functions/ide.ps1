function ide
{
  psmux split-window -h -l 30%
  psmux select-pane -L
  psmux split-window -v -l 30%
  psmux split-window -h -l 50%
  psmux select-pane -U
  # wt -w 0 split-pane -V -s .3 -d $PWD -p $Env:WT_PROFILE_ID
  # wt -w 0 move-focus previous
  # wt -w 0 split-pane -H -s .3 -d $PWD -p $Env:WT_PROFILE_ID
  # wt -w 0 split-pane -V -s .5 -d $PWD -p $Env:WT_PROFILE_ID
  # wt -w 0 move-focus up
}
