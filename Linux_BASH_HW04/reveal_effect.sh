#!/bin/bash

if [ "$#" -lt 4 ]; then
echo "ERROR: -f/-u <path/URL> -q <1-100> -n <frames> -o <output.gif> -s<(optional)>"
exit 1
fi

print_msg() {
  DATE=$(date +"%Y_%m_%d_%H_%M")
  level="$1"      # INFO / WARNING / ERROR
  msg="$2"        # message to log
   
  echo "${DATE}, ${level}: ${msg}" >> execution.log  

  if [ "$print_terminal" = true ]; then
  echo "${DATE}, ${level}: ${msg}"
  fi
}


path=""
url=""  
quality=5  
frames_num=10
output_file="output.gif"
print_terminal=false


while [ "$#" -gt 0 ]; do
  case "$1" in
    -f)
      path="$2"   
      shift 2     
      ;;
    -u)
      url="$2"    
      shift 2    
      ;;
    -q)
      quality="$2"  
      shift 2    
      ;;
    -n)
      frames_num="$2"    
      shift 2    
      ;;
    -o)
      output_file="$2"    
      shift 2    
      ;;    
    -s)
      print_terminal=true  
      shift 1    
      ;;
    *)
      echo "ERROR: -f/-u <path/URL> -q <1-100> -n <frames> -o <output.gif> -s<(optional)>" >> execution.log
      echo "ERROR: -f/-u <path/URL> -q <1-100> -n <frames> -o <output.gif> -s<(optional)>" 
      echo "" >> execution.log # new line
      exit 1
      ;;
  esac
done


print_msg "INFO" "Started working"


if [ -n "$path" ] && [ -n "$url" ]; then
print_msg "ERROR" "Use -f or -u"
echo "" >> execution.log # new line
exit 1
fi

if [ "$quality" -lt 1 ] || [ "$quality" -gt 100 ]; then
print_msg "ERROR" "Quality should be in range 1-100"
echo "" >> execution.log # new line
exit 1
fi

if [ "$frames_num" -lt 1 ]; then
print_msg "ERROR" "frames_num should be more than 0"
echo "" >> execution.log # new line
exit 1
fi


#----------------------------------------------------------------------
# create temp directory and delete if exists
if [ -d "temp_dir" ]; then
print_msg "INFO" "Output directory temp_dir already exists deleiting it"
rm -r "temp_dir"
fi

print_msg "INFO" "Making the directory temp_dir"
mkdir -p "temp_dir"

#----------------------------------------------------------------------
# download from URL or path and saves it in temp_dir/photo_file

photo_file="temp_dir/photo_file"


if [ -n "$url" ]; then   # download file from URL
  print_msg "INFO" "Checking the URL: $url"
 
  wget -O "$photo_file" "$url"
  if [ $? -ne 0 ]; then
    print_msg "ERROR" "Failed to download file from the URL: $url"
    rm -rf temp_dir # cleanup 
    echo "" >> execution.log # new line
    exit 1
  fi
  print_msg "INFO" "Downloaded file from the URL: $url"

else    # get file from path
  if [ ! -f "$path" ]; then
    print_msg "ERROR" "File not found: $path"
    rm -rf temp_dir # cleanup
    echo "" >> execution.log # new line
    exit 1
  fi

  cp "$path" "$photo_file"

  print_msg "INFO" "Copied file from $path to $photo_file "
fi  


print_msg "INFO" "Photo is in: $photo_file"

#----------------------------------------------------------------------
# move the photo to temp_dir and change its name to img_i.jpg

# show the main photo more time
cp "$photo_file" temp_dir/img_0.jpg
cp "$photo_file" temp_dir/img_1.jpg
cp "$photo_file" temp_dir/img_2.jpg
cp "$photo_file" temp_dir/img_3.jpg
cp "$photo_file" temp_dir/img_4.jpg
cp "$photo_file" temp_dir/img_5.jpg
cp "$photo_file" temp_dir/img_6.jpg
cp "$photo_file" temp_dir/img_7.jpg
cp "$photo_file" temp_dir/img_8.jpg


width=$(identify -format "%w" "$photo_file")
height=$(identify -format "%h" "$photo_file")

print_msg "INFO" "Image width: $width px"
print_msg "INFO" "Image height: $height px"


max_quality=100

step=$(( (max_quality - quality) / frames_num ))
if [ "$step" -lt 1 ]; then
  step=1
fi


for ((i=9; i<=frames_num+8; i++)); do

print_msg "INFO" "Creating frame $i with quality $quality"

compressed="temp_dir/img_${i}_compressed.jpg"
convert "$photo_file" -quality "$quality" "$compressed"

back_to_original="temp_dir/img_${i}.jpg"
convert "$compressed" -resize "${width}x${height}!" "$back_to_original"

rm "$compressed"

# increase quality smoothly
if [ "$quality" -lt 100 ]; then
  quality=$((quality + step))
  if [ "$quality" -gt 100 ]; then
    quality=100
    print_msg "WARNING" "Quality reached the maximum of 100"
  fi
fi
  
done

rm "$photo_file" # to delete the photo that is named as photo_file not img_i.jpg


print_msg "INFO" "Finished creating $frames_num frames in temp_dir"

#----------------------------------------------------------------------
# create GIF from the frames

print_msg "INFO" "Creating GIF file: $output_file"

convert -delay 10 -loop 0 temp_dir/img_*.jpg "$output_file"

if [ $? -ne 0 ]; then
  print_msg "ERROR" "Failed to create GIF"
  rm -rf temp_dir # cleanup
  echo "" >> execution.log # new line
  exit 1
fi

print_msg "INFO" "GIF created in: $output_file successfully"

#----------------------------------------------------------------------
# cleanup
print_msg "INFO" "Cleaning up temporary directory"
rm -rf temp_dir
 
print_msg "INFO" "Finished working successfully"

echo "" >> execution.log # new line
