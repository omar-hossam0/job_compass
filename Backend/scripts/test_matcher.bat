@echo off
echo ==========================================
echo Testing CV Matcher - Percentage Validation
echo ==========================================
echo.

cd /d "%~dp0"

echo Generating test input and running matcher...
echo.

python test_matcher_input.py | python match_cvs_to_job.py

echo.
echo ==========================================
echo Test Complete
echo ==========================================
echo.
echo Expected Results:
echo - All scores should be between 0-100%%
echo - CV #1 should have highest score (80-95%%)
echo - CV #2 should have good score (60-75%%)
echo - CV #3 should have fair score (45-60%%)
echo - CV #4 should have low score (25-40%%)
echo - CV #5 should have very low score (0-25%%)
echo.
pause
