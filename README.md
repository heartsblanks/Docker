Enable PowerShell Remoting:
	•	Open PowerShell as Administrator and run:
Enable-PSRemoting -Force

Allow PowerShell Remoting over HTTPS (optional but recommended for security):
	•	Set up an HTTPS listener for remoting:
New-PSSessionConfigurationFile -Path C:\Path\To\HTTPS.pssc
Register-PSSessionConfiguration -Path C:\Path\To\HTTPS.pssc -Name HTTPS-Listener -Force



Step 4: Testing the API

Now that the Flask API is running, you can test the PowerShell Remoting API by sending commands to the Flask API in the container, which will then execute on the Windows host.

Example curl request to run a command:

# To check the location of git on the Windows host
curl -X POST http://localhost:5000/run-command -H "Content-Type: application/json" -d '{"command": "Get-Command git"}'

# To check the location of maven on the Windows host
curl -X POST http://localhost:5000/run-command -H "Content-Type: application/json" -d '{"command": "Get-Command mvn"}'

Expected JSON Response:

{
    "output": "Path to git",
    "error": "",
    "exit_code": 0
}

Flask in Windows 

Testing the Setup

1. Verify Flask API is Running

After running the PowerShell script, ensure that the Flask API is running:

	•	Access via Browser or curl:
	•	Open a browser and navigate to http://localhost:5000/run-command.
	•	It should return a 400 Bad Request with {"error": "No command provided"} since no command is sent.
	•	Test a Command:
Use curl or any HTTP client to send a POST request to execute a command, such as Get-Command git:
curl -X POST http://localhost:5000/run-command -H "Content-Type: application/json" -d "{\"command\": \"Get-Command git\"}"

Expected Response:
{
    "output": "CommandType     Name                                               Version    Source\n-----------     ----                                               -------    ------\nApplication    git.exe                                            2.30.0.2   C:\\Program Files\\Git\\cmd\\git.exe",
    "error": "",
    "exit_code": 0
}

2. Verify Docker Container is Running

Check if the Docker container is running:
docker ps
You should see command-executor-container listed as running.

3. Access Mounted Directories

Any files cloned or modified in the mounted directories inside the Docker container will be accessible on the Windows host and vice versa. For example, if you clone a Git repository inside the container:

	Inside Docker Container:

git clone https://github.com/your-repo/your-project.git /container/git

On Windows Host:
Navigate to Z:\git to see the cloned repository.

5. Example Use Case

Cloning a Git Repository via Flask API

	1.	Send a Command to Clone a Repository:

curl -X POST http://localhost:5000/run-command -H "Content-Type: application/json" -d "{\"command\": \"git clone https://github.com/your-repo/your-project.git Z:/git/your-project\"}"

	2.	Check on Windows Host:
Navigate to Z:\git\your-project to verify that the repository has been cloned.

Executing Other Commands

You can execute any valid Windows command via the Flask API. For example, to check Maven version:

curl -X POST http://localhost:5000/run-command -H "Content-Type: application/json" -d "{\"command\": \"mvn -version\"}"
{
    "output": "Apache Maven 3.6.3 (cecedd343002696d0abb50b32b541b8a6ba2883f)",
    "error": "",
    "exit_code": 0
}
Testing Inside Docker (Optional)

If you need to run the curl command from inside a Docker container, here’s an example:

# Inside a Docker container
curl -X POST http://host.docker.internal:5000/run-command \
     -H "Content-Type: application/json" \
     -d "{\"command\": \"mvn -version\"}"
















