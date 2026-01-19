# Test CV Matcher - Percentage Validation
# Ensures all scores are between 0-100%

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Testing CV Matcher - Percentage Validation" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

Set-Location $PSScriptRoot

Write-Host "🔍 Generating test input and running matcher..." -ForegroundColor Yellow
Write-Host ""

# Run the test
$output = python test_matcher_input.py | python match_cvs_to_job.py 2>&1

# Display output
$output | ForEach-Object {
    if ($_ -match "✅") {
        Write-Host $_ -ForegroundColor Green
    } elseif ($_ -match "⚠️|❌") {
        Write-Host $_ -ForegroundColor Yellow
    } elseif ($_ -match "🎯|📊") {
        Write-Host $_ -ForegroundColor Cyan
    } else {
        Write-Host $_
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Test Complete - Validating Results" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Parse JSON output and validate
$jsonOutput = $output | Where-Object { $_ -match '^\{' } | Select-Object -Last 1

if ($jsonOutput) {
    try {
        $result = $jsonOutput | ConvertFrom-Json
        
        if ($result.success) {
            Write-Host "✅ Test PASSED - Analyzing scores..." -ForegroundColor Green
            Write-Host ""
            
            $allValid = $true
            $result.matches | ForEach-Object {
                $score = $_.similarity_score
                $cvNum = $_.cv_index + 1
                
                if ($score -lt 0 -or $score -gt 100) {
                    Write-Host "❌ CV #$cvNum : $score% - INVALID (out of range 0-100)" -ForegroundColor Red
                    $allValid = $false
                } elseif ($score -ge 75) {
                    Write-Host "🟢 CV #$cvNum : $score% - Excellent Match" -ForegroundColor Green
                } elseif ($score -ge 60) {
                    Write-Host "🟡 CV #$cvNum : $score% - Good Match" -ForegroundColor Yellow
                } elseif ($score -ge 45) {
                    Write-Host "🟠 CV #$cvNum : $score% - Fair Match" -ForegroundColor DarkYellow
                } else {
                    Write-Host "🔴 CV #$cvNum : $score% - Low Match" -ForegroundColor Red
                }
                
                # Show breakdown if available
                if ($_.semantic_score -and $_.keyword_score) {
                    Write-Host "   📊 Breakdown: Semantic=$($_.semantic_score)% + Keywords=$($_.keyword_score)%" -ForegroundColor Gray
                }
                if ($_.matched_skills -and $_.total_skills) {
                    Write-Host "   🎯 Skills: $($_.matched_skills)/$($_.total_skills) matched" -ForegroundColor Gray
                }
            }
            
            Write-Host ""
            if ($allValid) {
                Write-Host "✅ All scores are valid (0-100%)!" -ForegroundColor Green
                Write-Host "✅ Model is working correctly!" -ForegroundColor Green
            } else {
                Write-Host "❌ Some scores are out of range!" -ForegroundColor Red
                Write-Host "⚠️  Please check the model code!" -ForegroundColor Yellow
            }
        } else {
            Write-Host "❌ Test FAILED: $($result.error)" -ForegroundColor Red
        }
    } catch {
        Write-Host "⚠️  Could not parse JSON output" -ForegroundColor Yellow
        Write-Host "Raw output:" -ForegroundColor Gray
        Write-Host $jsonOutput -ForegroundColor Gray
    }
} else {
    Write-Host "❌ No JSON output found!" -ForegroundColor Red
}

Write-Host ""
Write-Host "Expected Results:" -ForegroundColor Cyan
Write-Host "  - All scores should be between 0-100%" -ForegroundColor Gray
Write-Host "  - CV #1 (perfect match): 85-100%" -ForegroundColor Gray
Write-Host "  - CV #2 (good match): 70-85%" -ForegroundColor Gray
Write-Host "  - CV #3 (fair match): 50-70%" -ForegroundColor Gray
Write-Host "  - CV #4 (low match): 30-50%" -ForegroundColor Gray
Write-Host "  - CV #5 (very low): 0-30%" -ForegroundColor Gray
Write-Host ""
