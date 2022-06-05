import os
import time

import numpy as np
import pyqrcode
from PIL import Image

t = time.time()
frame_num = 1000
for _ in range(frame_num):
    qrcode = pyqrcode.initBytes(os.urandom(2048), 1)
    a = pyqrcode.uncompressModule(qrcode['modules'], qrcode['size'])
    arr = np.frombuffer(a, dtype=np.uint8)
    arr = arr.reshape(qrcode['size'], qrcode['size'])
    # print(arr.shape)
    img = Image.fromarray(arr, mode="L").resize(size=(qrcode['size'] * 4, qrcode['size'] * 4))
    # img.show()

print(f"{frame_num / (time.time() - t):.3f} fps")

# print(arr)
# cv2.imshow("aaa", arr)
# cv2.waitKey(0)
#
