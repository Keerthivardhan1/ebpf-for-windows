# Copyright (c) Microsoft Corporation
# SPDX-License-Identifier: MIT

param([parameter(Mandatory = $true)] [string] $ProgramName,
    [parameter(Mandatory = $false)] [string] $SolutionDir = $Pwd,
    [parameter(Mandatory = $false)] [string] $Platform = "x64",
    [parameter(Mandatory = $false)] [string] $Configuration = "Release",
    [parameter(Mandatory = $false)] [bool] $KernelMode = $true)

# If program name ends with .o, remove the suffix
if ($ProgramName.EndsWith(".o")) {
    $ProgramName = $ProgramName.Substring(0, $ProgramName.Length - 2)
}

if ($null -eq (Get-Command 'msbuild.exe' -ErrorAction SilentlyContinue)) {
    throw "Unable to locate msbuild.exe. This command needs to run within a 'Developer Command Prompt'"
}

$fileExists = Test-Path -Path ("$SolutionDir\$Platform\$Configuration\$ProgramName.o")
if (!$fileExists) {
    $errorString = "Can't find program file: " + "$SolutionDir\$Platform\$Configuration\$ProgramName.o"
    throw $errorString
}

Push-Location $SolutionDir

$ProjectFile = "$SolutionDir\tools\bpf2c\templates\kernel_mode_bpf2c.vcxproj"
if (!$KernelMode) {
    $ProjectFile = "$SolutionDir\tools\bpf2c\templates\user_mode_bpf2c.vcxproj"
}

msbuild /p:SolutionDir="$SolutionDir\" /p:OutDir="$SolutionDir\$Platform\$Configuration\" /p:Configuration="$Configuration" /p:Platform="$Platform" /p:ProgramName="$ProgramName" $ProjectFile
if ($LASTEXITCODE -ne 0) {
    throw "Build failed for $ProgramName.o"
}