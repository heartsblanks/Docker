# Check if script is running with elevated permissions (admin)
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Script is not running with elevated permissions. Restarting with elevated permissions..."

    # Prompt for credentials (username and password)
    $credentials = Get-Credential

    # Restart the script with elevated permissions using the provided credentials
    Start-Process -FilePath "powershell.exe" `
                  -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
                  -Credential $credentials `
                  -Verb RunAs
    exit
}

# Variables
$flaskScriptPath = "C:\path\to\your\command_executor.py"  # Path to the Flask API script
$dockerImageName = "command-executor-flask"
$dockerContainerName = "command-executor-container"
$windowsEnvVars = @("GIT_TOKEN", "JIRA_TOKEN", "JENKINS_TOKEN")  # Specific tokens to pass

# Step 1: Build the Docker image
Write-Host "Building Docker image..."
docker build -t $dockerImageName .

# Step 2: Stop existing Docker container if running
$runningContainer = docker ps -q --filter "name=$dockerContainerName"
if ($runningContainer) {
    Write-Host "Stopping existing Docker container..."
    docker stop $dockerContainerName
    docker rm $dockerContainerName
}

# Step 3: Prepare environment variables to pass to Docker
$envVarsArgs = ""
foreach ($envVar in $windowsEnvVars) {
    $envValue = [System.Environment]::GetEnvironmentVariable($envVar)
    if ($envValue) {
        Write-Host "Passing environment variable: $envVar"
        $envVarsArgs += "-e $envVar=`"$envValue`" "
    } else {
        Write-Host "$envVar is not set in the environment."
    }
}

# Step 4: Run the Docker container with environment variables
Write-Host "Running Docker container..."
docker run -d `
    --name $dockerContainerName `
    $envVarsArgs `
    -e FLASK_PORT=5000 `
    $dockerImageName python /usr/src/app/command_executor.py

Write-Host "Flask API started, Docker container is running."
