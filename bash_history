# history settings i use in .bashrc etc etc 
export SHELL_SESSION_HISTORY=0
export HISTFILE="$HOME/.bash_history"
export HISTTIMEFORMAT="%d/%m/%y %T "
export HISTIGNORE="pwd:ls:ll:ls -l:ls -ltr:hh:"
export PROMPT_COMMAND="${PROMPT_COMMAND}${PROMPT_COMMAND:+;}history -a; history -n"
