#!/bin/bash
#
# Flattens a PDF
# by 3n3a
#
# NEEDS:
#   - Ghostscript

input_pdf="$1"
output_pdf="$2"

function flatten_pdf() {
  # 1: input pdf
  # 2: output pdf
  # from  here (http://zeroset.mnim.org/2015/01/07/flatten-pdfs-with-ghostscript/)
  gs -dSAFER -dBATCH -dNOPAUSE -dNOCACHE -sDEVICE=pdfwrite \
    -dColorConversionStrategy=/LeaveColorUnchanged  \
    -dAutoFilterColorImages=true \
    -dAutoFilterGrayImages=true \
    -dDownsampleMonoImages=true \
    -dDownsampleGrayImages=true \
    -dDownsampleColorImages=true \
    -sOutputFile="$2" "$1"
}

function check_file_exists() {
  if [[ -f "$1" ]]; then
    echo "File exists"
    return 0
  fi
  echo "File does not exist"
  return 1
}

function install_ghostscript() {
  # tries to install ghostscript on various platforms
  distro=$(lsb_release -is)
  
  case "$distro" in
    RedHatEnterprise)
      sudo dnf install -y ghostscript
      ;;
   
    Ubuntu | Debian)
      sudo apt install -y ghostscript
      ;;

    *)
      echo "Your System doesn't seem to be supported. Please install 'ghostscript'."
      exit 1
      ;;
  esac
}

function calculate_filesize_improvement() {
  # calculates how many percents were saved
  FILENAME_INPUT="$1"
  FILENAME_OUTPUT="$2"
  FILESIZE_BEFORE=$(stat --printf="%s" "$FILENAME_INPUT")
  FILESIZE_AFTER=$(stat --printf="%s" "$FILENAME_OUTPUT")

  PERCENT_FILESIZE=$(python -c "print((1-($FILESIZE_AFTER/$FILESIZE_BEFORE))*100)")
  echo "$PERCENT_FILESIZE% smaller"
}

function main() {
  echo "PDF Flattener Version 1.0"
  echo "-------------------------"
  echo ""
  
  if [[ -z "$input_pdf" ]]; then
    echo "Please enter a value for Input Pdf"
    exit 1
  fi
  
  if [[ -z "$output_pdf" ]]; then
    echo "Please enter a value for Output Pdf"
    exit 1
  fi

  # check input file exists
  if [[ ! $(check_file_exists "$input_pdf") ]]; then
    echo "Please make sure the input file exists and try again."
    exit 1
  fi
  
  # check if gs installed
  if [[ ! $(which ghostscript) ]]; then
    echo "Installing Ghostscript"
    install_ghostscript
  fi
  
  # start conversion
  flatten_pdf "$input_pdf" "$output_pdf"
  calculate_filesize_improvement "$input_pdf" "$output_pdf"
}

main
    
