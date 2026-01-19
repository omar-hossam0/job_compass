/**
 * Test CV Matching with Enhanced Hybrid Weighted Scoring
 * Tests the matchCVsToJob endpoint to ensure proper integration
 */

const axios = require("axios");

// Configuration
const BASE_URL = "http://192.168.56.1:5000";
const API_URL = `${BASE_URL}/api`;

// Test credentials
const HR_CREDENTIALS = {
  email: "hr@company.com",
  password: "hr123456",
};

let authToken = "";
let testJobId = "";

/**
 * Step 1: Login as HR
 */
async function loginAsHR() {
  try {
    console.log("🔐 Logging in as HR...");
    const response = await axios.post(`${API_URL}/auth/login`, HR_CREDENTIALS);

    if (response.data.success && response.data.token) {
      authToken = response.data.token;
      console.log("✅ HR login successful");
      return true;
    } else {
      console.error("❌ Login failed:", response.data.message);
      return false;
    }
  } catch (error) {
    console.error("❌ Login error:", error.response?.data || error.message);
    return false;
  }
}

/**
 * Step 2: Get a test job
 */
async function getTestJob() {
  try {
    console.log("\n📋 Fetching available jobs...");
    const response = await axios.get(`${API_URL}/jobs`, {
      headers: { Authorization: `Bearer ${authToken}` },
    });

    if (
      response.data.success &&
      response.data.data &&
      response.data.data.length > 0
    ) {
      testJobId = response.data.data[0]._id || response.data.data[0].id;
      const jobTitle = response.data.data[0].title;
      console.log(`✅ Found test job: "${jobTitle}" (ID: ${testJobId})`);
      console.log(`   Total jobs available: ${response.data.data.length}`);
      return true;
    } else {
      console.error("❌ No jobs found. Please create a job first.");
      return false;
    }
  } catch (error) {
    console.error(
      "❌ Error fetching jobs:",
      error.response?.data || error.message,
    );
    return false;
  }
}

/**
 * Step 3: Test CV matching
 */
async function testCVMatching() {
  try {
    console.log("\n🎯 Testing CV matching with Hybrid Weighted Scoring...");
    console.log(`   Job ID: ${testJobId}`);

    const startTime = Date.now();

    const response = await axios.post(
      `${API_URL}/ml/match-cvs`,
      { jobId: testJobId },
      {
        headers: {
          Authorization: `Bearer ${authToken}`,
          "Content-Type": "application/json",
        },
        timeout: 60000, // 60 seconds timeout
      },
    );

    const duration = ((Date.now() - startTime) / 1000).toFixed(2);

    if (response.data.success) {
      console.log(`✅ Matching completed in ${duration}s`);
      console.log("\n📊 Results:");
      console.log(`   Job Title: ${response.data.jobTitle}`);
      console.log(`   Matching Method: ${response.data.method || "N/A"}`);
      console.log(`   Total CVs Scanned: ${response.data.totalCVs || 0}`);
      console.log(`   CVs Matched: ${response.data.matchedCVs || 0}`);

      if (
        response.data.criticalSkills &&
        response.data.criticalSkills.length > 0
      ) {
        console.log(`\n🎯 Critical Skills Identified:`);
        console.log(
          `   ${response.data.criticalSkills.slice(0, 15).join(", ")}`,
        );
        if (response.data.criticalSkills.length > 15) {
          console.log(
            `   ... and ${response.data.criticalSkills.length - 15} more`,
          );
        }
      }

      const candidates = response.data.data || [];
      console.log(`\n👥 Top Matching Candidates (${candidates.length}):`);

      if (candidates.length === 0) {
        console.log("   ⚠️  No matching candidates found.");
        console.log("   💡 Make sure candidates have uploaded their CVs.");
      } else {
        candidates.slice(0, 10).forEach((candidate, idx) => {
          const matchIcon =
            candidate.matchScore >= 75
              ? "🟢"
              : candidate.matchScore >= 60
                ? "🟡"
                : "🔴";
          const matchLabel =
            candidate.matchScore >= 75
              ? "Excellent"
              : candidate.matchScore >= 60
                ? "Good"
                : candidate.matchScore >= 45
                  ? "Fair"
                  : "Low";

          console.log(`\n   ${idx + 1}. ${matchIcon} ${candidate.name}`);
          console.log(`      Email: ${candidate.email}`);
          console.log(
            `      ✅ Match Score: ${candidate.matchScore}% (${matchLabel})`,
          );

          // Show breakdown if available
          if (
            candidate.semanticScore !== undefined &&
            candidate.keywordScore !== undefined
          ) {
            console.log(`      📊 Breakdown:`);
            console.log(
              `         - Semantic Similarity: ${candidate.semanticScore}%`,
            );
            console.log(
              `         - Keyword Matching: ${candidate.keywordScore}%`,
            );
          }

          if (
            candidate.matchedSkills !== undefined &&
            candidate.totalSkills !== undefined
          ) {
            console.log(
              `      🎯 Skills Matched: ${candidate.matchedSkills}/${candidate.totalSkills}`,
            );
          }

          if (candidate.skills && candidate.skills.length > 0) {
            console.log(
              `      💼 Skills: ${candidate.skills.slice(0, 5).join(", ")}${candidate.skills.length > 5 ? "..." : ""}`,
            );
          }
        });

        // Statistics
        const avgScore = (
          candidates.reduce((sum, c) => sum + c.matchScore, 0) /
          candidates.length
        ).toFixed(2);
        const excellentMatches = candidates.filter(
          (c) => c.matchScore >= 75,
        ).length;
        const goodMatches = candidates.filter(
          (c) => c.matchScore >= 60 && c.matchScore < 75,
        ).length;
        const fairMatches = candidates.filter(
          (c) => c.matchScore >= 45 && c.matchScore < 60,
        ).length;

        console.log(`\n📈 Match Statistics:`);
        console.log(`   Average Score: ${avgScore}%`);
        console.log(`   Excellent Matches (≥75%): ${excellentMatches}`);
        console.log(`   Good Matches (60-74%): ${goodMatches}`);
        console.log(`   Fair Matches (45-59%): ${fairMatches}`);
      }

      return true;
    } else {
      console.error("❌ Matching failed:", response.data.message);
      return false;
    }
  } catch (error) {
    console.error(
      "❌ Error during matching:",
      error.response?.data || error.message,
    );
    if (error.code === "ECONNABORTED") {
      console.error(
        "   ⏱️  Request timed out. Python script may be taking too long.",
      );
    }
    return false;
  }
}

/**
 * Main test execution
 */
async function runTests() {
  console.log("╔════════════════════════════════════════════════════════════╗");
  console.log("║  CV Matching Test - Hybrid Weighted Scoring System        ║");
  console.log(
    "╚════════════════════════════════════════════════════════════╝\n",
  );

  // Step 1: Login
  const loginSuccess = await loginAsHR();
  if (!loginSuccess) {
    console.error("\n❌ Test failed at login step");
    process.exit(1);
  }

  // Step 2: Get test job
  const jobSuccess = await getTestJob();
  if (!jobSuccess) {
    console.error("\n❌ Test failed at job retrieval step");
    process.exit(1);
  }

  // Step 3: Test matching
  const matchSuccess = await testCVMatching();
  if (!matchSuccess) {
    console.error("\n❌ Test failed at matching step");
    process.exit(1);
  }

  console.log(
    "\n╔════════════════════════════════════════════════════════════╗",
  );
  console.log("║  ✅ All Tests Passed Successfully!                         ║");
  console.log(
    "╚════════════════════════════════════════════════════════════╝\n",
  );

  console.log("💡 Next Steps:");
  console.log("   1. Check HR Dashboard in the Flutter app");
  console.log('   2. Click "Find Matches" on any job');
  console.log("   3. Verify match scores are accurate and not fake data");
  console.log("   4. Confirm critical skills are being identified correctly\n");
}

// Run tests
runTests().catch((error) => {
  console.error("\n💥 Unexpected error:", error);
  process.exit(1);
});
