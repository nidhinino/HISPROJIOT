# IOT Microcontroller to Cloud

Nidhi Nayak(1404524) and Vedhavyas Mallya Ramesh (1341069)

# System Requirements

You need to have a minimum of 16GB RAM, Linux Installed preferably Ubuntu, High Speed internet and an account in AWS to access IoT cor, gcc compiler, python, paho-mqtt.

Please gitclone all the files into your local machine(Ubuntu Linux).

Note:Our local machine which we use is Ubuntu 22.04 inside Oracle Virtual box

# Architecture

### Original Architecture

The original architecture proposes an idea of sending the data from the RIOT sensor driver to the MQTT broker in the local machine and also the RIOT has a border router which can be configured in it and then to the AWS via a MQTT broker present in AWS, thereby we have a transparent bridge/gateway established between them.

![Untitled](IOT%20Microcontroller%20to%20Cloud%20d99c440828924c82a8d4d2370a5702e1/Untitled.png) 
RIOT-->MQTT-->AWS IOT CORE

### Our Architecture

Our Architecture eliminates the MQTT broker in the local machine and we just have the MQTT broker in AWS which is located inside AWS IoT core and we just push the messages from grenoble system.

![Untitled](IOT%20Microcontroller%20to%20Cloud%20d99c440828924c82a8d4d2370a5702e1/Untitled%201.png)
RIOT-->AWS IOT CORE

# AWS SetUp

This is step by step tutorial to send messages from grenoble to AWS IoT core. 

**Step 1: On AWS IoT Core**

1. Login to your AWS account. 
2. On left side you will Modules click on that then click on learners lab and start lab.
3. Then on the left click on green symbol besides AWS. It will redirect you to Console home page.
4. Click on Iot Core. There will be panel of left click on Manage—>All Devices—>Things
5. Create a New thing here —>Create single thing—>Next—>Enter name for your thing—>Next
6. Now you need to configure device Certificate—> Auto-generate which is most recommended—>Next—>Download all your certificates
7. We have successfully created Certificate, now we need to create policy and attach it
8. Give a new policy name and allow Policy effect. For Policy action and Policy Resource give * (It allows to perform all Aws IoT actions on all Aws IoT resources) and create policy.
9. You will be directed to a page where you can now download certificates and keys—>Activate
10. Make a Folder Named Certificate and put all three certificates here (AWS CA 1, Certificate for thing and Private key)
11. In Left panel under Security —> Certificates —> click on Certificate created right now —> attach the created policy here
12. Under Test —>MQTT test client—>Connection details. Here you will find Client ID, endpoint . copy paste this somewhere you will need this later.

**Step 2: On Linux terminal**

1. Login to Grenoble.
2. Open a Vim editor and type a code to publish message on Aws IoT core (Code attached in git- Testpaho.py)
3. In this code you will require Client ID, Broker that is your endpoint along with the Certificates(AWS CA, Certfile and Keyfile which is your private key)
4. We have taken this code as baseline and added a few things relevant to our project which is uploaded on github. named Testpaho.py

Original Code Reference: https://github.com/shariqahmkhan/awsiot/blob/master/awsiot.py 

1. You need to make a folder named certificate under grenoble system and paste all your certificates there. 
2. Use this code to transfer file from local machine to grenoble 

scp certificate_name <username>@grenoble.iot-lab.info:path_in_which_you_need_file

1. Once all the certificates are in Certificates folder, use pwd command for path, You will need path of these certificates to run [Testpaho.py](http://Testpaho.py) 
2. Run the code in grenoble. use Python3 filename.py and check for errors.

**Step 3: Integrate both**

1. On AWS Iot Core left side you will find MQTT test client under Test. You will see Subscribe to a topic. select your topic name that is your thing that you created. under additional configuration select Quality of service to be 1 and MQTT payload display as Auto-format JSON payloads. Subscribe now.
2. On grenoble end run your python file and wait for a few seconds.
3. You will see published message on AWS IoT Core.

If everything works as described, you are now able to send data from Grenoble to AWS IoT Core.

**Congratulations!**

## Dummy Driver Program 

We have a dummy driver which generates random Temperature and Humidity values and this is in turn called by the Python script called [Testpaho.py](http://Testpaho.py) which also acts as a gateway between AWS and the Grenoble RIOT and prints these values to the AWS endpoint.

From the files which were cloned to the local machine please copy it to the grenoble server with help of scp command.

The files needed to be copied(by scp) are generator.c, Testpaho.py, the certificates folder.

Maybe when you run the python script the path needs to be changed according to your directory structure. 

## **Set up the border router**

1. Use the Script Border_Router_SetUp.sh to configure the border Router in your local machine

note: the border router script was written by refering to fit-iot lab tutorial for which the reference have been provided below

Usage ./Border_Router_SetUp.sh <username of fit-iotlab> <password of fitiotlab> <default channel>

After executing this you will get the below results on successful execution. 

executing : ssh root@node-a8-103 "cd ~/A8/riot/RIOT/dist/tools/ethos; ./start_network.sh /dev/ttyA8_M3 tap0 ::/64 500000"

net.ipv6.conf.tap0.forwarding = 1

net.ipv6.conf.tap0.accept_ra = 0

- ---> ethos: sending hello.
- ---> ethos: activating serial pass through.
- ---> ethos: hello reply received

uhcp_client(): no reply received

uhcp_client(): sending REQ...

got packet from fe80::303d:7fff:fe61:450c port 43239

uhcp: push from fe80::303d:7fff:fe61:450c:43239 prefix=::/64

gnrc_uhcpc: uhcp_handle_prefix(): add compression context 0 for prefix ::a4f3:513:cb16:ffc6/64

gnrc_uhcpc: uhcp_handle_prefix(): configured new prefix ::a4f3:513:cb16:ffc6/64

When you need to stop press “Ctrl+C” or “strg+C” because this keeps running.

You will be returned to your local machine again after exit.

Again login to ssh <login>@grenoble.iot-lab.info followed by, logging into node using  ssh root@node-a8-<nodenumber> (“ssh root@node-a8-103” in my above example), alternatively the node number can be seen in the “fitiot lab test bench” when we click experiment number

Now we can do a ifconfig and we will see a global ipv6 address which means Border router set up is success. Also we can ping [google.de](http://google.de) and see packets going so there is network access to the nodes as well.

This must work 95% of the time but sometime it doesn’t for other reasons. So please try after sometime or alternatively, we can try the commands manually in the terminal from the tutorial link mentioned in the Reference Links section.

**Challenges:**

We faced many issues with respect to setting up the border router and finally were able to set it up.

Other challenge was the paho C script was having some dependencies and errors which had to be sorted and this was more complicated than the problem statement,hence we had to revert to python.

The root node in the border router did not have any packages and we could not install anything as we dont have root access/permissions, so we could not set up a gateway between nodes of the border router to the AWS.

The first difficulty was nodes being available or connection refused. So try and book a couple of nodes extra, in case of failure. Second was Session timeout, also for this one give a little extra time for your experiment so that it doesn't terminate in between your setup. other challenge would be error in connection, so you can try to reboot.

# **Acknowledgement**

This Project Course was easier, hassle free and interactive under the guidance and mentorship of Prof Dr. Oliver Hahm(IoT Researcher/Expert). This paper is the final report for the course “HIS Project” titled IoT - Microcontroller to Cloud, A course work in fulfilment of the Master’s program High Integrity Systems (HIS) by Nidhi Nayak & Vedhavyas Mallya Ramesh.

**References Links**

[https://teaching.dahahm.de/](https://teaching.dahahm.de/)

[https://www.riot-os.org](https://www.riot-os.org/)

[https://www.iot-lab.info/learn/tutorials/riot/riot-public-ipv6-m3/](https://www.iot-lab.info/learn/tutorials/riot/riot-public-ipv6-m3/) - for border router

[https://www.iot-lab.info/](https://www.iot-lab.info/)

[https://mosquitto.org/](https://mosquitto.org/)

[https://aws.amazon.com/de/premiumsupport/knowledge-center/iot-core-publish-mqtt-messages-python/](https://aws.amazon.com/de/premiumsupport/knowledge-center/iot-core-publish-mqtt-messages-python/)

[https://github.com/crond-jaist/iotrain-lab/blob/master/database/fundamental_training/protocols/mqtt_protocol/README.md](https://github.com/crond-jaist/iotrain-lab/blob/master/database/fundamental_training/protocols/mqtt_protocol/README.md)
