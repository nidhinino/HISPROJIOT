#!/bin/bash

# sh term1.sh nnayak <pass> <channel>

login=$1
pass=echo "*******"
channel=$3

echo "login: $login"
echo "password: $pass"
echo "channel: $channel"

send_command (){
    ssh $login@grenoble.iot-lab.info "$1"
    return $?
}

send_command "echo $pass | iotlab-auth -u $login"
exp_id=$(send_command "iotlab-experiment submit -n riot_a8 -d 300 -l 2,archi=a8:at86rf231+site=grenoble | jq -r '.id'")
echo "exp ID : $exp_id"



state=$(send_command "iotlab-experiment get -i $exp_id -s | jq -r '.state'")
while "$state" != "Running"
do
    state=$(send_command "iotlab-experiment get -i $exp_id -s | jq -r '.state'")
done

echo $(send_command "iotlab-experiment get -i $exp_id -n")

a8_1="node-"$(send_command "iotlab-experiment get -i $exp_id -n | jq -r '.items[0].network_address'" | cut -d'.' -f1)
a8_2="node-"$(send_command "iotlab-experiment get -i $exp_id -n | jq -r '.items[1].network_address'" | cut -d'.' -f1)

echo "node a8-1: $a8_1,  a8-2: $a8_2"



if [ ! -d "~/A8/riot" ]; then
    send_command "mkdir -p ~/A8/riot; cd ~/A8/riot; git clone https://github.com/RIOT-OS/RIOT.git -b 2020.10-branch"
fi

dir_loc="cd ~/A8/riot/RIOT;"

# step 5
send_command "$dir_loc source /opt/riot.source; make ETHOS_BAUDRATE=500000 DEFAULT_CHANNEL=$channel BOARD=iotlab-a8-m3 -C examples/gnrc_border_router clean all"
send_command "$dir_loc cp examples/gnrc_border_router/bin/iotlab-a8-m3/gnrc_border_router.elf ~/A8/."
send_command "sleep 12"


send_command_to_node(){
    echo "executing : ssh root@$1 \"$2\""
    ssh $login@grenoble.iot-lab.info "ssh root@$1  -o StrictHostKeyChecking=no \"$2\" "
    return $?
}


send_command_to_node $a8_1 "flash_a8_m3 A8/gnrc_border_router.elf"
send_command_to_node $a8_1 "iotlab_reset"
dir_uhcpd="cd ~/A8/riot/RIOT/dist/tools/uhcpd;"
send_command_to_node $a8_1 "$dir_uhcpd make clean all; cd ../ethos; make clean all"

send_command_to_node $a8_1 "printenv"
INET6_PREFIX=$(printenv | grep INET6_PREFIX=)
INET6="${INET6_PREFIX##INET6_PREFIX=}"
INET6_LEN=64
send_command_to_node $a8_1 "cd ~/A8/riot/RIOT/dist/tools/ethos; ./start_network.sh /dev/ttyA8_M3 tap0 $INET6::/$INET6_LEN 500000"
