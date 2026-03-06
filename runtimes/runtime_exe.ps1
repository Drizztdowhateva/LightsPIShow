param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ArgsFromCaller
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
python "$ScriptDir/runtime_package.py" exe @ArgsFromCaller
