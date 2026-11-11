#requires -Version 7.0
# Isolated tests: real temporary Git repositories, mocked keypresses and GitHub.
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ("workiq-walkthrough-test-" + [guid]::NewGuid())
$null = New-Item -ItemType Directory -Path $testRoot
$originalLocation = Get-Location
$originalReadHost = Get-Item Function:\Read-Host -ErrorAction SilentlyContinue
$originalGh = Get-Item Function:\gh -ErrorAction SilentlyContinue
$global:DemoTestAnswers = [System.Collections.Generic.Queue[string]]::new()
$global:DemoTestGhCalls = [System.Collections.Generic.List[string]]::new()
$global:DemoTestVisibility = "PUBLIC"
$global:DemoTestOnPause = $null

function Assert-Test {
    param([bool]$Condition, [string]$Message)
    if (-not $Condition) { throw "TEST FAILED: $Message" }
}

function Invoke-TestGit {
    & git @args
    if ($LASTEXITCODE -ne 0) { throw "Test Git command failed: $args" }
}

function Expect-Failure {
    param([scriptblock]$Action, [string]$MessagePattern)
    $failure = $null
    try { & $Action } catch { $failure = $_ }
    Assert-Test ($null -ne $failure) "Expected a failure matching $MessagePattern"
    Assert-Test ($failure.Exception.Message -match $MessagePattern) "Unexpected error: $($failure.Exception.Message)"
}

try {
    $checkout = Join-Path $testRoot "checkout"
    $null = New-Item -ItemType Directory -Path (Join-Path $checkout "scripts"), (Join-Path $checkout "demo"), (Join-Path $checkout "docs\specs")
    Copy-Item -LiteralPath (Join-Path $root "demo\workiq-prompt.md") -Destination (Join-Path $checkout "demo")
    Copy-Item -LiteralPath (Join-Path $root "demo\draft-pr-body.md") -Destination (Join-Path $checkout "demo")
    Copy-Item -LiteralPath (Join-Path $root "scripts\validate-prd.ps1") -Destination (Join-Path $checkout "scripts")
    Copy-Item -LiteralPath (Join-Path $root "docs\specs\prd-template.md") -Destination (Join-Path $checkout "docs\specs")
    Copy-Item -LiteralPath (Join-Path $root ".gitignore") -Destination $checkout

    $scriptPath = Join-Path $root "scripts\present-demo.ps1"
    $tokens = $null
    $parseErrors = $null
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($scriptPath, [ref]$tokens, [ref]$parseErrors)
    Assert-Test ($parseErrors.Count -eq 0) "Walkthrough must parse without errors"
    # Replace only the interactive key reader in the test copy; production pauses remain intact.
    $pause = $ast.Find({ param($node)
        $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq "Pause-Demo"
    }, $true)
    Assert-Test ($null -ne $pause) "Pause function must exist"
    $source = Get-Content -LiteralPath $scriptPath -Raw
    $testSource = $source.Substring(0, $pause.Extent.StartOffset) +
        'function Pause-Demo { param([string]$Message) Write-Host "[TEST KEY PRESS] $Message"; if ($global:DemoTestOnPause) { & $global:DemoTestOnPause } }' +
        $source.Substring($pause.Extent.EndOffset)
    $testScript = Join-Path $checkout "scripts\present-demo.ps1"
    Set-Content -LiteralPath $testScript -Value $testSource

    function global:Read-Host {
        param([string]$Prompt)
        if ($global:DemoTestAnswers.Count -eq 0) { throw "Unexpected confirmation: $Prompt" }
        return $global:DemoTestAnswers.Dequeue()
    }
    function global:gh {
        $global:DemoTestGhCalls.Add(($args -join " "))
        $global:LASTEXITCODE = 0
        if ($args[0] -eq "repo" -and $args[1] -eq "view") {
            return '{"nameWithOwner":"test-owner/working-demo","defaultBranchRef":{"name":"main"},"visibility":"' + $global:DemoTestVisibility + '"}'
        }
        if ($args[0] -eq "pr" -and $args[1] -eq "list") { return "[]" }
        if ($args[0] -eq "pr" -and $args[1] -eq "create") { return "https://github.com/test-owner/working-demo/pull/1" }
        if ($args[0] -eq "pr" -and $args[1] -eq "view") {
            if ($args -contains "--web") { return }
            return '{"url":"https://github.com/test-owner/working-demo/pull/1","isDraft":true,"files":[{"path":"docs/specs/intelligent-escalation-prd.md"}]}'
        }
        throw "Unexpected GitHub command in test: $args"
    }

    Set-Location $checkout
    $envPath = Join-Path $checkout ".env"
    $validEnv = @'
BUSINESS_BRIEF_URL="https://documents.example/brief?one=1&two=2"
DECISION_TRANSCRIPT_URL='https://documents.example/decision'
COMPLIANCE_NOTE_URL=https://documents.example/compliance
'@
    Set-Content -LiteralPath $envPath -Value $validEnv
    & $testScript -PrepareOnly
    $prompt = Get-Content -LiteralPath (Join-Path $checkout ".local\workiq-prompt.txt") -Raw
    Assert-Test ($prompt.Contains("https://documents.example/brief?one=1&two=2")) "Query string must be preserved"
    Assert-Test ($prompt -notmatch '\$\{|(?m)^>') "Variables and quote prefixes must be removed"
    foreach ($case in @(
        @{ Text = $validEnv.Replace("https://documents.example/compliance", "{{https://documents.example/compliance}}"); Error = "Invalid COMPLIANCE_NOTE_URL" },
        @{ Text = $validEnv.Replace("https://documents.example/compliance", "https://onedrive.example/:f:/folder"); Error = "Invalid COMPLIANCE_NOTE_URL" },
        @{ Text = $validEnv.Replace("https://documents.example/compliance", "https://example.invalid/replace"); Error = "Invalid COMPLIANCE_NOTE_URL" },
        @{ Text = $validEnv + "`nBUSINESS_BRIEF_URL=https://documents.example/duplicate"; Error = "Duplicate" },
        @{ Text = "BUSINESS_BRIEF_URL=https://documents.example/brief"; Error = "Missing" },
        @{ Text = $validEnv + "`nOTHER_VALUE=oops"; Error = "Unsupported" }
    )) {
        Set-Content -LiteralPath $envPath -Value $case.Text
        Expect-Failure { & $testScript -PrepareOnly } $case.Error
    }
    Set-Content -LiteralPath $envPath -Value $validEnv

    Invoke-TestGit init -b main
    Invoke-TestGit config user.name "Walkthrough Test"
    Invoke-TestGit config user.email "walkthrough@example.invalid"
    Invoke-TestGit config commit.gpgsign false
    Invoke-TestGit add .
    Invoke-TestGit commit -m "Test starter"
    $bare = Join-Path $testRoot "remote.git"
    Invoke-TestGit init --bare $bare
    Invoke-TestGit remote add origin https://github.com/test-owner/working-demo.git
    $bareUri = ([uri]($bare + [IO.Path]::DirectorySeparatorChar)).AbsoluteUri
    Invoke-TestGit config "url.$bareUri.insteadOf" https://github.com/test-owner/working-demo.git
    Invoke-TestGit push -u origin main

    $prd = Join-Path $checkout "docs\specs\intelligent-escalation-prd.md"
    Expect-Failure { & $testScript -ResumeAfterGeneration -NoPublish } "PRD not found"
    $fixture = "> SANITIZED REHEARSAL COPY`n`n" +
        (Get-Content -LiteralPath (Join-Path $root "demo\fallback\intelligent-escalation-prd.expected.md") -Raw)
    Set-Content -LiteralPath $prd -Value $fixture
    & $testScript -ResumeAfterGeneration -NoPublish
    Assert-Test ((Invoke-TestGit branch --show-current) -eq "main") "NoPublish must not create a branch"
    Assert-Test (-not (Invoke-TestGit diff --cached --name-only)) "NoPublish must not stage"
    Assert-Test ($global:DemoTestGhCalls.Count -eq 0) "NoPublish must not contact GitHub"
    Expect-Failure { & $testScript -NoPublish } "PRD already exists"
    Expect-Failure { & $testScript -ResumeAfterGeneration -Repository "wrong/repository" } "origin does not match"

    Set-Content -LiteralPath (Join-Path $checkout "unexpected.txt") -Value "Unrelated work"
    Expect-Failure { & $testScript -ResumeAfterGeneration -NoPublish } "Unexpected workspace change"
    Remove-Item -LiteralPath (Join-Path $checkout "unexpected.txt")
    Set-Content -LiteralPath $prd -Value ($fixture + "`nhttps://tenant.sharepoint.com/private")
    Expect-Failure { & $testScript -ResumeAfterGeneration -Repository "test-owner/working-demo" } "Tenant links"
    Assert-Test ((Invoke-TestGit branch --show-current) -eq "main") "Public-link gate must occur before branch creation"
    Set-Content -LiteralPath $prd -Value $fixture

    $global:DemoTestAnswers.Enqueue("NO")
    Expect-Failure { & $testScript -ResumeAfterGeneration -Repository "test-owner/working-demo" } "Not confirmed"
    Assert-Test ((Invoke-TestGit branch --show-current) -eq "main") "Declining must preserve starting branch"

    foreach ($answer in @("YES", "YES", "YES")) { $global:DemoTestAnswers.Enqueue($answer) }
    & $testScript -ResumeAfterGeneration -Repository "test-owner/working-demo" -Branch "spec/test-walkthrough"
    Assert-Test ((Invoke-TestGit branch --show-current) -eq "spec/test-walkthrough") "Specification branch must be created"
    Assert-Test ((Invoke-TestGit diff --name-only main HEAD) -eq "docs/specs/intelligent-escalation-prd.md") "Commit must change only the PRD"
    Assert-Test ([bool](Invoke-TestGit ls-remote --heads origin refs/heads/spec/test-walkthrough)) "Branch must reach temporary remote"
    Assert-Test ([bool]($global:DemoTestGhCalls | Where-Object { $_ -match '^pr create .*--draft' })) "PR must be draft"
    $body = Get-Content -LiteralPath (Join-Path $checkout ".local\draft-pr-body.md") -Raw
    Assert-Test ($body -match 'SANITIZED REHEARSAL COPY') "PR body must preserve rehearsal disclosure"
    Assert-Test (-not (Invoke-TestGit ls-files -- .env .local)) "Local source configuration must remain untracked"

    Invoke-TestGit switch main
    $global:DemoTestPauseCount = 0
    $global:DemoTestOnPause = {
        $global:DemoTestPauseCount++
        if ($global:DemoTestPauseCount -eq 2) {
            # Simulate the manual Copilot handoff producing the requested file.
            Set-Content -LiteralPath $prd -Value $fixture
        }
    }.GetNewClosure()
    $global:DemoTestAnswers.Enqueue("")
    & $testScript -NoPublish
    Assert-Test ($global:DemoTestPauseCount -eq 6) "Full story, handoff, review and validation must each pause"
    Assert-Test ((Invoke-TestGit branch --show-current) -eq "main") "Fresh NoPublish flow must not create a branch"
    $global:DemoTestOnPause = $null
    Set-Content -LiteralPath $prd -Value $fixture.Replace("## Superseded decisions", "## Wrong heading")
    Expect-Failure { & $testScript -ResumeAfterGeneration -NoPublish } "PRD section missing"
    Set-Content -LiteralPath $prd -Value $fixture.Replace("**Given**", "Precondition")
    Expect-Failure { & $testScript -ResumeAfterGeneration -NoPublish } "pwsh failed"
    Write-Host "All walkthrough tests passed: rendering, invalid input, review, guards, confirmation, commit, push, and draft PR." -ForegroundColor Green
}
finally {
    Set-Location $originalLocation
    Remove-Item Function:\Read-Host -ErrorAction SilentlyContinue
    Remove-Item Function:\gh -ErrorAction SilentlyContinue
    if ($originalReadHost) { Set-Item Function:\Read-Host -Value $originalReadHost.ScriptBlock }
    if ($originalGh) { Set-Item Function:\gh -Value $originalGh.ScriptBlock }
    # Only the explicitly created, GUID-named test folder is removed.
    Remove-Item -LiteralPath $testRoot -Recurse -Force
    Remove-Variable DemoTestAnswers,DemoTestGhCalls,DemoTestVisibility,DemoTestOnPause -Scope Global
    Remove-Variable DemoTestPauseCount -Scope Global -ErrorAction SilentlyContinue
}
