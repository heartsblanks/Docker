from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/run-ldap', methods=['POST'])
def run_ldap():
    ldap_command = request.json.get('command')
    if ldap_command:
        try:
            result = subprocess.run(ldap_command, shell=True, capture_output=True, text=True)
            return jsonify({'output': result.stdout, 'error': result.stderr}), 200
        except Exception as e:
            return jsonify({'error': str(e)}), 500
    else:
        return jsonify({'error': 'No command provided'}), 400

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
