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
 


