if [ $# != "2" ] ;then
        echo "sh deployPic.sh sub_dir_name path_to_the_image"
        exit 1
fi

subdir="$1"
path="$2"

if [ ! -f "$path" ];then
	echo 'wrong image path.'
	exit
fi

dir_path="images/$subdir"

if [ ! -d $dir_path ];then
	mkdir $dir_path
fi

fname=`basename "$path"`
des_path=$dir_path"/"$fname
mv "$path" "$des_path"

out_put="![$fname](/$des_path)"

echo $out_put
echo $out_put | pbcopy
