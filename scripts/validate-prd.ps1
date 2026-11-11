param(
    [Parameter(Mandatory = $false)]
    [string]$Path = ".\docs\specs\intelligent-escalation-prd.md"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
    throw "PRD not found: $Path"
}

$content = Get-Content -LiteralPath $Path -Raw
$errors = [System.Collections.Generic.List[string]]::new()

$requiredHeadings = @(
    "## Problem statement",
    "## Business outcomes and success measures",
    "## Personas",
    "## User journey",
    "## Scope",
    "## Functional requirements",
    "## Non-functional and compliance requirements",
    "## Acceptance criteria",
    "## Telemetry and measurement",
    "## Dependencies and risks",
    "## Open questions",
    "## Superseded decisions",
    "## Source traceability"
)

foreach ($heading in $requiredHeadings) {
    if (-not $content.Contains($heading)) {
        $errors.Add("Missing required heading: $heading")
    }
}

foreach ($keyword in @("**Given**", "**When**", "**Then**")) {
    if (-not $content.Contains($keyword)) {
        $errors.Add("Acceptance criteria are missing $keyword")
    }
}

if ($content -notmatch "https://") {
    $errors.Add("No HTTPS source URL was found")
}

if ($content -notmatch "(?im)^\|\s*(FR|NFR)-\d{3}") {
    $errors.Add("No requirement IDs were found in requirement tables")
}

$unresolvedTokens = [regex]::Matches(
    $content,
    "\{\{[^}]+\}\}|\[(?:Name and role|Date|Persona|Need|Step|Behavior|Question that source evidence does not answer)\]"
)

if ($unresolvedTokens.Count -gt 0) {
    $tokens = $unresolvedTokens.Value | Sort-Object -Unique
    $errors.Add("Unresolved template tokens: $($tokens -join ', ')")
}

if ($content -notmatch "(?is)70.+80|80.+70") {
    $errors.Add("The superseded threshold decision (70 to 80) is not documented")
}

if ($errors.Count -gt 0) {
    Write-Host "PRD validation failed:" -ForegroundColor Red
    foreach ($validationError in $errors) {
        Write-Host " - $validationError" -ForegroundColor Red
    }
    exit 1
}

Write-Host "PRD validation passed: $Path" -ForegroundColor Green

