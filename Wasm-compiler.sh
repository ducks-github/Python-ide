#!/bin/sh

# Script to set up a WebAssembly compiler environment in iSH
# Supports C, C++, Python, Rust, and Node.js for WebAssembly
# Run this script in iSH shell on iPhone

# Exit on error
set -e

# Update and install basic dependencies
echo "Updating package manager and installing dependencies..."
apk update
apk add alpine-sdk git curl cmake python3 nodejs npm clang binaryen wasmtime

# Create a working directory for WASM projects
WASM_DIR="$HOME/wasm-projects"
mkdir -p "$WASM_DIR"
cd "$WASM_DIR"

# Install Rust and wasm-pack for Rust-to-WASM compilation
echo "Installing Rust and wasm-pack..."
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
cargo install wasm-pack

# Install Emscripten for C/C++ to WASM compilation
echo "Installing Emscripten..."
git clone https://github.com/emscripten-core/emsdk.git
cd emsdk
./emsdk install latest
./emsdk activate latest
source ./emsdk_env.sh
cd ..

# Install Pyodide for Python-to-WASM (experimental in iSH)
echo "Installing Pyodide for Python-to-WASM..."
apk add python3-dev
curl -L -o pyodide.tar.gz https://github.com/pyodide/pyodide/releases/download/0.26.2/pyodide-0.26.2.tar.bz2
tar -xjf pyodide.tar.gz
rm pyodide.tar.gz
mv pyodide-0.26.2 pyodide
cd pyodide
# Note: Pyodide is a runtime; compiling Python to WASM requires Emscripten
echo "Pyodide installed. Use Emscripten for custom Python-to-WASM compilation."
cd ..

# Set up Node.js environment for running WASM
echo "Setting up Node.js for WASM execution..."
npm install -g wasm-run
npm init -y
npm install @wasmer/sdk

# Create example projects
echo "Creating example projects for C, C++, Python, Rust, and JavaScript..."

# Example C project
mkdir -p c-example
cat << EOF > c-example/hello.c
#include <stdio.h>
int main() {
    printf("Hello from C in WebAssembly!\n");
    return 0;
}
EOF
echo "C example created. Compile with: emcc c-example/hello.c -o c-example/hello.html"

# Example C++ project
mkdir -p cpp-example
cat << EOF > cpp-example/hello.cpp
#include <iostream>
int main() {
    std::cout << "Hello from C++ in WebAssembly!\n";
    return 0;
}
EOF
echo "C++ example created. Compile with: em++ cpp-example/hello.cpp -o cpp-example/hello.html"

# Example Rust project
mkdir -p rust-example
cd rust-example
wasm-pack new rust-wasm
cd ..
echo "Rust example created. Build with: cd rust-example/rust-wasm && wasm-pack build --target web"

# Example Python project
mkdir -p python-example
cat << EOF > python-example/hello.py
print("Hello from Python in WebAssembly!")
EOF
echo "Python example created. Use Pyodide or Emscripten to run (see notes)."

# Example JavaScript to run WASM
mkdir -p js-example
cat << EOF > js-example/index.js
const { Wasmer } = require('@wasmer/sdk');
async function runWasm() {
    const wasmModule = await WebAssembly.instantiateStreaming(fetch('example.wasm'));
    console.log("Running WASM from JavaScript...");
}
runWasm();
EOF
echo "JavaScript example created. Run with: node js-example/index.js"

# Print usage instructions
echo "Setup complete! Usage instructions:"
echo "- C: emcc c-example/hello.c -o c-example/hello.wasm"
echo "- C++: em++ cpp-example/hello.cpp -o cpp-example/hello.wasm"
echo "- Rust: cd rust-example/rust-wasm && wasm-pack build --target web"
echo "- Python: Use Pyodide (./pyodide/bin/pyodide) or Emscripten for WASM"
echo "- JavaScript/Node.js: Run WASM modules with node js-example/index.js"
echo "- Note: iSH has limitations. Some tools (e.g., Emscripten, Pyodide) may require additional configuration or may not work fully due to iOS restrictions."

# Clean up
echo "Cleaning up temporary files..."
rm -f *.tar.gz

echo "WebAssembly compiler environment setup complete in $WASM_DIR!"
