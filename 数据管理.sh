docker run -d -P --name web -v /webapp training/webapp python app.py
删除 docker rm -v

docker run -d -P --name web -v /src/webapp:/opt/webapp training/webapp python app.py

默认是读写，指定只读ro
docker run -d -P --name web -v /src/webapp:/opt/webapp:ro training/webapp python app.py

查看容器卷相关信息
docker inspect web

除了挂载目录，还可以直接挂载文件
docker run --rm -it  -v ~/.bash_history:/.bash_history ubuntu /bin/bash
可能造成文件inode的改变


数据卷容器：
sudo docker run -d -v /dbdata --name dbdata training/postgres echo "data-only"
docker run -d --volumes-from dbdata --name db1 training/postgres
还可以级联：
docker run -d --volumes-from db1 --name db2 training/postgres

备份：
docker run --volumes-from dbdata -v $(pwd):/backup ubuntu tar cvf /backup/backup.tar /dbdata


恢复：
docker run -v /dbdata --name dbdata2 ubuntu /bin/bash
docker run --volumes-from dbdata2 -v $(pwd):/backup busybox tar xvf /backup/backup.tar /dbdata
docker run --volumes-from dbdata2 dbdata2 busybox /bin/ls /dbdata











