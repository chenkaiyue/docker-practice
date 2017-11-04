etcd
etcdctl set testkey hello
etcdctl update testkey world
etcdctl rm testkey
etcdctl watch testkey
etcdctl exec-watch testkey --sh -c 'ls'