# Global settings
MAGICENTER=(me_dirs me_ls me_git)

# Magic enter functions
function me_dirs {
    local _w="\e[0m"
    local _g="\e[38;5;244m"

    if [ "$(dirs -p | sed -n '$=')" -gt 1 ]; then
        local stack="$(dirs)"
        echo "$_g${stack//\//$_w/$_g}$_w"
    fi
}

function me_ls {
    command eza -GFx --color=always
}

function me_git {
    command git -c color.status=always status -sb 2> /dev/null
}

# draw infoline if no command is given
function _buffer-empty {
    if [ -z "$BUFFER" ]; then
        printf "${USER}@${HOST}\n"
        local cmd
        for cmd in $MAGICENTER; do
            $cmd
        done
        printf "\n"
        zle redisplay
    else
        zle accept-line
    fi
}

# properly bind widgets
# see: https://github.com/zsh-users/zsh-syntax-highlighting/blob/1f1e629290773bd6f9673f364303219d6da11129/zsh-syntax-highlighting.zsh#L292-L356
zmodload zsh/zleparameter
zle -N buffer-empty _buffer-empty

bindkey -M main  "^M" buffer-empty
bindkey -M vicmd "^M" buffer-empty
