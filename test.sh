./keygen.sh 
wait $(echo $!)
if [ -f "haiku_key.pub" ]; then
	echo "File created!"
fi
