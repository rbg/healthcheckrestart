# !/bin/sh
function usage
{
        echo "Usage: ./monitor.sh [-h] [-u url]"
        echo "-h | --help = display help"
        echo "-u | --url  = Healthcheck url to the foobar service"
        exit 1
        exit
}
while [ $# -gt 0 ]; do
        case $1 in
                -h|--help)
                        usage
                        ;;
                -u|--url)
                        url="$2"
                        ;;
        esac
        shift
done

if [ -z "$url" ]; then
        echo "You must provide a healthcheck url to use this script. Reference the -u flag in the help section"
        exit
fi

echo "url: $url"
SERVICE=foobar
while true
do
  if pgrep $SERVICE >/dev/null 2>&1
  then
     # abc is running
  STATUS=$(curl -s -o /dev/null -w '%{http_code}' $url)
  echo $STATUS
  if [ $STATUS -eq 500 ]; then
    echo "$SERVICE"' responded with '"$STATUS"'. Restarting '"$SERVICE"' service...'
    killall $SERVICE
    ./$SERVICE &
    disown
  fi
    else
    echo "$SERVICE"' service not running. Starting '"$SERVICE"' service...'
     ./$SERVICE &
    disown
  fi
  sleep 2
done
done