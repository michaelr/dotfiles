set -g SHELL fish
# disable fish greeting
set -g fish_greeting ""

# theme-bobthefish settings
set -g theme_color_scheme dracula
set -g theme_nerd_fonts yes
set -g theme_date_format "+%l:%M%p %a %b %d"
set -g theme_display_cmd_duration no

# this was causing slowdowns on wsl
set -g theme_display_ruby no

# disable direnv logging (because I hate seeing the huge env diff)
set -x DIRENV_LOG_FORMAT ""

# direnv hook
direnv hook fish | source

