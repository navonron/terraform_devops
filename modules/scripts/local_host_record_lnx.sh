ip="ip"
host_name="host_name"
action="action"
file="/etc/hosts"

apt install sudo 
if [ "$action" = "add" ]; then
    hostfile="$ip $host_name"
    echo "$hostfile" | sudo tee -a $file
elif [ "$action" = "remove" ]; then
    pattern="^$ip\s+$host_name"
    sudo sed -i "/$pattern/d" $file
    echo "Host entry removed"
else
    echo "Invalid action: $action"
fi
