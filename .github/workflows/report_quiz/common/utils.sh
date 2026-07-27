# To escapes some stupid quotes
escp(){
    echo -e \"$(printf '%q' "$*")\"
}

