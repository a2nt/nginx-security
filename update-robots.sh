#!/usr/bin/env sh

# Updates robots.txt to disallow search spiders access to honey pots

find . -type f -iname "robots.txt" -print0 | while IFS= read -r -d $'\0' name; do
    cat "$name" | head -n -2 > "$name".tmp
    echo "Disallow: /wp-config.php" >> "$name".tmp
    echo "Disallow: /wp-login.php" >> "$name".tmp
    echo "Disallow: /xmlrpc.php" >> "$name".tmp
    echo "Disallow: /wp-main.php" >> "$name".tmp
    echo "Disallow: /setup-config.php" >> "$name".tmp
    echo "Disallow: /setup.php" >> "$name".tmp
    echo "Disallow: /settings.php" >> "$name".tmp
    echo "Disallow: /admin.php" >> "$name".tmp
    echo "Disallow: /login.php" >> "$name".tmp
    echo "Disallow: /administrator" >> "$name".tmp
    echo "Disallow: /login.asp" >> "$name".tmp
    echo "Disallow: /personel.asp" >> "$name".tmp
    echo "Disallow: /includes.php" >> "$name".tmp
    echo "Disallow: /configuration.php" >> "$name".tmp
    echo "Disallow: /README.md" >> "$name".tmp
    tail -n 2 "$name" >> "$name".tmp
    cat "$name".tmp > "$name"
    rm "$name".tmp
done