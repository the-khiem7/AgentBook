$timeline = @(
    @{
        Message = "chore: initial setup"
        Date    = "YYYY-MM-DDTHH:mm:ss"
        Files   = @(
            "path/to/file1",
            "path/to/file2"
        )
    },
    @{
        Message = "feat: add core feature"
        Date    = "YYYY-MM-DDTHH:mm:ss"
        Files   = @(
            "path/to/feature-file.cs",
            "path/to/feature-tests.cs"
        )
    }
    # Add more stages as needed
)

foreach ($stage in $timeline) {
    Write-Host "`n=== $($stage.Message) @ $($stage.Date)"
    $missing = @($stage.Files | Where-Object { -not (Test-Path $_) })
    if ($missing.Count -gt 0) {
        Write-Warning "Skipping stage because the following files were not found:`n$($missing -join [Environment]::NewLine)"
        continue
    }

    $stageFiles = $stage.Files
    $ignored = @()
    foreach ($file in $stage.Files) {
        git check-ignore --quiet -- $file *> $null
        if ($LASTEXITCODE -eq 0) {
            $ignored += $file
        }
    }
    if ($ignored.Count -gt 0) {
        Write-Warning "Ignoring files excluded by .gitignore:`n$($ignored -join [Environment]::NewLine)"
        $stageFiles = @($stageFiles | Where-Object { $ignored -notcontains $_ })
        if ($stageFiles.Count -eq 0) {
            Write-Warning "No remaining files to commit for this stage; skipping."
            continue
        }
    }

    git status -sb -- $stageFiles | Out-Host
    Read-Host "Review & edit listed files, press Enter to stage"

    git add -- $stageFiles
    if ($LASTEXITCODE -ne 0) {
        throw "git add failed for stage '$($stage.Message)'"
    }

    $env:GIT_AUTHOR_DATE = $stage.Date
    $env:GIT_COMMITTER_DATE = $stage.Date

    git commit -m $stage.Message | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "git commit failed for stage '$($stage.Message)'"
    }
}

Remove-Item Env:\GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
Remove-Item Env:\GIT_COMMITTER_DATE -ErrorAction SilentlyContinue

Write-Host "`nTimeline replay finished. Inspect with 'git log --stat --decorate"