import os
from PIL import Image

def getNewSize(img):
	'''
	This function determines the new size of the image.
	Change the below logic as per your desired size.
	'''
	(w,h) = img.size
	(nw,nh) = img.size
	if (w > 1000):
		nw = 1000
		nh = int((1.0*h/w)*nw)
	elif (h > 1200):
		nh = 1200
		nw = int((1.0*w/h)*nh)
	return (nw,nh)

def compressResizeImages(val):
	'''
	This function compresses and resizes the images present in the input folder.
	'''
	extns = ['.jpg','.jpeg','.png','.gif'] #extensions for images
	bytesSaved = 0
	files = next(os.walk(inFolder))[2]
	for file in files:
		if (file[-4:] in extns or file[-5:] in extns):
			print ('processing file....>>> {0}'.format(file))
			imgFile = inFolder + file #input image file path
			outImg = outFolder + file #output image file path
			oSize = os.path.getsize(imgFile) #size of the original image
			inImg = Image.open(imgFile)
			size = getNewSize(inImg)
			inImg.thumbnail(size,Image.ANTIALIAS) # resize the image
			inImg.save(outImg, "JPEG", quality=val)
			nSize = os.path.getsize(outImg) #size of the new image
			bytesSaved = bytesSaved + (oSize - nSize)
	return bytesSaved

def main():
	'''
	This program will compress all images present in the input folder.
	'''
	quality = 50 #1-worst & 100:best
	bytesSaved = compressResizeImages(quality)
	print ('\nTotal Kbytes saved after resizing and compression....{0}'.format(bytesSaved/1000))

#####INPUT OUTPUT FOLDERS##################
inFolder = '/home/saqib/Documents/cnic-ocr/UntitledFolder/'
outFolder = '/home/saqib/Documents/cnic-ocr/UntitledFolder/'
############################################
if __name__ == '__main__':
	main()