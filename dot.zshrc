############################################################
## .zshrc
##   last modified 2011-12-28
############################################################

# 履歴ファイルの設定
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000

# CJK_WIDTH対応
setopt print_eightbit

# キーバインディングをemacs互換に設定
bindkey -e

# コマンドオプションの自動補完
zstyle :compinstall filename '/home/yuy/.zshrc'
autoload -Uz compinit
compinit

# 色づけの設定
autoload -U colors
colors

# ../を自動補完に加える設定 'man zshcompsys'からコピペ
zstyle -e ':completion:*' special-dirs '[[ $PREFIX = (../)#(|.|..) ]] && reply=(..)'

# エスケープシーケンスを有効にする
setopt prompt_subst

# 履歴に入力時刻も記録するようにする
setopt extended_history

# 既存のコマンドは履歴に入れないようにする
setopt hist_ignore_dups

# 複数ターミナルで履歴を共有可能にする
setopt share_history

# scp等でワイルドカードにワーニングを出さない
unsetopt NOMATCH

# emacs上で扱えるようにする？
[[ $EMACS = t ]] && unsetopt zle

# PROMPTの設定 -> /etc/zsh/zshrcに
case ${UID} in
0)
  PROMPT=$'%{\e[35m%}[%n@%m %1d]#%{\e[m%} '
  RPROMPT=$'%{\e[33m%}[%~]%{\e[m%}'
  PROMPT2="%_%% "
  SPROMPT="%r is correct? [n,y,a,e]: "
  ;;
*)
  PROMPT=$'%{\e[36m%}[%n@%m %1d]$%{\e[m%} '
  RPROMPT=$'%{\e[33m%}[%~]%{\e[m%}'
  PROMPT2="%_%% "
  SPROMPT="%r is correct? [n,y,a,e]: "
  ;;
esac

# M-f, M-bの挙動をemacsと同じにする
bindkey $'\ef' emacs-forward-word
bindkey $'\eb' emacs-backward-word
export WORDCHARS=""

case "$TERM" in
dumb)
  # emacsのshell-modeでPROMPTにエスケープを入れないようにする
  PROMPT="[%n@%m %1d]$ " 
  unsetopt zle
  ;;
xterm)
  # xterm等でタイトルに現在ディレクトリを反映する
  function chpwd() {
    echo -n "\e]2;$USER@$HOST $(pwd)\a"
  }
  chpwd
  ;;
screen-256color)
  # screenでsshした場合，新規whindowを作成する
  function ssh_screen() {
    eval server=\${$#}
    screen -t $server ssh "$@"
  }
  function ssh_tmux() {
    eval server=\${$#}
    tmux new-window -n $server "ssh '$@'"
  }
  #alias ssh=ssh_screen
  alias ssh=ssh_tmux
  # screenのwindow名称を最後に実行したコマンド名に変更する
  function preexec() {
    # see [zsh-workers:13180]
    # http://www.zsh.org/mla/workers/2000/msg03993.html
    emulate -L zsh
    local -a cmd; cmd=(${(z)2})
    case $cmd[1] in
    fg)
      if (( $#cmd == 1 )); then
        cmd=(builtin jobs -l %+)
      else
        cmd=(builtin jobs -l $cmd[2])
      fi
      ;;
    %*) 
      cmd=(builtin jobs -l $cmd[1])
      ;;
    cd)
      if (( $#cmd == 2)); then
        cmd[1]=$cmd[2]
      fi
      ;&
    *)
      echo -n "k$cmd[1] @$HOST:t\\"
      return
      ;;
    esac

    local -A jt; jt=(${(kv)jobtexts})

    $cmd >>(read num rest cmd=(${(z)${(e):-\$jt$num}})
    echo -n "^[k$cmd[1] @$HOST:t^[\\") 2>/dev/null
  }
esac

# ls関係の設定＆エイリアス
eval "`dircolors -b ~/.dir_colors/dircolors`"
alias ls='ls --color=auto'
alias ll='ls -l'
alias la='ls -a'
alias lla='ls -la'

# some more aliases
alias emacs='emacs -nw'
alias gnome-terminal='VTE_CJK_WIDTH=auto VTE_BACKEND=pango gnome-terminal --disable-factory'
alias ta='trash'
alias rm~='rm -i ./*~'
alias rrm~='find ./* -name '*~' | xargs rm -i'
alias mkrb='cp ~/project/skel/skel.rb '
alias scr='screen -d -r yuy'
alias scn='screen -S yuy'
alias scl='screen -ls'
alias tmux='tmux -2'

# enable ctrl-s and ctrl-q for vim
stty -ixon -ixoff

#PATH=$PATH:$HOME/.rvm/bin:$HOME/bin # Add RVM to PATH for scripting

PERL_MB_OPT="--install_base \"/home/yuy/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/home/yuy/perl5"; export PERL_MM_OPT;
