#!/bin/bash

unalias ls

get_file_name() {
    filename=$(basename -- "$1")
    extension="${filename##*.}"
    echo "${filename%.*}"
}

get_file_extension() {
    filename=$(basename -- "$1")
    extension="${filename##*.}"
    echo $extension
}

check_flac_extension() {
    if [ `get_file_extension "$1"` == "flac" ]; then
        echo "true"
    else
        echo "false"
    fi
}

assert_ffmpeg() {
    ffmpeg -version > /dev/null
    if [[ $? != 0 ]]; then
        echo "ffmpeg is not installed!"
        exit 1
    fi
}

escape_name() {
    escaped=$(echo "$1" | sed -e 's/./\\&/g; 1{$s/^$/""/}; 1!s/^/"/; $!s/$/"/')
    echo "${escaped}"
}

single() {
    input_file="$1"
    if [ `check_flac_extension "$input_file"` == "false" ]; then
        echo "Input file '$input_file' is not a flac file!"
        return 1
    fi

    just_name=`get_file_name "$input_file"`
    # just_name=`escape_name "$just_name"`

    if [[ -f "${just_name}.mp3" ]]; then
        echo "${just_name} was already converted!"
        return 1
    fi

    # input_file=$(escape_name "${input_file}")
    # echo "ess $fafa"

    echo "Converting ${just_name} to mp3..."
    ffmpeg -i ./"$input_file" -ab 320k -map_metadata 0 -id3v2_version 3 "${just_name}.mp3"
    echo "Done :)"
}

bulk() {
    cd "$1"
    ls |
    while read -r file ; do
        single "$file"
    done
}

bulks() {
    cd "$1"
    ls |
    while read -r dir; do
        if [[ -d "$dir" ]]; then
            cd "$dir"
            ls |
            while read -r file ; do
                single "$file"
            done
            cd ..
        fi
    done
}

assert_ffmpeg
# single "$1"
# bulk "$1"
bulks "$1"
# escape_name "$1"
