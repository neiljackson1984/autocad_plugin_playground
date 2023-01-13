#!pwsh

# set up for, and then launch the acad.exe process for debugging.



# we need to be able to do a bit of prep work before launching acad for debugging.
# We want to be able to specify a script processor as the target executable for the debug start command,
# then do the setup work in the script processor which will launch the acad.exe process in turn, and we want the debugger to attach
# to the acad.exe process.
# I think that, in a Linux environment, a shell script that called exec acad.exe would do the trick,
# but windows does not have an exact equivalent of the Linux exec(), I think -- rather than replacing the process in place,
# the best we can do with windows is to start a child process, and we need the debugger to attach to the child process.

# https://devblogs.microsoft.com/devops/introducing-the-child-process-debugging-power-tool/ 
#   https://visualstudiogallery.msdn.microsoft.com/a1141bff-463f-465f-9b6d-d29b7b503d7a

# https://stackoverflow.com/questions/4814361/how-to-start-a-child-process-in-the-same-visual-studio-debugging-session-as-the
# https://learn.microsoft.com/en-us/previous-versions/windows/desktop/xperf/image-file-execution-options 


Param (
	[Parameter(
	)]
	[String] $TargetPath
)

# "TargetPath: $($TargetPath)" | Out-File -Encoding "utf8" -Force -Append -FilePath (join-path $PSScriptRoot "log.txt") 

return
$pathOfAcadExecutableFile = "$(Resolve-Path (Join-Path (Join-Path (Join-Path $env:ProgramFiles "Autodesk") "AutoCAD 2023") "acad.exe"))"
$pathOfAcCoreConsoleExecutableFile = "$(Resolve-Path (Join-Path (Join-Path (Join-Path $env:ProgramFiles "Autodesk") "AutoCAD 2023") "accoreconsole.exe"))"
$pathOfTemporaryAcadScriptFile = (join-path ([System.IO.Path]::GetTempPath()) "$((New-Guid).Guid)).scr") 

# MSBuild macros from Visual Studio:
# $TargetPath = "C:\work\2023-01-06_acad_file_dissection\a\ClassLibrary1\ClassLibrary1\bin\Debug\ClassLibrary1.dll"

$pathOfDwgFile = "C:\work\2023-01-06_acad_file_dissection\EV-2-M-10-115-FGV.dwg"

#it might make sense to have acad load a temporary copy of our dll to prevent acad from locking the file.
Set-Content -Force -NoNewline -Path $pathOfTemporaryAcadScriptFile -Value (
	@(
		"secureload 0"
		"netload `"$($TargetPath)`""
		"open `"$($pathOfDwgFile)`""
		"adskgreeting"
		""
	) -join "`n"
)

# possible strategy: ensure the existence of the appropriate registry key and values at
# HKEY_LOCAL_MACHINE\Software\Microsoft\Windows NT\currentversion\image file execution
# per instructions at https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2008/a329t4ed(v=vs.90)?redirectedfrom=MSDN
# per instructions at https://stackoverflow.com/questions/4814361/how-to-start-a-child-process-in-the-same-visual-studio-debugging-session-as-the
# 
# in this case, we would not be designating anything as the debug start executable  in the visul studio settings, but would rather
# run this script independently.

# alternate possible strategy: 
# designate this script (or, more accurately, pwsh.exe, with the arguments to launch this script) as the debug start executable
# in the visual studio settings, and rely on the visual studio child process debugging power tool to detect our
# spawning of the acad executable, below, and attach to that newly-created process.


# & $pathOfAcCoreConsoleExecutableFile /product PLNT3D /language "en-US" /s "$((resolve-path $pathOfTemporaryAcadScriptFile))"
& $pathOfAcadExecutableFile /product PLNT3D /language "en-US" /nologo /b "$((resolve-path $pathOfTemporaryAcadScriptFile))"
Start-Process .................................................
#%%

$pathOfTemporaryPowershellScriptFile = (join-path ([System.IO.Path]::GetTempPath()) "$((New-Guid).Guid)).ps1")
Set-Content -Force -NoNewline -Path $pathOfTemporaryPowershellScriptFile -Value (
	@(
		'$args | fl'
	) -join "`n"
) 
& pwsh -File  "$pathOfTemporaryPowershellScriptFile" -a 1


# https://social.msdn.microsoft.com/Forums/vstudio/en-US/7c7d49b5-efd3-417f-8b74-d11d713c1688/template-custom-f5-behaviour-start-action?forum=vsx
# $x = [System.Diagnostics.Process]::Start("pwsh.exe", "-c (Get-Command pwsh.exe).Path").StandardOutput.ReadToEnd()
# $x = [System.Diagnostics.Process]::Start().StandardOutput.ReadToEnd()
# $y = New-Object System.Diagnostics.ProcessStartInfo @("pwsh.exe")
# $y | fl

# get-jobget
# $PSVersionTable | fl

# "(Get-Command pwsh.exe).Path" | fl

# https://learn.microsoft.com/en-us/aspnet/web-forms/overview/deployment/web-deployment-in-the-enterprise/understanding-the-project-file
# https://learn.microsoft.com/en-us/cpp/build/reference/common-macros-for-build-commands-and-properties?redirectedfrom=MSDN&view=msvc-170
# https://learn.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2015/msbuild/common-msbuild-project-properties?view=vs-2015&redirectedfrom=MSDN
# https://learn.microsoft.com/en-us/visualstudio/msbuild/property-functions?view=vs-2022
# https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild-tasks?view=vs-2022
# https://learn.microsoft.com/en-us/visualstudio/msbuild/msbuild-task-reference?view=vs-2022


# the MSBuild "TargetPath" properrty does not seem to be defined when the
# debugging start command is run (which makes sense, perhaps, becuase TargetPath
# is something that is probably resolved during the build process, and starting
# debugging can be done independent of building.
#
# I suspect that TargetPath might be specific to each build target, of which
# which there might be more than one. Therefore, it does not make sense to speak
# of THE TargetPath outside the context of a single build target.
#
# I am really struggling to figure out the preferred way to specify, within the
# .csproj file, specifically within the StartAction, StartProgram, and
# StartArguments elements, the following three things:
#   - path of the powershell (or pwsh) executable file.
#   - path of this very start_debugging.ps1 script file.
#   - path of the dll file that the build proces generated.
#
# My main confusion is knowing which macro expressions are valid within those
# elements.  Exactly which Macro expressions are valid at any given instant
# during Visual Studio's (or MSBuild's) parsing of the .csproj file(s) is not a
# trivial thing to know, because the available properties depend on which parts
# of the .csproj file(s) MSBuild has already parsed.  Many of the properties
# that work, for instance, in build target specifications, seem not to be
# defined when MSBuild (or Visual Studio) parses the StartAction, StartProgram,
# and StartArguments elements. 
#
# At the moment, I have happened upon the below monstrous expressions that seem
# to work (however fragile they may be):
#
#   - path of powershell executable: (HARDCODED.  in my case:
#     "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe")
#   - path of this very start_debugging.ps1 script file:
#     "$([System.IO.Path]::Combine($(MSBuildProjectDirectory),
#     `start_debugging.ps1`))"
#   - path of the dll file:
#     "$([System.IO.Path]::Combine($(MSBuildProjectDirectory),$(OutputPath),$(AssemblyName).dll))"
#
# The relevant section from the .csproj file looks like this:
#
#  <PropertyGroup Condition="'$(Configuration)|$(Platform)' == 'Debug|AnyCPU'">
#    <StartAction>Program</StartAction>
#    <StartProgram>C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe</StartProgram>
#    <StartArguments>-WindowStyle Hidden -File
#    "$([System.IO.Path]::Combine($(MSBuildProjectDirectory),
#    `start_debugging.ps1`))" -TargetPath
#    "$([System.IO.Path]::Combine($(MSBuildProjectDirectory),$(OutputPath),$(AssemblyName).dll))"</StartArguments>
#    <EnableUnmanagedDebugging>true</EnableUnmanagedDebugging> </PropertyGroup>
#
#
# Very annoyingly, when I open the Visual Studio GUI to edit these elements
# (Project Properties->Debug), Visual Studio displays the computed values rather
# than the uncomputed expressions. thus, an errant edit and save of the
# properties in the GUI might cause my expressions to be replaced by computed
# values.  How can a supposedly professional-grade piece of software have such a
# shitty interface?
#
#   $(MSBuildExtensionsPath)\$(MSBuildToolsVersion)
#   ==>
#   C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current
#
# Where exactly, within the MSBUild configuration, is TargetPath specified?
# probably during one of the build tasks (and ONLY within the build task).
#
#  C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current grep
# -E -e "TargetPath" -inHr  'C:\Program Files\Microsoft Visual
# Studio\2022\Community\MSBuild\Current'/*  | cut -c -150