#!/bin/zsh

# Function to extract the date from the folder name in the format "long month (%B), day of month (%d), year (%Y)"
get_date_from_folder() {
    local folder_name=$1
    # Regular expression pattern to match "long month (%B), day of month (%d), year (%Y)" format in the folder name
    local pattern='([[:alpha:]]+ [0-9]{1,2}, [0-9]{4})'
    local date_string
    if [[ $folder_name =~ $pattern ]]; then
        date_string="${MATCH}"
    else
        date_string=""
    fi
    echo "$date_string"
}

# Function to rename the folder with the new date format
rename_folder_with_date() {
    # the current folder we are working on
    local folder_name=$1

    # Extract the parent directory's path
    local parent_path=$(dirname "$folder_name")

    local subfolder="${folder_name#${parent_path}}"
    subfolder="${subfolder:1}"

    local new_date_format=$2
    local old_date=$(get_date_from_folder "$folder_name")

    local new_subfolder="${subfolder//$old_date/}"

    # Check if the last character of new_subfolder is a comma and remove it
    if [[ "${new_subfolder: -1}" == "," ]]; then
        new_subfolder="${new_subfolder%,}"
    fi

    if [[ -n "$old_date" ]]; then
        local new_date=$(date -j -f "%B %d, %Y" "$old_date" +"$new_date_format")
        local new_folder_name="${parent_path}/${new_date} ${new_subfolder} iPhoto Export"

        # keeping around hte following for future debugging
        #echo "Old Folder: $folder_name"
        #echo "Parent Path: $parent_path"
        #echo "Subfolder: $subfolder"
        #echo "Old Date: $old_date"  # Debug log: Print the extracted old date
        #echo "New Date: $new_date"  # Debug log: Print the extracted new date
        #echo "New Folder: $new_folder_name"
        #echo " "     

        mv "$folder_name" "$new_folder_name"
    else
        echo "No Date Found in Folder: $folder_name"  # Debug log: Print when no date is found
        echo " "     
        date_string=""
    fi
}


# Main script logic
main() {
    local new_date_format="%Y-%m-%d"  # Change this to the desired date format

    # Get the current directory (current folder)
    local current_directory="${PWD}"

    # Iterate through all subdirectories in the current directory
    for folder in "${current_directory}"/*(/); do
        if [[ -d "$folder" ]]; then
            # Call the rename function for each folder
            rename_folder_with_date "$folder" "$new_date_format"
        fi
    done
}

# Call the main function to start the renaming process
main
