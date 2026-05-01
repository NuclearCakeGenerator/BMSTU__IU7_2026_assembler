To install dependancies on linux:

1. Install `llvm-vs-code-extensions.lldb-dap` extension in VS Code.
2. run `setup.sh` via root**

or

2. Install `make`, `nasm` etc manually:

```bash
sudo apt update && sudo apt upgrade -y && sudo apt install -y nasm make gcc gdb libgtk-3-dev
```

For convienient build and run shortcuts create in `.vscode/` these files:

`launch.json`
```
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Debug Assembly (LLDB)",
      "type": "lldb",
      "request": "launch",
      "program": "${fileDirname}/app.exe",
      "cwd": "${fileDirname}",
      "stopOnEntry": true,
      "preLaunchTask": "build-asm"
    },
    {
      "name": "Debug Assembly (GDB)",
      "type": "cppdbg",
      "request": "launch",
      "program": "${fileDirname}/app.exe",
      "cwd": "${fileDirname}",
      "stopAtEntry": true,
      "preLaunchTask": "build-asm",
      "MIMode": "gdb",
      "miDebuggerPath": "/usr/bin/gdb",
      "externalConsole": false
    }
  ]
}
```

`tasks.json`
```
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "build-asm",
            "type": "shell",
            "command": "make",
            "group": "build",
            "options": {
                "cwd": "${fileDirname}"
            }
        }
    ]
}
```

This configuration will allow you to build and run your specific lab in debug mode by simply press `F5` when any file of this lab is currently opened in editor.
