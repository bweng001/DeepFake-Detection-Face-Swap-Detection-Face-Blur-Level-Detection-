import os
import cv2
# encoding: UTF-8
path_list = []

videoWriter = cv2.VideoWriter('Detect2.avi', cv2.VideoWriter_fourcc(*'DIVX'), 12, (1026, 373))


def visitDir(path):
    if not os.path.isdir(path):
        print('Error: "', path, '" is not a directory or does not exist.')
        return
    else:
        global num
        try:
            for lists in os.listdir(path):
                sub_path = os.path.join(path, lists)
                num += 1
                # print('No.', x, ' ', sub_path)
                if os.path.isdir(sub_path):
                    visitDir(sub_path)
        except:
            pass


num = 0
# visitDir('D:\AI下学期\ACV\Deepfake\Deepfakes')
visitDir('D:\AI下学期\ACV\Deepfake\Deepfakes3')
for i in range(num + 1):
    path_no = "Deepfakes3\\" + str(i) + ".png"
    if i > 0:
        path_list.append(path_no)
for i in range(num):
    path = path_list[i]
    img = cv2.imread(path)
    videoWriter.write(img)
