import cv2

vc = cv2.VideoCapture('deepfake.FLV')  # 读入视频文件
c = 1

if vc.isOpened():  # 判断是否正常打开
    rval, frame = vc.read()
    print("Read Successfully")

else:
    rval = False

# timeF = 2  # 视频帧计数间隔频率
count = 0
name_no = 0
while rval:  # 循环读取视频帧
    rval, frame = vc.read()
    count += 1
    if count >= 0 & count < 500:
        if (count % 3 == 0):  # 每隔timeF帧进行存储操作
            name_no += 1
            # frame = frame[100:380, :]
            frame = frame[100:350, :]
            cv2.imwrite('image/' + str(name_no) + '.png', frame)  # 存储为图像        cv2.waitKey(1)
vc.release()
