# 最佳实践
使用不同的目录来进行不同环境的隔离。
dev、stage、sit、prod。方便管理，灵活释放与创建
![image](https://github.com/myysophia/terraform-repo/assets/25994521/fd410ad7-3d93-4ece-86c5-b7c94a669f81)
# 状态管理架构

![image](https://github.com/myysophia/terraform-repo/assets/25994521/1a915335-f9dd-4c69-8a21-8d5a1d0a0101)

# 问题点
【1】对于资源释放需要有顺序
如果先把bucket释放了，web-clusrer中使用了这个bucket，是无法destroy的。
mysql 的tfstate存储在s3 的bucket中，如果bucket被删除了，tf 将无法再管理这个mysql，这个mysql将是游离状态的。
所以tf 的状态最好是在S3 存储并使用dynamicDB加锁避免多人同时操作资源。

# 注意
IaC 不同于普通编程，错误往往是毁灭性的。你整个数据存储、网络拓扑、所有一切的基础设施。所以务必小心。