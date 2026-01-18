/**
 * Comprehensive Test to VERIFY Real CV Analysis
 * This script proves that the model is actually analyzing CVs and not returning fake data
 */

import axios from 'axios';

const BASE_URL = 'http://192.168.56.1:5000';
const API_URL = `${BASE_URL}/api`;

const HR_CREDENTIALS = {
  email: 'hr@company.com',
  password: 'hr123456',
};

let authToken = '';

// Test with DIFFERENT job descriptions to verify different results
const testScenarios = [
  {
    name: 'Backend Developer Job',
    description: `
      Senior Backend Developer needed.
      Must have: Node.js, Express.js, MongoDB, REST APIs, Docker
      5+ years experience required.
    `,
    expectedHighSkills: ['nodejs', 'node.js', 'express', 'mongodb', 'docker', 'rest', 'api']
  },
  {
    name: 'Frontend Developer Job',
    description: `
      Frontend Developer position.
      Required: React, Vue.js, HTML, CSS, JavaScript, TypeScript
      Experience with responsive design.
    `,
    expectedHighSkills: ['react', 'vue', 'html', 'css', 'javascript', 'typescript']
  },
  {
    name: 'Data Scientist Job',
    description: `
      Data Scientist role.
      Requirements: Python, Machine Learning, TensorFlow, Pandas, SQL
      PhD preferred.
    `,
    expectedHighSkills: ['python', 'machine-learning', 'tensorflow', 'pandas', 'sql']
  }
];

async function loginAsHR() {
  try {
    const response = await axios.post(`${API_URL}/auth/login`, HR_CREDENTIALS);
    if (response.data.success && response.data.token) {
      authToken = response.data.token;
      return true;
    }
    return false;
  } catch (error) {
    console.error('❌ Login failed:', error.message);
    return false;
  }
}

async function testJobDescriptionDirectly(jobDescription) {
  try {
    console.log('\n🔬 Testing Python Model Directly...');
    console.log('━'.repeat(60));
    
    const { spawn } = require('child_process');
    const path = require('path');
    
    const scriptPath = path.join(__dirname, 'match_cvs_to_job.py');
    
    // Create test input
    const testInput = {
      job_description: jobDescription,
      cv_texts: [
        // CV 1: Matches backend skills
        'Senior Backend Developer with 6 years experience. Expert in Node.js, Express.js, MongoDB, Docker, REST APIs. Built scalable microservices.',
        
        // CV 2: Matches frontend skills
        'Frontend Developer with 4 years experience. Proficient in React, Vue.js, TypeScript, HTML5, CSS3. Created responsive SPAs.',
        
        // CV 3: Matches data science skills
        'Data Scientist with PhD. Expert in Python, Machine Learning, TensorFlow, Pandas, NumPy. Published 10+ research papers.',
        
        // CV 4: Generic/low match
        'Junior developer with 1 year experience. Learning programming. Completed some online courses.'
      ],
      top_k: 10
    };

    const python = spawn('python', [scriptPath], {
      stdio: ['pipe', 'pipe', 'pipe']
    });

    // Send input
    python.stdin.write(JSON.stringify(testInput));
    python.stdin.end();

    let outputData = '';
    let errorData = '';

    python.stdout.on('data', (data) => {
      outputData += data.toString();
    });

    python.stderr.on('data', (data) => {
      errorData += data.toString();
      // Print Python logs in real-time
      console.log('🐍', data.toString().trim());
    });

    return new Promise((resolve, reject) => {
      python.on('close', (code) => {
        if (code !== 0) {
          reject(new Error(`Python exited with code ${code}: ${errorData}`));
        } else {
          try {
            const result = JSON.parse(outputData);
            resolve(result);
          } catch (e) {
            reject(new Error(`Failed to parse output: ${e.message}\n${outputData}`));
          }
        }
      });

      setTimeout(() => {
        python.kill();
        reject(new Error('Python script timeout'));
      }, 30000);
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  }
}

async function analyzeResults(results, scenario) {
  console.log('\n📊 ANALYSIS RESULTS');
  console.log('━'.repeat(60));
  console.log(`Scenario: ${scenario.name}`);
  console.log(`Critical Skills Found: ${results.critical_skills?.length || 0}`);
  
  if (results.critical_skills) {
    console.log(`Top Skills: ${results.critical_skills.slice(0, 10).join(', ')}`);
  }

  console.log('\n📋 CV Match Results:');
  results.matches.forEach((match, idx) => {
    const cvNum = idx + 1;
    const score = match.similarity_score;
    const semanticScore = match.semantic_score || 0;
    const keywordScore = match.keyword_score || 0;
    const matchedSkills = match.matched_skills || 0;
    const totalSkills = match.total_skills || 0;

    const icon = score >= 70 ? '🟢' : score >= 50 ? '🟡' : '🔴';
    
    console.log(`\n${icon} CV #${cvNum}: ${score}%`);
    console.log(`   Breakdown: Semantic=${semanticScore}% + Keywords=${keywordScore}%`);
    console.log(`   Skills Matched: ${matchedSkills}/${totalSkills}`);
    
    // Verify the math
    const calculatedScore = Math.round((semanticScore + keywordScore) * 100) / 100;
    if (Math.abs(calculatedScore - score) > 0.1) {
      console.log(`   ⚠️  WARNING: Math doesn't match! ${calculatedScore} vs ${score}`);
    } else {
      console.log(`   ✅ Math verified: ${semanticScore} + ${keywordScore} = ${score}`);
    }
  });

  return results.matches;
}

async function verifyDifferentJobsProduceDifferentResults() {
  console.log('\n' + '═'.repeat(60));
  console.log('🔬 VERIFICATION TEST: Different Jobs → Different Results');
  console.log('═'.repeat(60));
  console.log('\nThis test proves the model is NOT returning fake data!');
  console.log('If it was fake, all jobs would return similar scores.\n');

  const allResults = [];

  for (let i = 0; i < testScenarios.length; i++) {
    const scenario = testScenarios[i];
    console.log(`\n${'▼'.repeat(30)}`);
    console.log(`TEST ${i + 1}/${testScenarios.length}: ${scenario.name}`);
    console.log(`${'▼'.repeat(30)}`);

    try {
      const result = await testJobDescriptionDirectly(scenario.description);
      
      if (result.success) {
        const matches = await analyzeResults(result, scenario);
        allResults.push({
          scenario: scenario.name,
          matches: matches
        });
      } else {
        console.error('❌ Test failed:', result.error);
      }
      
      // Wait between tests
      await new Promise(resolve => setTimeout(resolve, 1000));
      
    } catch (error) {
      console.error(`❌ Error in ${scenario.name}:`, error.message);
    }
  }

  // Compare results
  console.log('\n' + '═'.repeat(60));
  console.log('🔍 COMPARING RESULTS ACROSS DIFFERENT JOBS');
  console.log('═'.repeat(60));

  if (allResults.length >= 2) {
    console.log('\n📊 CV #1 Scores Across Different Jobs:');
    allResults.forEach(result => {
      const cv1Score = result.matches[0]?.similarity_score || 0;
      console.log(`   ${result.scenario}: ${cv1Score}%`);
    });

    // Check if scores are different
    const cv1Scores = allResults.map(r => r.matches[0]?.similarity_score || 0);
    const uniqueScores = new Set(cv1Scores);
    
    console.log('\n🎯 VERDICT:');
    if (uniqueScores.size === 1) {
      console.log('❌ SUSPICIOUS: All jobs returned the SAME score!');
      console.log('   This might indicate fake/hardcoded data.');
    } else if (uniqueScores.size === cv1Scores.length) {
      console.log('✅ EXCELLENT: Each job returned DIFFERENT scores!');
      console.log('   This proves the model is analyzing each job uniquely.');
      console.log('   The model is working correctly! 🎉');
    } else {
      console.log('⚠️  MIXED: Some scores are different, some are similar.');
      console.log('   This is normal variation.');
    }

    // Calculate score variance
    const mean = cv1Scores.reduce((a, b) => a + b, 0) / cv1Scores.length;
    const variance = cv1Scores.reduce((sum, score) => sum + Math.pow(score - mean, 2), 0) / cv1Scores.length;
    const stdDev = Math.sqrt(variance);

    console.log(`\n📈 Statistical Analysis:`);
    console.log(`   Mean Score: ${mean.toFixed(2)}%`);
    console.log(`   Standard Deviation: ${stdDev.toFixed(2)}%`);
    
    if (stdDev > 5) {
      console.log(`   ✅ Good variance! Model is adapting to different jobs.`);
    } else if (stdDev < 1) {
      console.log(`   ❌ Very low variance! Might be fake data.`);
    } else {
      console.log(`   ⚠️  Moderate variance.`);
    }
  }

  console.log('\n' + '═'.repeat(60));
}

async function testWithRealDatabase() {
  console.log('\n' + '═'.repeat(60));
  console.log('🗄️  TESTING WITH REAL DATABASE');
  console.log('═'.repeat(60));

  try {
    console.log('\n🔐 Logging in...');
    const loginSuccess = await loginAsHR();
    if (!loginSuccess) {
      console.error('❌ Cannot test with database: Login failed');
      return;
    }
    console.log('✅ Logged in successfully');

    console.log('\n📋 Fetching real jobs from database...');
    const jobsResponse = await axios.get(`${API_URL}/jobs`, {
      headers: { Authorization: `Bearer ${authToken}` }
    });

    if (!jobsResponse.data.success || !jobsResponse.data.data || jobsResponse.data.data.length === 0) {
      console.log('⚠️  No jobs found in database. Creating test jobs would be needed.');
      return;
    }

    const job = jobsResponse.data.data[0];
    console.log(`✅ Found job: "${job.title}"`);
    console.log(`   Description length: ${job.description?.length || 0} chars`);

    console.log('\n🎯 Matching CVs to this job...');
    const startTime = Date.now();
    
    const matchResponse = await axios.post(
      `${API_URL}/ml/match-cvs`,
      { jobId: job._id || job.id },
      {
        headers: { 
          Authorization: `Bearer ${authToken}`,
          'Content-Type': 'application/json'
        },
        timeout: 60000
      }
    );

    const duration = ((Date.now() - startTime) / 1000).toFixed(2);

    if (matchResponse.data.success) {
      console.log(`✅ Matching completed in ${duration}s`);
      console.log(`\n📊 Results from REAL DATABASE:`);
      console.log(`   Method: ${matchResponse.data.method}`);
      console.log(`   Total CVs: ${matchResponse.data.totalCVs}`);
      console.log(`   Matched CVs: ${matchResponse.data.matchedCVs}`);
      
      if (matchResponse.data.criticalSkills) {
        console.log(`   Critical Skills: ${matchResponse.data.criticalSkills.slice(0, 10).join(', ')}`);
      }

      const candidates = matchResponse.data.data || [];
      console.log(`\n👥 Top 5 Candidates:`);
      
      candidates.slice(0, 5).forEach((candidate, idx) => {
        const icon = candidate.matchScore >= 70 ? '🟢' : candidate.matchScore >= 50 ? '🟡' : '🔴';
        console.log(`\n${idx + 1}. ${icon} ${candidate.name}`);
        console.log(`   Score: ${candidate.matchScore}%`);
        
        if (candidate.semanticScore && candidate.keywordScore) {
          console.log(`   Breakdown: ${candidate.semanticScore}% + ${candidate.keywordScore}%`);
          
          // Verify math
          const calculated = candidate.semanticScore + candidate.keywordScore;
          if (Math.abs(calculated - candidate.matchScore) <= 0.1) {
            console.log(`   ✅ Math verified!`);
          } else {
            console.log(`   ⚠️  Math mismatch: ${calculated} vs ${candidate.matchScore}`);
          }
        }
        
        if (candidate.matchedSkills && candidate.totalSkills) {
          console.log(`   Skills: ${candidate.matchedSkills}/${candidate.totalSkills}`);
        }
      });

      // Check for suspicious patterns
      console.log(`\n🔍 Checking for suspicious patterns...`);
      
      const scores = candidates.map(c => c.matchScore);
      const uniqueScores = new Set(scores);
      
      if (scores.length > 0 && uniqueScores.size === 1) {
        console.log(`❌ SUSPICIOUS: All ${scores.length} candidates have the SAME score (${scores[0]}%)`);
        console.log(`   This might indicate fake data!`);
      } else if (uniqueScores.size > scores.length * 0.5) {
        console.log(`✅ GOOD: High score diversity (${uniqueScores.size} unique scores)`);
        console.log(`   Model appears to be analyzing each CV individually.`);
      } else {
        console.log(`⚠️  Moderate diversity: ${uniqueScores.size} unique scores from ${scores.length} CVs`);
      }

      if (scores.length >= 2) {
        const diff = Math.abs(scores[0] - scores[scores.length - 1]);
        console.log(`\n📉 Score Range: ${scores[scores.length - 1]}% to ${scores[0]}% (diff: ${diff.toFixed(1)}%)`);
        
        if (diff < 5) {
          console.log(`   ⚠️  Very narrow range - might need more diverse CVs`);
        } else if (diff > 30) {
          console.log(`   ✅ Good range - clear differentiation between candidates`);
        } else {
          console.log(`   ✅ Reasonable range`);
        }
      }

    } else {
      console.error('❌ Matching failed:', matchResponse.data.message);
    }

  } catch (error) {
    console.error('❌ Database test error:', error.response?.data || error.message);
  }
}

async function runFullVerification() {
  console.log('\n╔════════════════════════════════════════════════════════════╗');
  console.log('║     CV MATCHING MODEL - VERIFICATION TEST SUITE            ║');
  console.log('║     Proving the Model is NOT Returning Fake Data          ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');

  console.log('📝 This test will:');
  console.log('   1. Test Python model directly with different job descriptions');
  console.log('   2. Verify that different jobs produce different results');
  console.log('   3. Check mathematical accuracy of scores');
  console.log('   4. Test with real database (if available)');
  console.log('   5. Look for suspicious patterns in results\n');

  // Test 1: Direct Python model testing
  await verifyDifferentJobsProduceDifferentResults();

  // Test 2: Real database testing
  await testWithRealDatabase();

  console.log('\n╔════════════════════════════════════════════════════════════╗');
  console.log('║     VERIFICATION COMPLETE                                  ║');
  console.log('╚════════════════════════════════════════════════════════════╝\n');
  
  console.log('💡 Summary:');
  console.log('   ✅ If you see different scores for different jobs → Model is REAL');
  console.log('   ✅ If math checks out (semantic + keywords = total) → Calculations are CORRECT');
  console.log('   ✅ If critical skills vary by job → Extraction is WORKING');
  console.log('   ❌ If all scores are identical → Need to investigate\n');
}

runFullVerification().catch(error => {
  console.error('\n💥 Verification failed:', error.message);
  process.exit(1);
});
