alias p="ps -ef | grep -v 'grep' | grep -i "
alias ll="ls -l"
alias lr="ls -lart"
alias ch="./configure --help | less"
alias cls="clear"
alias "cd.."="cd .."
alias hh="history | grep -i "
alias cg="curl -v google.com"
alias gs="git status"
alias gp="git push"
# sort - from here:
# http://serverfault.com/questions/62411/how-can-i-sort-du-h-output-by-size
# Linux would use:
# alias duh="du -hs * | sort -h"
# for Mac:
# brew install coreutils
# alias duh="du -hs * | gsort -h"
# alias duh="du -hs * | sort -h"
# alias duh='du -hs .[^.]* | gsort -h'
alias duh='du -hs .[^.]* *| sort -h'
alias hh="history | grep -i "
alias dm="dmesg -T"
# alias q="cd $HOME/src/github/macOS-Simple-KVM"
alias q="cd $HOME/src/github/OSX-KVM"
alias qq="cd $HOME/src/OSX/OSX-KVM"
alias pp="rm $HOME/.config/pulse/*;pulseaudio -k;sudo alsa force-reload;sudo killall pulseaudio"
alias sss='cd ~/src'
alias ho="export PROMPT_COMMAND='${PROMPT_COMMAND}${PROMPT_COMMAND:+;}history -a; history -n'"
alias hf="export PROMPT_COMMAND='setLastCommandState'"

