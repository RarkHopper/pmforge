#!/bin/bash

BASHRC_PATH="$HOME/.bashrc"

# もとの.bashrcをバックアップ
cp "$BASHRC_PATH" "$BASHRC_PATH.bak"
echo "Created backup at $BASHRC_PATH.bak"

# エイリアス
declare -a aliases=(
    "# Useful aliases"
    "alias ll='ls -alh'"
    "alias la='ls -A'"
    "alias l='ls -CF'"
    "alias ..='cd ..'"
    "alias ...='cd ../..'"
    "alias grep='grep --color=auto'"
    "alias df='df -h'"
    "alias du='du -h'"
    "alias free='free -m'"
    "alias cl=clear"
)

# 既にあるかどうかを確認
aliases_exist=false
for snippet in "${aliases[@]}"; do
    if grep -q "^$(echo "$snippet" | sed 's/[\/&]/\\&/g')" "$BASHRC_PATH"; then
        aliases_exist=true
        break
    fi
done

# なければ追加
if [ "$aliases_exist" = false ]; then
    echo -e "\n# Added by aliases.sh" >> "$BASHRC_PATH"
    for snippet in "${aliases[@]}"; do
        echo "$snippet" >> "$BASHRC_PATH"
    done
    echo "aliases added to $BASHRC_PATH"
else
    echo "Some aliases already exist in $BASHRC_PATH"
fi

echo "To apply changes immediately, run: source $BASHRC_PATH"
