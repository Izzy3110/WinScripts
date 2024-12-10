# Windows Scripts - Sandbox

## Installation
### Dependencies
#### Create a shared folder
```
cd C:\
mkdir scripts
```

#### Put your installation file into C:\scripts
#### sandbox-setup.cmd: Copy the full execution filename edit the filepath and modify the commandline arguments
```
...
echo Installing Wireshark-4.2.9-x64...
start /wait C:\scripts\Wireshark-4.2.9-x64.exe /desktopicon=yes
...
```

### First run
#### Create a launch_sanbox.bat inside the folder of the config-file (*.wsb) 
```
@echo off
echo Starting Windows Sandbox...
start /wait config.wsb
echo Sandbox process complete.
pause

```

### Contents
### Config-File
##### config.wsb
```
<Configuration>
    <MappedFolders>
        <MappedFolder>
        <!-- Create a drive mapping that mirrors my Scripts folder -->
            <HostFolder>C:\scripts</HostFolder>
            <SandboxFolder>C:\scripts</SandboxFolder>
            <ReadOnly>false</ReadOnly>
        </MappedFolder>
         <MappedFolder>
            <HostFolder>C:\Pluralsight</HostFolder>
            <SandboxFolder>C:\Pluralsight</SandboxFolder>
            <ReadOnly>true</ReadOnly>
        </MappedFolder>
    </MappedFolders>
    <ClipboardRedirection>true</ClipboardRedirection>
    <MemoryInMB>8192</MemoryInMB>
    <LogonCommand>
     <Command>C:\scripts\sandbox-setup.cmd</Command>
    </LogonCommand>
</Configuration>
```
