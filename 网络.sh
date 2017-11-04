## 网络
docker run -d -P webapp python app.py
docker logs
映射所有接口地址
docker run -d -p 5000:5000 webapp python app.py
映射指定地址的指定端口
docker run -d -p 127.0.0.1:5000:5000 webapp python app.py
映射到指定地址的任意端口
docker run -d -p 127.0.0.1::5000
指定udp
dokcer run -p 5000:5000/udp

查看映射端口配置
$ docker port nostalgic_morse 5000
127.0.0.1:49155.

容器互联： --link
docker run -d --name db postgres
docker run -d -P --name web --link db:db webapp python app.py

通过环境变量(env)和/etc/hosts注册连接信息(解析域名和ip地址)
docker run --rm --name web2 --links db:db webapp env

容器的dns是通过挂载主机中的/ect/reslove.conf来进行更新和同步的
-h hostname    会被写到容器内的/ect/hostname和/etc/hosts中
--link 会被写到/etc/hosts中
--dns  会被写到/etc/reslove.conf

容器之间网络互通: -icc=ture/false
默认设置在/etc/default/docker 中配置DOCKER_OPTS=--icc=false
sudo iptables -nL


默认情况下，容器可以主动访问到外部网络的连接，但是外部网络无法访问到容器
容器所有到外部网络的连接，源地址都会被NAT成本地系统的IP地址。这是使用 
iptables 的源地址伪装操作实现的。

如果希望永久绑定到某个固定的 IP 地址，可以在 Docker 配置文件 /etc/default/docker 中
指定 DOCKER_OPTS="--ip=IP_ADDRESS"，之后重启 Docker 服务即可生效

外部访问容器使用-p，实际上也是通过本地的iptables实现的
iptables -t nat -nL
Chain DOCKER (2 references)
target     prot opt source               destination
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:49153 to:172.17.0.2:80

配置docker0网桥
sudo apt-get install bridge-utils
sudo brctl show
ip addr show eth0
ip route
删除旧网桥
sudo service docker stop
sudo ifconfig docker0 down 或者 sudo ip link set dev docker0 down
sudo brctl delbr docker0

创建网桥
sudo brctl addbr bridge0
sudo ip addr add 192.168.5.1/24 dev bridge0
sudo ifconfig bridge0 up 		sudo ip link set dev docker0 up

查看网桥：
ip addr show bridge0


创建一个点到点连接：
mkdir -p /var/run/netns
ln -s /proc/2989/ns/net /var/run/netns/2989

sudo ip link add A type veth peer name B

sudo ip link set A netns 2989
sudo ip netns exec 2989 ip addr add 10.1.1.1/32 dev A
sudo ip netns exec 2989 ip link set A up
sudo ip netns exec 2989 ip route add 10.0.0.1/32 dev A

sudo ip link set B netns 3004
sudo ip netns exec 3004 ip addr add 10.0.0.2/32 dev B
sudo ip netns exec 3004 ip link set B up
sudo ip netns exec 3004 ip route add 10.1.1.1/32 dev B




sudo docker run -it --net=none busybox /bin/bash
创建网络命名空间
sudo mkdir -p /var/run/netns
sudo ln -s /proc/$pid/ns/net /var/run/netns/$pid

sudo ip link add A type veth peer name B
sudo brctl addif docker0 A
sudo ip link set A up

sudo ip link set B netns $pid
sudo ip netns exec $pid ip link set dev B name eth0
sudo ip netns exec $pid ip link set eth0 up
sudo ip netns exec $pid ip addr add 172.17.42.9/16 dev eth0
sudo ip netns exec $pid ip route add default via 172.17.42.1