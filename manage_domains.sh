#!/bin/bash

export LC_ALL=C

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$LIST_FILE" ]; then
    LIST_FILE="${SCRIPT_DIR}/list"
fi
if [ -z "$INACTIVE_FILE" ]; then
    INACTIVE_FILE="${SCRIPT_DIR}/inactive"
fi

# Validate files exist
for file in "$LIST_FILE" "$INACTIVE_FILE"; do
    if [[ ! -f "$file" ]]; then
        echo "Error: Required file $file not found"
        exit 1
    fi
done

add_domain() {
    local domain=$1
    # Validate domain format
    if ! echo "$domain" | grep -qP '^(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+[a-z]{2,}$'; then
        echo "Error: Invalid domain format: $domain"
        exit 1
    fi
    if ! grep -q "^$domain$" "$LIST_FILE"; then
        echo "$domain" >> "$LIST_FILE"
        # Preserve comments at top of file
        (grep '^#' "$LIST_FILE"; grep -v '^#' "$LIST_FILE" | sort) > "$LIST_FILE.tmp" && mv "$LIST_FILE.tmp" "$LIST_FILE"
        echo "Domain $domain added to $LIST_FILE."
    else
        echo "Domain $domain already exists in $LIST_FILE."
    fi
}

move_domain() {
    local domain=$1
    if grep -q "^$domain$" "$LIST_FILE"; then
        sed -i "/^$domain$/d" "$LIST_FILE"
        echo "$domain" >> "$INACTIVE_FILE"
        (head -n 15 "$INACTIVE_FILE" && tail -n +16 "$INACTIVE_FILE" | sort) > "$INACTIVE_FILE.tmp" && mv "$INACTIVE_FILE.tmp" "$INACTIVE_FILE"
        echo "Domain $domain moved to $INACTIVE_FILE."
    else
        echo "Domain $domain does not exist in $LIST_FILE."
    fi
}

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 {add|move} domain"
    exit 1
fi

command=$1
domain=$2

case $command in
    add)
        add_domain "$domain"
        ;;
    move)
        move_domain "$domain"
        ;;
    *)
        echo "Invalid command. Use 'add' to add a domain or 'move' to move a domain."
        exit 1
        ;;
esac
