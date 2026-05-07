#!/usr/bin/env bash
# ==============================================================================
# Home Assistant Add-on: Globalping Probe
#
# This script is adapted from the upstream globalping-probe entrypoint.
# It downloads the latest probe bundle on every start (matching upstream
# behaviour) so the add-on container always runs the current probe code.
#
# Source: https://github.com/jsdelivr/globalping-probe/blob/master/bin/entrypoint.sh
# ==============================================================================
set -o pipefail

update-ca-certificates >/dev/null 2>&1 || true

run_probe() {
    exec node /app/dist/index.js
}

try_update() {
    local response latestVersion currentVersion loadedTarball
    local latestBundleA latestBundleB latestBundleC

    echo "Checking for the latest probe version..."

    response=$(curl --max-time 40 --retry 3 --retry-max-time 120 \
        --retry-all-errors -XGET -Lf -sS \
        "https://data.jsdelivr.com/v1/packages/gh/jsdelivr/globalping-probe/resolved")

    if [ $? -eq 0 ] && [ -n "$response" ]; then
        echo "Probe version successfully fetched from jsDelivr API."
        latestVersion=$(jq -r ".version" <<<"${response}" | sed 's/v//')
    else
        echo "Failed to fetch the version info from jsDelivr API. Trying GitHub API..."
        response=$(curl --max-time 40 --retry 3 --retry-max-time 120 \
            --retry-all-errors -XGET -Lf -sS \
            "https://api.github.com/repos/jsdelivr/globalping-probe/releases/latest")

        if [ $? -eq 0 ] && [ -n "$response" ]; then
            echo "Probe version successfully fetched from GitHub API."
            latestVersion=$(jq -r ".tag_name" <<<"${response}" | sed 's/v//')
        else
            echo "Failed to fetch the version info from GitHub API. All methods failed."
            return 1
        fi
    fi

    if [ -z "$latestVersion" ] || [ "$latestVersion" = "null" ]; then
        echo "Failed to parse the version string from the response."
        return 1
    fi

    latestBundleA="https://cdn.jsdelivr.net/globalping-probe/v${latestVersion}/globalping-probe.bundle.tar.gz"
    latestBundleB="https://fastly.jsdelivr.net/globalping-probe/v${latestVersion}/globalping-probe.bundle.tar.gz"
    latestBundleC="https://github.com/jsdelivr/globalping-probe/releases/download/v${latestVersion}/globalping-probe.bundle.tar.gz"

    if [ -f /app/package.json ]; then
        currentVersion=$(jq -r ".version" "/app/package.json" 2>/dev/null || echo "")
    else
        currentVersion=""
    fi

    echo "Current version ${currentVersion:-<none>}"
    echo "Latest version ${latestVersion}"

    if [ -n "$currentVersion" ] && [ "$currentVersion" = "$latestVersion" ]; then
        return 0
    fi

    loadedTarball="globalping-probe-${latestVersion}"
    echo "Installing globalping-probe v${latestVersion}..."

    if ! curl -XGET -Lf -sS "${latestBundleA}" -o "/tmp/${loadedTarball}.tar.gz"; then
        echo "Failed to fetch from cdn.jsdelivr.net. Trying fastly.jsdelivr.net..."
        if ! curl -XGET -Lf -sS "${latestBundleB}" -o "/tmp/${loadedTarball}.tar.gz"; then
            echo "Failed to fetch from fastly.jsdelivr.net. Trying GitHub..."
            if ! curl -XGET -Lf -sS "${latestBundleC}" -o "/tmp/${loadedTarball}.tar.gz"; then
                echo "Failed to fetch the release tarball from all sources."
                return 1
            fi
        fi
    fi

    if ! tar -xzf "/tmp/${loadedTarball}.tar.gz" --one-top-level="/tmp/${loadedTarball}"; then
        echo "Failed to extract the release tarball."
        return 1
    fi

    rm -rf /app
    mv "/tmp/${loadedTarball}" /app
    rm -f "/tmp/${loadedTarball}.tar.gz"

    if [ -f /app/bin/patch.sh ]; then
        echo "Running the patch script..."
        bash /app/bin/patch.sh || true
    fi

    echo "Globalping probe v${latestVersion} installed."
    return 0
}

if ! try_update; then
    if [ ! -f /app/dist/index.js ]; then
        echo "No probe installed and update failed; cannot start probe."
        exit 1
    fi
    echo "Update failed; starting previously installed probe."
fi

run_probe
