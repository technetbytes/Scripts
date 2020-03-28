# Using this script user can upload image in Cloudinary CDN

import cloudinary
from cloudinary.uploader import upload

cloud_name = ""
api_key = ""
api_secret = ""

#Cloudinary configuration parameters
cloudinary.config(cloud_name = cloud_name,api_key = api_key, api_secret = api_secret)

#set uploaded file name
file_name = "5.png"

#get Cloudinary generated public_id
file_info = upload(file_name)

# with user specific name using public_id attribute
file_info_2 = upload(file_name,public_id='alkudi')