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
$flaskScriptPath = "C:\path\to\your\ldap_server.py"  # Path to the Flask API script
$dockerImageName = "python-env-flask"
$dockerContainerName = "python-env-flask-container"
$gitRepoPathInContainer = "/usr/src/git_repo"  # Directory in the container for the repo
$gitRepoUrl = "https://github.com/your-repo/your-project.git"  # Git repository to clone
$windowsEnvVars = @("GIT_TOKEN", "JIRA_TOKEN", "JENKINS_TOKEN")  # Specific tokens to pass

# Directories to mount
$mounts = @(
    "C:/Workspaces:/container/workspaces",  # Mount C:/Workspaces to /container/workspaces in container
    "Z:/git:/container/git",                # Mount Z:/git to /container/git in container
    "Z:/.ssh:/container/ssh",               # Mount Z:/.ssh to /container/ssh in container
    "C:/.m2/repository:/container/m2_repo", # Mount C:/.m2/repository to /container/m2_repo in container
    "Z:/.m2:/container/m2",                 # Mount Z:/.m2 to /container/m2 in container
    "C:/Users/username/.m2:/container/user_m2", # Mount C:/Users/username/.m2 to /container/user_m2 in container
    "C:/Users/username/.ssh:/container/user_ssh" # Mount C:/Users/username/.ssh to /container/user_ssh in container
)

# Step 1: Start the Flask API
Write-Host "Starting Flask API..."
Start-Process powershell -ArgumentList "python $flaskScriptPath" -NoNewWindow

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
    $dockerImageName bash -c "git clone $gitRepoUrl $gitRepoPathInContainer && bash"

Write-Host "Flask API started, Docker container is running, and Git repository is cloned."
