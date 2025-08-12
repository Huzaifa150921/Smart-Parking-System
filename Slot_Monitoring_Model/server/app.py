from flask import Flask, request, jsonify
from flask_cors import CORS  
from werkzeug.utils import secure_filename
from pymongo import MongoClient
from bson import ObjectId
import os
from dotenv import load_dotenv
import datetime
import cv2
import sys

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app) 


sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'src')))
from src.utils import Park_classifier

# Upload folder
UPLOAD_FOLDER = 'uploads'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# MongoDB setup
MONGO_URI = os.getenv("MONGO_URI")
client = MongoClient(MONGO_URI)
db = client['video_db']
collection = db['videos']

@app.route('/uploads', methods=['POST'])
def upload_video():
    if 'video' not in request.files or 'puid' not in request.form:
        return jsonify({'error': 'Missing video file or PUID'}), 400

    video = request.files['video']
    puid = request.form['puid']

    if video.filename == '':
        return jsonify({'error': 'No selected video file'}), 400

    # Save video locally
    filename = secure_filename(video.filename)
    filepath = os.path.join(UPLOAD_FOLDER, filename)
    video.save(filepath)

    # Save metadata to MongoDB
    video_doc = {
        'puid': puid,
        'filename': filename,
        'filepath': filepath,
        'upload_time': datetime.datetime.utcnow()
    }
    result = collection.insert_one(video_doc)

    return jsonify({
        'message': 'Video uploaded and saved to MongoDB',
        'video_id': str(result.inserted_id)
    }), 200

@app.route('/process', methods=['GET'])
def process_video():
    puid = request.args.get('puid')
    if not puid:
        return jsonify({'error': 'Missing puid'}), 400
    video_doc = collection.find_one({'puid': puid})
    if not video_doc:
        return jsonify({'error': 'Video not found'}), 404
    video_path = video_doc['filepath']
    carp_park_positions_path = os.path.abspath(os.path.join(os.path.dirname(__file__), '../data/source/CarParkPos'))
    rect_width, rect_height = 107, 48
    classifier = Park_classifier(carp_park_positions_path, rect_width, rect_height)
    cap = cv2.VideoCapture(video_path)
    total = len(classifier.car_park_positions)
    free = 0
    occupied = 0
    slots = []
    # Read first frame only for quick demo (or change to last frame, or average, as needed)
    ret, frame = cap.read()
    if not ret:
        cap.release()
        return jsonify({'error': 'Failed to read video'}), 500
    processed_frame = classifier.implement_process(frame)
    status_list = classifier.classify_status(processed_frame)
    for idx, is_free in enumerate(status_list):
        slots.append({'slot_id': idx+1, 'status': 'free' if is_free else 'occupied'})
        if is_free:
            free += 1
        else:
            occupied += 1
    cap.release()
    # Store results in MongoDB
    db['slot_monitoring_model_results'].insert_one({
        'puid': puid,
        'total': total,
        'free': free,
        'occupied': occupied,
        'slots': slots,
        'createdAt': datetime.datetime.utcnow()
    })
    return jsonify({
        'total': total,
        'free': free,
        'occupied': occupied,
        'slots': slots
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')









