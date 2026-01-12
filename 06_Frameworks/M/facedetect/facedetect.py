#!/usr/bin/env python3

import cv2
import argparse
import os
import time

def main():
    parser = argparse.ArgumentParser(description="Face Detection using Haar Cascades")
    parser.add_argument("--image", required=True, help="Input image")
    parser.add_argument("--cascade", required=True, help="Cascade XML file")
    parser.add_argument("--out", required=True, help="Output image")
    parser.add_argument("--scale", type=float, default=1.3)
    parser.add_argument("--neighbors", type=int, default=4)

    args = parser.parse_args()

    if not os.path.exists(args.image):
        raise FileNotFoundError(args.image)

    if not os.path.exists(args.cascade):
        raise FileNotFoundError(args.cascade)

    img = cv2.imread(args.image)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    gray = cv2.equalizeHist(gray)

    cascade = cv2.CascadeClassifier(args.cascade)

    start = time.time()
    faces = cascade.detectMultiScale(
        gray,
        scaleFactor=args.scale,
        minNeighbors=args.neighbors,
        minSize=(30, 30),
        flags=cv2.CASCADE_SCALE_IMAGE
    )
    elapsed = (time.time() - start) * 1000

    for (x, y, w, h) in faces:
        cv2.rectangle(img, (x, y), (x + w, y + h), (0, 255, 0), 2)

    cv2.imwrite(args.out, img)

    print(f"Faces detected: {len(faces)}")
    print(f"Processing time: {elapsed:.1f} ms")
    print(f"Saved output: {args.out}")

if __name__ == "__main__":
    main()
