const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

module.exports = async () => {
  console.log('Stopping test server...');

  try {
    execSync('pkill -f http-server', { stdio: 'ignore' });
  } catch (e) {
    // Ignore if no process found
  }

  // Clean up PID file
  const pidFile = path.join(__dirname, '.server.pid');
  if (fs.existsSync(pidFile)) {
    fs.unlinkSync(pidFile);
  }

  console.log('Test server stopped');
};
