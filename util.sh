die_on_failure (){
    stat=$1
    msg=$2
    if [[ $stat -ne 0 ]]
    then
        echo $msg >&2
        exit 1
    fi
}
