const { execSync } = require('child_process');
const path = require('path');

module.exports = async () => {
  console.log('Starting test server...');

  // Kill any existing http-server instances
  try {
    execSync('pkill -f http-server', { stdio: 'ignore' });
  } catch (e) {
    // Ignore if no process found
  }

  // Start http-server in the background
  const { spawn } = require('child_process');
  const serverProcess = spawn('npx', ['http-server', '-p', '8080', '--silent'], {
    detached: true,
    stdio: 'ignore',
    cwd: __dirname
  });

  serverProcess.unref();

  // Save PID for cleanup
  require('fs').writeFileSync(path.join(__dirname, '.server.pid'), serverProcess.pid.toString());

  // Wait for server to be ready
  await new Promise(resolve => setTimeout(resolve, 2000));

  console.log('Test server started on http://localhost:8080');
};
