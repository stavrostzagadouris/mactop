#!/usr/bin/env sh
# Installs the atop / appletop alias into the current user's shell config.

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SCRIPT_PATH="$SCRIPT_DIR/atop"

if [ ! -f "$SCRIPT_PATH" ]; then
    echo "Could not find atop in $SCRIPT_DIR" >&2
    exit 1
fi
chmod +x "$SCRIPT_PATH" "$SCRIPT_DIR/appletop" 2>/dev/null || true

case "$(basename "${SHELL:-zsh}")" in
    zsh)
        RC="$HOME/.zshrc"
        ALIAS_LINE="alias atop='$SCRIPT_PATH'"
        ALIAS_LINE2="alias appletop='$SCRIPT_PATH'"
        ;;
    fish)
        RC="$HOME/.config/fish/config.fish"
        ALIAS_LINE="alias atop '$SCRIPT_PATH'"
        ALIAS_LINE2="alias appletop '$SCRIPT_PATH'"
        ;;
    *)
        RC="$HOME/.bashrc"
        ALIAS_LINE="alias atop='$SCRIPT_PATH'"
        ALIAS_LINE2="alias appletop='$SCRIPT_PATH'"
        ;;
esac

mkdir -p "$(dirname "$RC")"
touch "$RC"

if grep -Eq '^[[:space:]]*alias[[:space:]]+atop[= ]' "$RC"; then
    echo "ℹ 'atop' alias already exists in $RC"
else
    printf '\n%s\n' "$ALIAS_LINE" >> "$RC"
    echo "✔ Added 'atop' alias to $RC"
fi

if grep -Eq '^[[:space:]]*alias[[:space:]]+appletop[= ]' "$RC"; then
    echo "ℹ 'appletop' alias already exists in $RC"
else
    printf '%s\n' "$ALIAS_LINE2" >> "$RC"
    echo "✔ Added 'appletop' alias to $RC"
fi

echo "✔ Ready! Open a new terminal (or run: . $RC) and type 'atop' (or 'appletop')."
