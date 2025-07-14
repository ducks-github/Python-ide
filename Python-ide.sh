#!/bin/sh

# Script to set up a Python IDE in iSH using Pyodide (WebAssembly) and serve it on localhost

# Update package manager and install dependencies
echo "Updating apk and installing dependencies..."
apk update
apk add python3 curl

# Create a working directory
WORK_DIR="$HOME/python-ide"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Create the HTML file for the Python IDE
echo "Creating index.html for Python IDE..."
cat > index.html << 'EOF'
<!DOCTYPE html>
<html class="h-full bg-slate-900">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://cdn.tailwindcss.com"></script>
  <script src="https://cdn.jsdelivr.net/pyodide/v0.20.0/full/pyodide.js"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.63.3/codemirror.min.css" />
  <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.63.3/codemirror.min.js"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.63.3/mode/python/python.min.js"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/codemirror/5.63.3/theme/dracula.css"/>
  <style>
    .CodeMirror { height: 50vh; }
    #output { white-space: pre-wrap; color: white; }
  </style>
  <title>Python IDE on WebAssembly</title>
</head>
<body class="h-full overflow-hidden max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 mt-8">
  <p class="text-slate-200 text-3xl my-4 font-extrabold mx-2 pt-8">Python IDE in Browser (Pyodide)</p>
  <div class="h-3/4 flex flex-row">
    <div class="grid w-2/3 border-dashed border-2 border-slate-500 mx-2">
      <textarea id="code" name="code">
# Write Python code here
def hello():
    return "Hello from Pyodide!"
print(hello())
      </textarea>
    </div>
    <div class="grid w-1/3 mx-2">
      <button id="run" class="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded mb-4">
        Run Code
      </button>
      <div id="output" class="border-dashed border-2 border-slate-500 p-2"></div>
    </div>
  </div>
  <script>
    let editor, pyodide;
    async function main() {
      editor = CodeMirror.fromTextArea(document.getElementById('code'), {
        mode: 'python',
        theme: 'dracula',
        lineNumbers: true
      });
      pyodide = await loadPyodide();
      document.getElementById('run').addEventListener('click', async () => {
        const code = editor.getValue();
        const output = document.getElementById('output');
        output.innerText = '';
        try {
          await pyodide.runPythonAsync(`
            import sys
            import io
            sys.stdout = io.StringIO()
            ${code}
            sys.stdout.getvalue()
          `).then(result => {
            output.innerText = result || 'No output';
          });
        } catch (err) {
          output.innerText = `Error: ${err.message}`;
        }
      });
    }
    main();
  </script>
</body>
</html>
EOF

# Start a simple HTTP server
echo "Starting HTTP server on localhost:8000..."
python3 -m http.server 8000 &

# Wait briefly to ensure the server starts
sleep 2

# Inform the user
echo "Python IDE is running at http://localhost:8000"
echo "Open Safari or another browser on your iPhone and navigate to http://localhost:8000"
echo "Write Python code in the editor, click 'Run Code', and see the output."
echo "To stop the server, run 'killall python3' in iSH."
