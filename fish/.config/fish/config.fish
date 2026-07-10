# ─────────────────────────────────────────
#  Fish Shell Configuration  (~/.config/fish/config.fish)
# ─────────────────────────────────────────

if not status is-interactive
    exit
end

if status is-login
    if test -z "$DISPLAY" -a "$XDG_VTNR" = 1
        exec dbus-run-session niri
    end
end

if status is-interactive
    set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/ssh-agent.socket"

    if not pgrep -u (id -u) ssh-agent >/dev/null
        ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null
    end

    ssh-add -l >/dev/null 2>&1
    or begin
        ssh-add ~/.ssh/id_ed25519_github
#       ssh-add ~/.ssh/id_ed25519_oculeus
    end
end

# ── Greeting ──────────────────────────────
function fish_greeting
    fastfetch
end

# ── Starship ──────────────────────────────
starship init fish | source

# ── Environment ───────────────────────────
set -gx EDITOR "code-insiders --wait"
set -gx VISUAL "code-insiders --wait"
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx BAT_THEME "gruvbox-dark"
set -gx FZF_DEFAULT_COMMAND "fd --type f --hidden --follow --exclude .git"
set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border --preview 'bat --color=always {}'"

# ── PATH ──────────────────────────────────
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin

# ═══════════════════════════════════════════
#  ABBREVIATIONS
# ═══════════════════════════════════════════

# ── Editor ────────────────────────────────
abbr --add code   'code-insiders'

# ── File & navigation ─────────────────────
abbr --add ls     'eza --icons --group-directories-first'
abbr --add ll     'eza -lah --icons --group-directories-first --git'
abbr --add lt     'eza --tree --icons --level=2'
abbr --add lt3    'eza --tree --icons --level=3'
abbr --add cat    'bat'
abbr --add ..     'cd ..'
abbr --add ...    'cd ../..'
abbr --add ....   'cd ../../..'
abbr --add mkd    'mkdir -p'
abbr --add cp     'cp -iv'                  # confirm + verbose
abbr --add mv     'mv -iv'                  # confirm + verbose
abbr --add rm     'rm -iv'                  # confirm + verbose (saves lives)

# ── Search & text ─────────────────────────
abbr --add grep   'rg'
abbr --add find   'fd'
abbr --add sed    'sd'                       # sd 'old' 'new' file

# ── System info ───────────────────────────
abbr --add du     'dust'
abbr --add df     'duf'
abbr --add top    'btm'
abbr --add ps     'procs'
abbr --add diff   'delta'
abbr --add cd     'z'

# ── Network ───────────────────────────────
abbr --add ping   'gping'
abbr --add curl   'curlie'                   # API inspection
abbr --add get    'aria2c'                   # file downloads with progress
abbr --add wget   'wget --progress=bar'      # explicit progress bar

# ── Git ───────────────────────────────────
abbr --add g      'git'
abbr --add gs     'git status'
abbr --add ga     'git add'
abbr --add gaa    'git add --all'
abbr --add gc     'git commit -m'
abbr --add gca    'git commit --amend'
abbr --add gcane  'git commit --amend --no-edit'
abbr --add gp     'git push'
abbr --add gpf    'git push --force-with-lease'  # safer than --force
abbr --add gpl    'git pull'
abbr --add gco    'git checkout'
abbr --add gcb    'git checkout -b'          # new branch
abbr --add gb     'git branch'
abbr --add gbd    'git branch -d'
abbr --add glog   'git log --oneline --graph --decorate'
abbr --add gd     'git diff'
abbr --add gds    'git diff --staged'
abbr --add gst    'git stash'
abbr --add gstp   'git stash pop'
abbr --add grb    'git rebase'
abbr --add grbi   'git rebase -i'
abbr --add grs    'git restore'
abbr --add grss   'git restore --staged'     # unstage a file

# ── Arch / pacman ─────────────────────────
abbr --add pac    'sudo pacman'
abbr --add pacs   'sudo pacman -S'
abbr --add pacr   'sudo pacman -Rns'
abbr --add pacu   'sudo pacman -Syu'
abbr --add paci   'pacman -Qi'
abbr --add pacl   'pacman -Ql'               # list files in package
abbr --add paco   'pacman -Qdt'              # list orphan packages
abbr --add pacss  'pacman -Ss'               # search repos

# ── systemd ───────────────────────────────
abbr --add sc     'sudo systemctl'
abbr --add scs    'sudo systemctl status'
abbr --add scst   'sudo systemctl start'
abbr --add scsp   'sudo systemctl stop'
abbr --add scr    'sudo systemctl restart'
abbr --add sce    'sudo systemctl enable --now'
abbr --add scd    'sudo systemctl disable --now'
abbr --add jc     'journalctl'
abbr --add jcf    'journalctl -fu'           # follow a service: jcf nginx

# ── Misc ──────────────────────────────────
abbr --add cl     'clear'
abbr --add q      'exit'
abbr --add path   'echo $PATH | tr : \n'     # print PATH one entry per line

# ── Quick config edits ────────────────────
abbr --add efish  'code-insiders ~/.config/fish/config.fish'
abbr --add eship  'code-insiders ~/.config/starship.toml'
abbr --add eghst  'code-insiders ~/.config/ghostty/config'

# ═══════════════════════════════════════════
#  FUNCTIONS
# ═══════════════════════════════════════════

# mkcd — make a directory and cd into it immediately
function mkcd --description "mkdir + cd"
    mkdir -p $argv[1] && cd $argv[1]
end

# up N — go up N directories at once
function up --description "Go up N directories"
    set n (test -n "$argv[1]" && echo $argv[1] || echo 1)
    set path ""
    for i in (seq $n)
        set path "$path../"
    end
    cd $path
end

# extract — one command for every archive format
function extract --description "Extract any archive"
    switch $argv[1]
        case "*.tar.bz2";  tar xjf $argv[1]
        case "*.tar.gz";   tar xzf $argv[1]
        case "*.tar.xz";   tar xJf $argv[1]
        case "*.zip";      unzip $argv[1]
        case "*.7z";       7z x $argv[1]
        case "*.rar";      unrar x $argv[1]
        case "*.gz";       gunzip $argv[1]
        case "*.bz2";      bunzip2 $argv[1]
        case "*";          echo "Unknown archive format: $argv[1]"
    end
end

# bak — quickly back up a file with a timestamp suffix
# usage: bak file.conf  →  file.conf.bak.2025-01-15
function bak --description "Backup a file with timestamp"
    cp -v $argv[1] $argv[1].bak.(date +%Y-%m-%d)
end

# mktar — create a compressed tarball from a folder
# usage: mktar myfolder  →  myfolder.tar.gz
function mktar --description "Create a .tar.gz archive"
    tar czvf $argv[1].tar.gz $argv[1]
end

# cheat — look up cheat.sh for any command
# usage: cheat tar        cheat git commit
function cheat --description "Look up cheat.sh for a command"
    curl -s "cheat.sh/$argv[1]" | bat --language=sh
end

# myip — show your public and local IPs
function myip --description "Show public and local IP"
    echo "Public : "(curl -s ifconfig.me)
    echo "Local  : "(ip route get 1 | awk '{print $7; exit}')
end

# ports — show all listening ports
function ports --description "Show all listening ports"
    ss -tulnp
end

# reload — re-source config without opening a new shell
function reload --description "Reload fish config"
    source ~/.config/fish/config.fish
    echo "Fish config reloaded."
end

# newscript — create an executable shell script and open it
# usage: newscript deploy.sh
function newscript --description "Create and open an executable script"
    echo "#!/usr/bin/env fish" > $argv[1]
    chmod +x $argv[1]
    code-insiders $argv[1]
end

# lsport — find what process is using a given port
# usage: lsport 8080
function lsport --description "Find process using a port"
    ss -tulnp | grep $argv[1]
end

# fgit — fuzzy git branch switcher using fzf
function fgit --description "Fuzzy git branch switcher"
    set branch (git branch --all | fzf | string trim)
    and git checkout (echo $branch | sed 's|remotes/origin/||')
end

# fhist — fuzzy search shell history and run a command
function fhist --description "Fuzzy search command history"
    builtin history | fzf | read -l cmd
    and commandline $cmd
end

# ── Init zoxide ───────────────────────────
zoxide init fish | source

# pnpm
set -gx PNPM_HOME "/home/bogdan/.local/share/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
