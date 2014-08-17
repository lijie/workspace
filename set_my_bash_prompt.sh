# Below are the color init strings for the basic file types. A color init
# string consists of one or more of the following numeric codes:
# Attribute codes:
# 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
# Text color codes:
# 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
# Background color codes:
# 40=black 41=red 42=green 43=yellow 44=blue 45=magenta 46=cyan 47=white

# ==================================================================
# some colors
none="\[\033[0m\]"
black="\[\033[0;30m\]"
dark_gray="\[\033[1;30m\]"
blue="\[\033[0;34m\]"
light_blue="\[\033[1;34m\]"
green="\[\033[0;32m\]"
light_green="\[\033[1;32m\]"
cyan="\[\033[0;36m\]"
light_cyan="\[\033[1;36m\]"
red="\[\033[0;31m\]"
light_red="\[\033[1;31m\]"
purple="\[\033[0;35m\]"
light_purple="\[\033[1;35m\]"
brown="\[\033[0;33m\]"
yellow="\[\033[1;33m\]"
light_gray="\[\033[0;37m\]"
white="\[\033[1;37m\]"


# display_clock()
# > display a clock in the upper-righthand corner
function display_clock {
    LIGHT_BLUE="$(tput setaf 4; tput bold)"
    DEFAULT="$(tput sgr0)"

    CLOCK="[$LIGHT_BLUE$(date +%H:%M:%S)$DEFAULT]"

    # <columns in display> - len($CLOCK)
    let UPPER_RIGHT=$(tput cols)-10

    tput sc
    tput cup 0 ${UPPER_RIGHT}
    echo -n ${CLOCK}
    tput rc
}

function set_hist_color {
    # $? - exit value of last command
    local ERR_in=$?
    ERR="[$ERR_in]"
    if [ $ERR_in -gt 0 ]
    then
	HIST_COLOR="1;31" # failure
    else
	HIST_COLOR="1;32" # success
	ERR=
    fi
}

# set TTY_COLOR to current (tty-number mod 8)+30
function set_tty_color {

    local rem color
    #let rem=`tty | sed -e 's/.*\/\(tty\)\?//'`%8
    let rem=0
    let color=rem+30
    TTY_COLOR="1;$color"
}


function set_user_color {
    local u_color_in
    let u_color_in=`id -u`%8+30
    USER_COLOR="1;${u_color_in}"
#purple="\[\033[0;35m\]"
    if [ `id -u` -eq 0 ] ; then
	USER_COLOR="1;31"
    fi
}

# ==================================================================

# prompt_command()
# > commands to run before each prompt display
function prompt_command {
    set_hist_color
    set_tty_color
    set_user_color
    #display_clock
        
        # for screen title setting
    echo -n -e "\033k\033\134"
}

function color_prompt
{
    PROMPT_COMMAND=prompt_command
    local current_tty=`tty | sed -e "s/\/dev\/\(.*\)/\1/"`

    PS1="$dark_gray> \033[\$(echo -n \$TTY_COLOR)m\]$current_tty \033[\$(echo -n \$USER_COLOR)m\]\u$dark_gray@$purple\H$dark_gray:$light_blue\w\n$dark_gray> $cyan\t \033[\$(echo -n \$HIST_COLOR)m\]\$ERR\033[\$(echo -n \$TTY_COLOR)m\]"'\$'"$none "

    PS2="$dark_gray>$none "
}


function dynamic_prompt {
    # Colour Macros
    BLUE='\[\033[0;34m\]'
    LIGHT_CYAN='\[\033[1;36m\]'
    WHITE='\[\033[1;37m\]'
    DEFAULT='\[\033[0m\]'

    # Pre-Prompt Function
    PROMPT_COMMAND=prompt_command

    # Prompt
    # \! - history number of last command
    # $? - exit value of last command
    # \t - exit time of last command
    # \w - current directory (relative)
    PS1="$BLUE[\[\033[\$(echo -n \$HIST_COLOR)m\]\!$BLUE] $WHITE\w$LIGHT_CYAN\$ $DEFAULT"
}


function top_prompt
{
# If running interactively, then:
if [ "$PS1" ]; then
   local top_prompt_color="\[\033[1;30;46m\]"
    # set the prompt 
    PS1="$(tput sc)$(tput cup 0 0)$(tput el)$top_prompt_color     \w : \u@\H { \$(date +%T) }$(tput rc)$"
    
    # move one line
    tput cup 1 0
    
fi
}

function plain_prompt
{
    local current_tty=`tty | sed -e "s/\/dev\/\(.*\)/\1/"`
    PS1="> $current_tty \u@\H:\w\n> \$? \t \! "'\$'" "
    PS2="> "
}


function fancy_three_line_prompt
{
PS1='\[\033[0m\]\[\033[0;31m\].:\[\033[0m\]\[\033[1;30m\][\[\033[0m\]\[\033[0;28m\]Managing \033[1;31m\]\j\[\033[0m\]\[\033[1;30m\]/\[\033[0m\]\[\033[1;31m\]$(ps ax | wc -l | tr -d '\'' '\'')\[\033[0m\]\[\033[1;30m\] \[\033[0m\]\[\033[0;28m\]jobs.\[\033[0m\]\[\033[1;30m\]] [\[\033[0m\]\[\033[0;28m\]CPU Load: \[\033[0m\]\[\033[1;31m\]$(temp=$(cat /proc/loadavg) && echo ${temp%% *}) \[\033[0m\]\[\033[0;28m\]Uptime: \[\033[0m\]\[\033[1;31m\]$(temp=$(cat /proc/uptime) && upSec=${temp%%.*} ; let secs=$((${upSec}%60)) ; let mins=$((${upSec}/60%60)) ; let hours=$((${upSec}/3600%24)) ; let days=$((${upSec}/86400)) ; if [ ${days} -ne 0 ]; then echo -n ${days}d; fi ; echo -n ${hours}h${mins}m)\[\033[0m\]\[\033[1;30m\]]\[\033[0m\]\[\033[0;31m\]:.\n\[\033[0m\]\[\033[0;31m\].:\[\033[0m\]\[\033[1;30m\][\[\033[0m\]\[\033[1;31m\]$(ls -l | grep "^-" | wc -l | tr -d " ") \[\033[0m\]\[\033[0;28m\]files using \[\033[0m\]\[\033[1;31m\]$(ls --si -s | head -1 | awk '\''{print $2}'\'')\[\033[0m\]\[\033[1;30m\]] [\[\033[0m\]\[\033[1;31m\]\u\[\033[0m\]\[\033[0;31m\]@\[\033[0m\]\[\033[1;31m\]\h \[\033[0m\]\[\033[1;34m\]\w\[\033[0m\]\[\033[1;30m\]]\[\033[0m\]\[\033[0;31m\]:.\n\[\033[0m\]\[\033[0;31m\].:\[\033[0m\]\[\033[1;30m\][\[\033[0m\]\[\033[1;31m\]\t\[\033[0m\]\[\033[1;30m\]]\[\033[0m\]\[\033[0;31m\]:. \[\033[0m\]\[\033[1;37m\]$ \[\033[0m\]'
}

#some aliases to set fancy prompts
#see .bash_slyles for further informations

if [ -f ~/.bash_styles ];
then
 alias dumb='. ~/.bash_styles dumb'
 alias ice='. ~/.bash_styles ice'
 alias fire='. ~/.bash_styles fire'
 alias nature='. ~/.bash_styles nature'
 alias sunshine='. ~/.bash_styles sunshine'
 alias dream='. ~/.bash_styles dream'
 alias magic='. ~/.bash_styles magic'
 alias iceg='. ~/.bash_styles iceg'
 alias topline='. ~/.bash_styles topline'
fi


# Actions
color_prompt
