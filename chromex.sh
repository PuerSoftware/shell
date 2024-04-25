function chromex() {
    if [ -z "$1" ]; then
        echo "Usage: create_chrome_extension <extension-name>"
        return 1
    fi

    name=$1

    mkdir "$name"
    cd "$name"
    touch manifest.json
    mkdir -p popup
    touch popup/popup.html
    touch popup/popup.js
    touch popup/popup.css
    mkdir -p icons
    mkdir -p content_scripts
    touch content_scripts/content.js
    mkdir -p background_scripts
    touch background_scripts/background.js

    echo '{
        "manifest_version": 2,
        "name": "'"$name"'",
        "version": "1.0",
        "description": "A simple Chrome extension.",
        "browser_action": {
            "default_popup": "popup/popup.html",
            "default_icon": {
                "16": "icons/icon16.png",
                "48": "icons/icon48.png",
                "128": "icons/icon128.png"
            }
        },
        "permissions": [],
        "background": {
            "scripts": ["background_scripts/background.js"],
            "persistent": false
        },
        "content_scripts": [
            {
                "matches": ["<all_urls>"],
                "js": ["content_scripts/content.js"]
            }
        ]
    }' > manifest.json

    echo "Boilerplate for Chrome extension '$name' created successfully."
}
