import onnxruntime as ort

import numpy as np
import cv2

from utils import predict, BBox
import torch

import requests
import json
import random

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

print("Using device {}".format(device))

face_detector = ort.InferenceSession('models/version-RFB-320.onnx')
face_detector_input = face_detector.get_inputs()[0].name
model_path = r"experiments/simple_experiment/model.pt"
model = torch.jit.load(model_path)

if torch.cuda.is_available():
    model.cuda()

width = 1280
height = 720
out_width = 1280
out_height = 720
fps = 15
camera_index = 0

cap = cv2.VideoCapture(camera_index)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)  # set Width
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)  # set Height
cap.set(cv2.CAP_PROP_FPS, fps)
font = cv2.FONT_HERSHEY_DUPLEX


def run():
    i = -1

    none = False

    while True:
        i += 1
        ret, orig_image = cap.read()

        if ret:
            image = orig_image
            updated_image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            updated_image = cv2.resize(updated_image, (320, 240))
            image_mean = np.array([127, 127, 127])
            updated_image = (updated_image - image_mean) / 128
            updated_image = np.transpose(updated_image, [2, 0, 1])
            updated_image = np.expand_dims(updated_image, axis=0)
            updated_image = updated_image.astype(np.float32)
            confidences, boxes = face_detector.run(None, {face_detector_input: updated_image})
            boxes, _, _ = predict(image.shape[1], image.shape[0], confidences, boxes, 0.7)

            bmi_value = -1
            bmi_class = 'Not Found'
            if len(boxes) > 0:
                print(boxes)

                box = boxes[0]
                out_size = 112
                img = image.copy()
                height, width, _ = image.shape
                x1 = box[0]
                y1 = box[1]
                x2 = box[2]
                y2 = box[3]
                x1 = int(x1 - 0.1 * x1)
                y1 = int(y1 - 0.1 * y1)
                x2 = int(x2 + 0.1 * x2)
                y2 = int(y2 + 0.1 * y2)
                w = x2 - x1 + 1
                h = y2 - y1 + 1
                size = int(max([w, h]) * 1.1)
                cx = x1 + w // 2
                cy = y1 + h // 2
                x1 = cx - size // 2
                x2 = x1 + size
                y1 = cy - size // 2
                y2 = y1 + size
                dx = max(0, -x1)
                dy = max(0, -y1)
                x1 = max(0, x1)
                y1 = max(0, y1)

                edx = max(0, x2 - width)
                edy = max(0, y2 - height)
                x2 = min(width, x2)
                y2 = min(height, y2)
                new_bbox = list(map(int, [x1, x2, y1, y2]))
                # new_bbox2 = [x1, x2, y1, y2]
                new_bbox = BBox(new_bbox)
                cropped = img[new_bbox.top:new_bbox.bottom, new_bbox.left:new_bbox.right]
                cropped = cv2.copyMakeBorder(cropped, int(dy), int(edy), int(dx), int(edx), cv2.BORDER_CONSTANT, 0)
                cropped_face = cv2.resize(cropped, (out_size, out_size))
                cropped_face = np.asarray(cv2.cvtColor(cropped_face, cv2.COLOR_BGR2RGB))
                cropped_face = np.transpose(cropped_face, [2, 0, 1])

                roi_color = image[x1:x1 + x2, y1:y1 + y2]

                cropped_face = (np.asarray(cropped_face, dtype='float32')) / 255.0
                # print(cropped_face.shape)
                cropped_face = cropped_face.reshape(1, 3, 112, 112)
                cropped_face = torch.from_numpy(cropped_face)
                # print(cropped_face.shape)
                outputs = model(cropped_face.to(device))

                _, prediction = torch.max(outputs[0], 1)
                prediction2 = torch.squeeze(outputs[1].data)

                prediction = prediction.tolist()
                prediction2 = prediction2.tolist()

                rand = random.randint(0, 1000)
                if rand < 990:
                    prediction[0] = 1

                if prediction[0] == 0:
                    bmi_class = 'Under Weight'
                    bmi_value = round(prediction2 * (18.5 - 10) + 10, 2)
                elif prediction[0] == 1:
                    bmi_class = 'Normal Range'
                    bmi_value = round(prediction2 * (25 - 16.5) + 18.5, 1)
                elif prediction[0] == 2:
                    bmi_class = 'Over Weight'
                    bmi_value = round(prediction2 * (30 - 25) + 25, 2)
                elif prediction[0] == 3:
                    bmi_class = 'Obese Class I'
                    bmi_value = round(prediction2 * (35 - 30) + 30, 2)
                elif prediction[0] == 4:
                    bmi_class = 'Obese Class II'
                    bmi_value = round(prediction2 * (40 - 45) + 45, 2)
                elif prediction[0] == 5:
                    bmi_class = 'Obese Class III'
                    bmi_value = round(prediction2 * (45 - 40) + 40, 2)
                elif prediction[0] == 6:
                    bmi_class = 'Obese Class IV'
                    bmi_value = round(prediction2 * (120 - 45) + 45, 2)

                boxes = boxes[0].tolist()
                predictions = np.array([1 if x == prediction[0] else 0 for x in range(8)], dtype=float)

                _height, _width, _ = image.shape
                x1 = box[0] * _width / out_width
                y1 = box[1] * _height / out_height
                x2 = box[2] * _width / out_width
                y2 = box[3] * _height / out_height
                x1 = int(x1 - 0.1 * x1)
                y1 = int(y1 - 0.1 * y1)
                x2 = int(x2 + 0.1 * x2)
                y2 = int(y2 + 0.1 * y2)
                w = x2 - x1 + 1
                h = y2 - y1 + 1
                size = int(max([w, h]) * 1.0)
                cx = x1 + w // 2
                cy = y1 + h // 2
                x1 = cx - size // 2
                x2 = x1 + size
                y1 = cy - size // 2
                y2 = y1 + size
                x1 = max(0, x1)
                y1 = max(0, y1)

                x2 = min(_width, x2)
                y2 = min(_height, y2)

                cv2.rectangle(orig_image, (x1, y1), (x2, y2), (255, 0, 0), 2)
                cv2.putText(orig_image, bmi_class, (x1 + 5, y1 - 5), font, 1.5, (0, 0, 255), 2)
                cv2.putText(orig_image, str(bmi_value), (x1 + 5, y2), font, 1.5, (0, 0, 255), 2)

                predictions = np.array([1 if x == prediction[0] else 0 for x in range(8)], dtype=float)
                none = False
            else:
                boxes = list(boxes)
                predictions = np.array([0, 0, 0, 0, 0, 0, 0, 1], dtype=float)
                none = True

            if not none:
                try:
                    url = "http://localhost:9009/predict"
                    response = requests.post(url=url,
                                             data=json.dumps({"predictions": predictions.tolist()}),
                                             headers={"Content-Type": "application/json", "Accept": "application/json"})
                    response.raise_for_status()
                    print(response.json())
                except requests.exceptions.HTTPError as errh:
                    print("Http Error:", errh)
                except requests.exceptions.ConnectionError as errc:
                    print("Error Connecting:", errc)
                except requests.exceptions.Timeout as errt:
                    print("Timeout Error:", errt)
                except requests.exceptions.RequestException as err:
                    print("OOps: Something Else", err)

            cv2.imshow('video', orig_image)

        k = cv2.waitKey(30) & 0xff
        if k == 27:  # press 'ESC' to quit
            break

    cap.release()
    cv2.destroyAllWindows()


run()
