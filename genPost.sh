if [ $# != "2" ] ;then
	echo "sh genPost.sh title category"
	exit 1
fi
dstr=`date +%Y-%m-%d`
fn=$dstr'-'$1'.markdown'
content=`sh echopc.sh huji "$1" "$2"`
if [ $? = "0" ]; then
	#statements
	echo $content
	echo $content > "_posts/"$fn
	echo "Done"
else
	echo $content
fi
