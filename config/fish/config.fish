set -Ux LANG "en_US.UTF-8"
set -Ux LC_CTYPE "en_US.UTF-8"

fish_config theme choose "Just a Touch"

set -U fish_greeting

if status is-interactive
    # Commands to run in interactive sessions can go here
end


set --local local_config "$__fish_config_dir/local.fish"
if test -e $local_config
    source $local_config
end

starship init fish | source
