#!/bin/bash
#
# utilities.sh
#

# print text with color
puts() {
#     Num  Colour    #define         R G B
#     0    black     COLOR_BLACK     0,0,0
#     1    red       COLOR_RED       1,0,0
#     2    green     COLOR_GREEN     0,1,0
#     3    yellow    COLOR_YELLOW    1,1,0
#     4    blue      COLOR_BLUE      0,0,1
#     5    magenta   COLOR_MAGENTA   1,0,1
#     6    cyan      COLOR_CYAN      0,1,1
#     7    white     COLOR_WHITE     1,1,1
    text=$1
    case $2 in
        "black"|"BLACK")
            output_color=0
        ;;
        "red"|"RED")
            output_color=1
        ;;
        "green"|"GREEN")
            output_color=2
        ;;
        "yellow"|"YELLOW")
            output_color=3
        ;;
        "blue"|"BLUE")
            output_color=4
        ;;
        "magenta"|"MAGENTA")
            output_color=5
        ;;
        "cyan"|"CYAN")
            output_color=6
        ;;
        "white"|"WHITE")
            output_color=7
        ;;
    esac
    if [ -z "$output_color" ]; then
        echo "$text"
    else
        echo "$(tput setaf $output_color)$text $(tput sgr 0)"
    fi
    unset output_color
}

set_dotenv(){
    echo "$1=$2" >> .jefe/.env
}

get_dotenv(){
    echo $( grep "$1" .jefe/.env | sed -e "s/$1=//g" )
}

load_dotenv(){
    project_type=$( get_dotenv "PROJECT_TYPE" )
    project_name=$( get_dotenv "PROJECT_NAME" )
    project_root=$( get_dotenv "PROJECT_ROOT" )
    VHOST=$( get_dotenv "VHOST" )
    dbname=$( get_dotenv "DB_NAME" )
    dbuser=$( get_dotenv "DB_USER" )
    dbpassword=$( get_dotenv "DB_PASSWORD" )
    dbhost=$( get_dotenv "DB_HOST" )
}

# read yaml file
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

get_yamlenv(){
    echo $( parse_yaml .jefe/environments.yaml | grep "^$1_$2" | sed -e "s/$1_$2=//g" | sed -e "s/\"//g")
}

load_settings_env(){
    # access yaml content
    user=$( get_yamlenv $1 user)
    group=$( get_yamlenv $1 group)
    host=$( get_yamlenv $1 host)
    port=$( get_yamlenv $1 port)
    public_dir=$( get_yamlenv $1 public_dir)
    dbname=$( get_yamlenv $1 dbname)
    dbuser=$( get_yamlenv $1 dbuser)
    dbpassword=$( get_yamlenv $1 dbpassword)
    dbhost=$( get_yamlenv $1 dbhost)
    exclude=$( get_yamlenv $1 exclude)
}

