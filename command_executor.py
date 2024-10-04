from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/run-command', methods=['POST'])
def run_command():
    # Get the command from the POST request
    command = request.json.get('command')
    
    if command:
        try:
            # Execute the command using subprocess
            result = subprocess.run(command, shell=True, capture_output=True, text=True)
            return jsonify({
                'output': result.stdout,
                'error': result.stderr,
                'exit_code': result.returncode
            }), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    else:
        return jsonify({'error': 'No command provided'}), 400

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
