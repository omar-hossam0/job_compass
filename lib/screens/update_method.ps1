[string[]]$lines = @(Get-Content home_dashboard_screen.dart)
Write-Host "Original file: $($lines.Count) lines"

# Find where _getAllJobs starts
$methodStart = -1
for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -like "*_getAllJobs()*") {
        $methodStart = $i
        break
    }
}

# Find where it ends
$methodEnd = -1
for ($i = $methodStart + 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -like "*_toggleSaveJob*") {
        $methodEnd = $i - 2
        break
    }
}

Write-Host "Method start: $methodStart, end: $methodEnd"

if ($methodStart -ge 0 -and $methodEnd -gt $methodStart) {
    $newLines = @()
    $newLines += $lines[0..($methodStart-1)]
    $newLines += "  List<Map<String, dynamic>> _getAllJobs() {"
    $newLines += "    return JobsData.allJobs.map((job) {"
    $newLines += "      final jobCopy = Map<String, dynamic>.from(job);"
    $newLines += "      jobCopy['logo'] = JobsData.getCompanyLogo(job['company']);"
    $newLines += "      jobCopy['logoColor'] = JobsData.getCompanyColor(job['company']);"
    $newLines += "      return jobCopy;"
    $newLines += "    }).toList();"
    $newLines += "  }"
    $newLines += ""
    $newLines += $lines[$methodEnd..$($lines.Count-1)]
    
    $newLines | Set-Content home_dashboard_screen.dart
    Write-Host "File updated! New line count: $($newLines.Count)"
}
