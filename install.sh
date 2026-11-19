#!/usr/bin/env sh
# Installs the mactop alias into the current user's shell config.

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SCRIPT_PATH="$SCRIPT_DIR/mactop"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Could not find mactop in $SCRIPT_DIR" >&2
    exit 1
fi
chmod +x "$SCRIPT_PATH" 2>/dev/null || true

case "$(basename "${SHELL:-zsh}")" in
    zsh)  RC="$HOME/.zshrc";                   SEP="=" ;;
    fish) RC="$HOME/.config/fish/config.fish"; SEP=" " ;;
    *)    RC="$HOME/.bashrc";                  SEP="=" ;;
esac

mkdir -p "$(dirname "$RC")"
touch "$RC"
# Don't glue the first alias onto a last line that has no trailing newline
[ -s "$RC" ] && [ -n "$(tail -c 1 "$RC")" ] && echo >> "$RC"

if grep -Eq '^[[:space:]]*alias[[:space:]]+mactop[= ]' "$RC"; then
    echo "ℹ 'mactop' alias already exists in $RC"
else
    printf "alias mactop%s'%s'\n" "$SEP" "$SCRIPT_PATH" >> "$RC"
    echo "✔ Added 'mactop' alias to $RC"
fi

echo "✔ Ready! Open a new terminal (or run: . $RC) and type 'mactop'."
