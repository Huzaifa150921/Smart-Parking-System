import cv2
import numpy as np
import pickle
from src.utils import Park_classifier
from flask import Flask, request, jsonify
from bson.objectid import ObjectId
from pymongo import MongoClient


app = Flask(__name__)
client = MongoClient("mongodb://localhost:27017/")
db = client["video_db"]
collection = db["videos"]


def demostration():
    """It is a demonstration of the application.
    """

    # defining the params
    rect_width, rect_height = 107, 48
    carp_park_positions_path = "data/source/CarParkPos"
    video_path = "data/source/carPark.mp4"

    # creating the classifier  instance which uses basic image processes to classify
    classifier = Park_classifier(carp_park_positions_path, rect_width, rect_height)

    # Implementation of the classy
    cap = cv2.VideoCapture(video_path)
    while True:

        # reading the video frame by frame
        ret, frame = cap.read()

        # check is there a retval
        if not ret:break
        
        # prosessing the frames to prepare classify
        prosessed_frame = classifier.implement_process(frame)
        
        # drawing car parks according to its status 
        denoted_image = classifier.classify(image=frame, prosessed_image = prosessed_frame)
        
        # displaying the results
        cv2.imshow("Car Park Image which drawn According to  empty or occupied", denoted_image)
        
        # exit condition
        k = cv2.waitKey(1)
        if k & 0xFF == ord('q'):
            break
        
        if k & 0xFF == ord('s'):
            cv2.imwrite("output.jpg", denoted_image)

    # re-allocating sources
    cap.release()
    cv2.destroyAllWindows()

@app.route('/process', methods=['POST'])
def process_video():
    data = request.get_json()
    video_id = data.get('video_id')
    if not video_id:
        return jsonify({'error': 'Missing video_id'}), 400
    video_doc = collection.find_one({'_id': ObjectId(video_id)})
    if not video_doc:
        return jsonify({'error': 'Video not found'}), 404
    video_path = video_doc['filepath']
    carp_park_positions_path = "../data/source/CarParkPos"
    rect_width, rect_height = 107, 48
    classifier = Park_classifier(carp_park_positions_path, rect_width, rect_height)
    cap = cv2.VideoCapture(video_path)
    total_slots = len(classifier.car_park_positions)
    free_slots = 0
    occupied_slots = 0
    while True:
        ret, frame = cap.read()
        if not ret:
            break
        prosessed_frame = classifier.implement_process(frame)
        # Assume classify returns a list of booleans: True=free, False=occupied
        slot_statuses = classifier.classify(image=frame, prosessed_image=prosessed_frame, return_status=True)
        free_slots = slot_statuses.count(True)
        occupied_slots = slot_statuses.count(False)
        # Only process first frame for speed, or break after first frame
        break
    cap.release()
    return jsonify({
        'message': 'Processing complete',
        'total_slots': total_slots,
        'free_slots': free_slots,
        'occupied_slots': occupied_slots
    })

if __name__ == "__main__":
    demostration()
