# start_flask_and_docker.ps1

# Function to check for admin privileges
function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

# Check if script is running with elevated permissions (admin)
if (-not (Test-Administrator)) {
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
$flaskScriptPath = "C:\path\to\your\command_executor_host.py"  # Path to the Flask API script
$dockerImageName = "command-executor-flask"
$dockerContainerName = "command-executor-container"
$windowsEnvVars = @("GIT_TOKEN", "JIRA_TOKEN", "JENKINS_TOKEN")  # Specific tokens to pass

# Directories to mount: "HostPath:ContainerPath"
$mounts = @(
    "C:/Workspaces:/container/workspaces",
    "Z:/git:/container/git",
    "Z:/.ssh:/container/ssh",
    "C:/.m2/repository:/container/m2_repo",
    "Z:/.m2:/container/m2",
    "C:/Users/username/.m2:/container/user_m2",
    "C:/Users/username/.ssh:/container/user_ssh"
)

# Step 1: Start the Flask API
Write-Host "Starting Flask API..."
Start-Process -FilePath "python.exe" -ArgumentList "`"$flaskScriptPath`"" -NoNewWindow

# Step 2: Build the Docker image
Write-Host "Building Docker image..."
docker build -t $dockerImageName .

# Step 3: Stop existing Docker container if running
$runningContainer = docker ps -q --filter "name=$dockerContainerName"
if ($runningContainer) {
    Write-Host "Stopping existing Docker container..."
    docker stop $dockerContainerName
    docker rm $dockerContainerName
}

# Step 4: Prepare environment variables to pass to Docker
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

# Step 5: Prepare mount arguments for Docker
$mountArgs = ""
foreach ($mount in $mounts) {
    $mountArgs += "-v $mount "
}

# Step 6: Run the Docker container with environment variables and mounted directories
Write-Host "Running Docker container..."
docker run -d `
    --name $dockerContainerName `
    $envVarsArgs `
    $mountArgs `
    -e FLASK_PORT=5000 `
    $dockerImageName

Write-Host "Flask API started, Docker container is running, and directories are mounted."
