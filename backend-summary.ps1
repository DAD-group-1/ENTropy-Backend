$org = "DAD-group-1"
$commits = @{ }
$repoCommits = @{ }

$rawJson = gh repo list $org --limit 200 --json nameWithOwner
$repos = ($rawJson | ConvertFrom-Json).nameWithOwner

foreach ($repo in $repos)
{
    Write-Host "Processing $repo..."

    $contributors = gh api repos/$repo/contributors --paginate 2> $null |
            ConvertFrom-Json

    $repoTotal = 0

    foreach ($c in $contributors)
    {
        $repoTotal += $c.contributions

        if ( $commits.ContainsKey($c.login))
        {
            $commits[$c.login] += $c.contributions
        }
        else
        {
            $commits[$c.login] = $c.contributions
        }
    }

    $repoCommits[$repo] = $repoTotal
}

$totalCommits = ($commits.Values | Measure-Object -Sum).Sum

$resultByUser = $commits.GetEnumerator() |
        Sort-Object Value -Descending |
        Select-Object @{ N = "User"; E = { $_.Key } }, @{ N = "Commits"; E = { $_.Value } }

$resultByRepo = $repoCommits.GetEnumerator() |
        Sort-Object Value -Descending |
        Select-Object @{ N = "Repository"; E = { $_.Key } }, @{ N = "Commits"; E = { $_.Value } }

Write-Host "`n--- Commits by User ---"
$resultByUser | Format-Table -AutoSize

Write-Host "`n--- Commits by Repository ---"
$resultByRepo | Format-Table -AutoSize

Write-Host "Number of repositories : $( $repos.Count )"
Write-Host "Number of contributors : $( $commits.Count )"
Write-Host "Total commits          : $totalCommits"