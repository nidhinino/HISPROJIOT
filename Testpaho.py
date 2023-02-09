import time
import subprocess
from paho.mqtt import client as mqtt 

c = mqtt.Client("iotconsole-94cf18fd-2237-43c2-b0b5-3441a3ae892b")
c.tls_set("/senslab/users/nnayak/Certificates/AmazonRootCA1.crt", 
            certfile ="/senslab/users/nnayak/Certificates/f1b6aadce92a1c37c229a0e448d33b3c455d6b9de6b663730346719053aadbfe_certificate.pem.crt", 
            keyfile= "/senslab/users/nnayak/Certificates/f1b6aadce92a1c37c229a0e448d33b3c455d6b9de6b663730346719053aadbfe_private.pem")

c.connect("a3ssbjwvgchcxz-ats.iot.us-east-1.amazonaws.com", 8883, 45)
count = 0
time.sleep(1)
script_path = "/senslab/users/nnayak/generator.c" #use path of the generator file in grenoble
subprocess.call(["gcc", script_path])

while True:
    k=subprocess.check_output("./a.out")
    c.publish("awsiot_Hello",k, qos = 1)
    count = count + 1
    print(count)