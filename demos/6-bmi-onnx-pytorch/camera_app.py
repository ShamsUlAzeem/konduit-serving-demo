import numpy as np
import cv2
import requests

width = 1280
height = 720
out_width = 160
out_height = 120

cap = cv2.VideoCapture(0)
cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)  # set Width
cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)  # set Height
font = cv2.FONT_HERSHEY_DUPLEX

url = 'http://localhost:8082/infer'
while True:
    ret, orig_image = cap.read()
    imencoded = cv2.imencode(".jpg", cv2.resize(orig_image, (out_width, out_height)))[1]

    files = {'image': ('image.jpg', imencoded.tostring(), 'image/jpeg', {'Expires': '0'})}
    response = requests.post(url, files=files).json()
    print(response)

    boxes = np.asarray([response['boxes']])
    if len(boxes[0]) == 0:
        continue

    box = boxes[0]
    out_size = 112
    img = orig_image.copy()
    height, width, _ = img.shape
    x1 = box[0] * width / out_width
    y1 = box[1] * height / out_height
    x2 = box[2] * width / out_width
    y2 = box[3] * height / out_height
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

    cv2.rectangle(orig_image, (x1, y1), (x2, y2), (255, 0, 0), 2)
    cv2.putText(orig_image, str(response['bmi_class']), (x1 + 5, y1 - 5), font, 1, (255, 255, 255), 2)
    cv2.putText(orig_image, str(response['bmi_value']), (x1 + 5, y2), font, 1, (255, 255, 0), 1)
    # print(Class, BMI)
    cv2.imshow('video', orig_image)
    k = cv2.waitKey(30) & 0xff
    if k == 27:  # press 'ESC' to quit
        break

cap.release()
cv2.destroyAllWindows()
