if [ $# != "3" ]; then
	#statements
	echo 'echopost.sh author title categories'
	exit 1
fi

ct='---\\n'
ct=$ct"author: $1"'\\n'
ct=$ct'comments: true\\n'
dstr=`date +%Y-%m-%d\ %H:%M:%S+00:00`
ct=$ct'date: '$dstr'\\n'
ct=$ct'layout: post\\n'
ct=$ct"slug: $2"'\\n'
ct=$ct"title: $2"'\\n'
ct=$ct'categories:\\n'
ct=$ct"- $3"'\\n'
ct=$ct'---\\n'
ct=$ct'content'
echo $ct
exit 0
