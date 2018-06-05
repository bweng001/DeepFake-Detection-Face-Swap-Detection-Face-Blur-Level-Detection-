import cv2
import pandas as pd
import numpy as np
import os


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


if __name__ == '__main__':
    side_view_face_cascade = cv2.CascadeClassifier(
        "D:\\program21.4.18\\Anaconda\\envs\\opencv-env\\Lib\\site-packages\\cv2\\data\\lbpcascade_profileface.xml")

    frontal_face_cascade = cv2.CascadeClassifier(
        "D:\\program21.4.18\\Anaconda\\envs\\opencv-env\\Lib\\site-packages\\cv2\\data\\haarcascade_frontalface_default.xml")
    num = 0
    path_list = []
    face_position_list = []
    no_face = [0, 0, 0, 0, 0, 0, 0, 0]
    visitDir('D:\AI下学期\ACV\Deepfake\Video1')
    for i in range(num + 1):
        path_no = "Video1\\" + str(i) + ".png"
        if i > 0:
            path_list.append(path_no)
    for i in range(num):
        path = path_list[i]
        img = cv2.imread(path)

        img2gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        cv2.equalizeHist(img2gray)
        # frontal_face_position = frontal_face_cascade.detectMultiScale(img2gray,
        #                                                               minNeighbors=2,
        #                                                               minSize=(60, 60),
        #                                                               maxSize=(130, 130))
        frontal_face_position = frontal_face_cascade.detectMultiScale(img2gray,
                                                                      minNeighbors=5
                                                                      )
        if len(frontal_face_position) != 0:
            if len(frontal_face_position) == 2:
                frontal_face_position1 = frontal_face_position[1]
                for (x, y, w, h) in frontal_face_position1:
                    print(i + 1, ":", x, y, w, h)
                    cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), 2)
                    cv2.imwrite(str(i + 1) + ".png", img)
                face_position_list.append(frontal_face_position)
            else:
                face_position_list.append(no_face)
    face_position_array = np.array(face_position_list).reshape(num, 1)

    # face = crop[y:y+h,x:x+w]
    # imageVar = cv2.Laplacian(image, cv2.CV_64F).var()

    # save1 = pd.DataFrame(face_position_array,
    #                      columns=['(X,Y),width,height'])
    # save1.to_csv('Face_Position_Video1.csv')
