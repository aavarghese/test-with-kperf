# if local-setup kill $PID
if [ ! -z "$LOCAL_RECEIVER_PID" ]; then
  echo "Killing local process group $LOCAL_RECEIVER_PGID"
  #echo  kill --    -"$LOCAL_RECEIVER_PGID"
  #kill -SIGTERM -- -${LOCAL_RECEIVER_PGID}
  kill $(ps j |grep $LOCAL_RECEIVER_PGID|grep "eventing receiver"|awk '{print $2}')
fi
