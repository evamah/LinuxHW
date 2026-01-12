#!/bin/bash

if [ "$#" -lt 1 ]; then
echo "ERROR: <path to the csv file>"
exit 1
fi


csv_file="$1" 

if [ ! -f "$csv_file" ]; then
  DATE=$(date +"%Y_%m_%d_%H_%M")
  echo "${DATE}, ERROR: The file $csv_file not found"
  exit 1
fi


csv_file_name=$(basename "$csv_file" .csv)

#----------------------------------------------------------------------
# create output directory for GIFs and html files and delete if exists

output_dir="outputs_${csv_file_name}"    

if [ -d "$output_dir" ]; then
rm -r "$output_dir"
fi

mkdir -p "$output_dir"

#----------------------------------------------------------------------
# log file for info and errors
info_file="campaign_log_${csv_file_name}.txt"  
  

print_msg() {
  DATE=$(date +"%Y_%m_%d_%H_%M")
  level="$1"      # INFO / WARNING / ERROR
  msg="$2"        # message to log
   
  echo "${DATE}, ${level}: ${msg}" >> "$info_file"
}

print_msg "INFO" "Started working on campaign_runner.sh"
print_msg "INFO" "The CSV file is: $csv_file"
print_msg "INFO" "Output directory $output_dir already exists, deleted it"
print_msg "INFO" "The output directory is: $output_dir"
print_msg "INFO" "The output log file is: $info_file"


#----------------------------------------------------------------------
# html file for results GIFs
DATE=$(date +"%Y_%m_%d_%H_%M")
html_file="${csv_file_name}_${DATE}.html"   
print_msg "INFO" "Making the HTML file: $html_file"

# add HTML head
echo "<html><head><meta charset="utf-8"><title>Campaign Results</title></head><body><h1>Campaign Results for ${csv_file_name}</h1>" > "$html_file"


#----------------------------------------------------------------------
# read csv file line by line 

row_num=0

while IFS=',' read -r url output_name quality frames_num || [ -n "$url" ]; do
    row_num=$((row_num + 1))

    output_name=$(echo "$output_name" | tr -d '\r')
    quality=$(echo "$quality" | tr -d '\r')
    frames_num=$(echo "$frames_num" | tr -d '\r')
    url=$(echo "$url" | tr -d '\r')


    # skip the first line
    if [ "$row_num" -eq 1 ]; then
    print_msg "INFO" "Skipped CSV header row"
    echo "" >> "$info_file" # new line
    continue
    fi

    # skip empty lines
    if [[ -z "$url" || -z "$quality" || -z "$frames_num" || -z "$output_name" ]]; then
    print_msg "ERROR" "Row $row_num has missing values: URL='$url' QUALITY='$quality' FRAMES='$frames_num' NAME='$output_name'"
    echo "" >> "$info_file" # new line
    continue
    fi

    print_msg "INFO" "Processing row $row_num: URL=$url QUALITY=$quality FRAMES=$frames_num NAME=$output_name"

    output_path="${output_dir}/${output_name}"

    print_msg "INFO" "Running reveal_effect.sh on row $row_num"


    # Check if URL
    wget -q --spider "$url"
    #wget -O "$photo_file" "$url"
    if [ $? -eq 0 ]; then
        ./reveal_effect.sh -u "$url" -q "$quality" -n "$frames_num" -o "$output_path"
    
  # path
    else 
        if [ ! -f "$url" ]; then
            print_msg "ERROR" "Row $row_num is not a URL or a file path: $url"
        fi
        ./reveal_effect.sh -f "$url" -q "$quality" -n "$frames_num" -o "$output_path"
    

    fi

    # reveal_effect returns 1 
    if [ $? -ne 0 ]; then
        print_msg "WARNING" "reveal_effect.sh failed on row $row_num"
        echo "" >> "$info_file" # new line
        continue
    fi

    print_msg "INFO" "saved final image in: $output_path"

    echo "" >> "$info_file" # new line

    echo "<div><h2>${output_dir}/${output_name}</h2>" >> "$html_file"
    echo "<img src=\"${output_path}\"></div>" >> "$html_file"
    echo "<br>" >> "$html_file"


done < "$csv_file"

#----------------------------------------------------------------------
# close the HTML document

echo "</body></html>" >> "$html_file"

print_msg "INFO" "HTML file created: $html_file"
print_msg "INFO" "Finished working successfully"
