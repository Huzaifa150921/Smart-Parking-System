from flask import Flask, jsonify
from flask_cors import CORS
import subprocess
import os

app = Flask(__name__)
CORS(app)

@app.route('/detect_plate', methods=['POST'])
def detect_plate_api():
    print("[DEBUG] Starting number_plate.py subprocess...")
    result = subprocess.run([
        'python', os.path.abspath('../number_plate.py')
    ], capture_output=True, text=True)
    print("[DEBUG] Subprocess finished.")
    print(f"[DEBUG] Subprocess stdout:\n{result.stdout}")
    print(f"[DEBUG] Subprocess stderr:\n{result.stderr}")
    # Try to extract the plate number from stdout (last non-empty line)
    output_lines = result.stdout.strip().splitlines()
    plate_number = ""
    for line in reversed(output_lines):
        if line and "Detected Plate Number:" in line:
            plate_number = line.split("Detected Plate Number:")[-1].strip()
            break
        elif line:
            plate_number = line.strip()
            break
    return jsonify({"plate_number": plate_number, "output": result.stdout, "stderr": result.stderr})

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)