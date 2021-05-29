# Redis 基本认知

Redis 是 AP 架构，在集群中，client 向 master 发送写请求，master 成功写完之后，就会向 client 发送成功，然后再异步向 slave 发送写请求。





Redis 基于 Reactor模式开发了网络事件处理器，这个处理器叫做文本事件处理器

#### 文本事件处理器：

如果客户端要连接 redis，那么会为 socket 关联连接应答处理器。																																								如果客户端要写数据导 redis，那么会为 socket 关联命令请求处理器。																																						如果客户端要从 redis 读取数据，那么会为 socket 关联命令回复处理器。

![redis架构图](F:\自我总结qwq\消息队列面试题\照片\redis架构图.png)

#### Redis 单线程效率高原因：

1.）纯内存操作

2.）核心基于非阻塞的 IO 多路复用机制

3.）避免了多线程的频繁上下文切换











# redis 主从架构设计



>  如何保证 redis 的高并发和高可用？

>  redis 的主从复制原理能介绍一下吗？

>  redis 的哨兵原理能介绍一下吗？







redis 是整个大型的缓存架构中，支撑高并发架构里面非常重要的一个环节，但是只有 redis 是远远不够的。

首先，你底层的中间件、缓存系统，必须能支撑我们说的高并发，其次，再经过良好的整体的缓存架构设计（多级缓存架构、热点代码的缓存）



单机 redis 支持 1w ~ 5w 之间

**redis 主从架构  ->  读写分离架构  ->  可支持水平扩展的读高并发架构**



redis replication 的核心机制：

1. redis 采用异步方式复制数据到 slave 节点，不过 redis. 2.8 开始，slave node 会周期性确认自己每次复制的数据量
2. 一个 master node 可以配置多个 slave node 的
3. slave node 也可以连接其它的 slave node
4. slave node 做复制的时候，是不会 block master node 的正常工作的
5. slave node 在做复制的时候，也不会对 block 自己的查询操作，他会用旧数据来提供服务；但是复制完成的时候，需要删除旧数据加载新数据，这个时候暂停服务
6. slave node 主要用来进行横向扩容，做读写分离，扩容的 slave node 可以提高读的吞吐量。



#### master 的持久化对于主从架构的安全保障的意义：

1.）采用了主从架构，建议必须开启 master node 的持久化。

2.）不建议使用 slave node 作为 master node 的数据热备，如果你关掉 master 的持久化，可能在 master 宕机重启之后，master 数据是空的，然后一经过复制，slave node 的数据也空了。

3.）即使采用了 哨兵，slave node 自动接管 master node，但是也可能 sentinal 还没有检测到 master 自动重启，还是可能导致 master、slave node 数据全变空。



**master 的各种备份方案**

​	万一说本地的所有文件全部丢失；从备份中挑选一份 rdb 去恢复 master，



### 主从架构核心原理

**1.核心原理**

- slave  第一次连接 master，会进行**全量复制**，开始全量复制的时候，master bgsave 开启后台线程，生成 RDB 快照文件，同时还会将从客户端收到的所有写请求写入到**复制缓冲区**，RDB 文件生成后，master 将这个RDB 文件发送给 slave，等 RDB 文件传输完成，并且在 slave 加载完成后，主节点再把复制缓冲区中的写命令发给从节点，进行同步
- slave 于 master 断开连接后，master 接收到的命令写入 **复制积压缓冲区**。slave 重连后，向 master 发送 runid、offset。master 先对 runid 进行对比，判断是否和本节点是否一致，然后 master 对 offset 进行对比，offset 在复制积压缓冲区之间，master 向 slave 发送 contine，此时 slave 只需要等待 master 传回失去连接期间丢失的命令。若 runid 不一致、offset 差距大于复制积压缓冲区，进行全量复制。
- slave node 如果和 master node 有网络故障，断开了连接，会自动重连。master 如果发现有多个 slave node 都来重新来连接，仅仅会启动一个 RDB 的 bgsave 操作，用一份数据服务所有 slave node。
- slave 与 master 建立连接后，master 写一条数据，就发送 slave 一条。



**复制积压缓冲区(replication backlog buffer)：默认 1 M**

master 与 slave 进行常规同步用的是复制积压缓冲区

主节点和从节点进行常规同步时，会把写命令也暂存在复制积压缓冲区中。如果从节点和主节点间发生了网络断连，等从节点再次连接后，可以从复制积压缓冲区中同步尚未复制的命令操作。对主从同步的影响：如果从节点和主节点间的网络断连时间过长，复制积压缓冲区可能被新写入的命令覆盖。此时，从节点就没有办法和主节点进行增量复制了，而是只能进行全量复制。针对这个问题，应对的方法是调大复制积压缓冲区的大小


**复制缓冲区(replication_buffer )**

master 与 slave 进行全量复制用的是复制缓冲区

当主节点向从节点发送 RDB 文件时，如果又接收到了写命令操作，就会把它们暂存在复制缓冲区中。等 RDB 文件传输完成，并且在从节点加载完成后，主节点再把复制缓冲区中的写命令发给从节点，进行同步。对主从同步的影响：如果主库传输 RDB 文件以及从库加载 RDB 文件耗时长，同时主库接收的写命令操作较多，就会导致复制缓冲区被写满而溢出。一旦溢出，主库就会关闭和从库的网络连接，重新开始全量同步。可以通过调整 **client-output-buffer-limit slave** 这个配置项，来增加复制缓冲区的大小，以免复制缓冲区溢出。




**2.主从复制的断点续传：**

redis2.8 开始支持 增量复制（backlog）

在全量复制过程中，master 与 slave 之间的网络连接断掉，那么 slave 重新连接 master 时，会触发增量复制







**3.无磁盘化处理：**

master 在内存中直接创建rdb，然后发送给 slave，不会在本地落地磁盘了，而默认处理是 master 先在本地磁盘保存 rdb，然后发送给 slave。

repl-disk-sync  no      （默认是 no，也就是磁盘化处理）。

repl-diskless-sync-delay	5           (等待 5 s 一定时长再开始复制，因为要等更多slave 连接进来，这样只会bgsave 一次)。



**4.过期 key 处理：**

slave 不会过期 key，只会等待 master 过期 key，如果 master 过期了一个 key，或者通过 LRU 淘汰了一个 key，那么就会模拟一条 del 命令发送给 salve。







### 1.复制的完整流程

1.）slave node 启动后，仅仅保存master node 的信息，包括master node的host和ip，但是复制流程未开启

2.）slave node内部有个定时任务，每秒检查是否有更新的 master node要连接和复制，如果发现，就跟 master node 建立 socket 网络连接。

3.）slave node 发送 ping 命令给 master node

4.）口令认证，如果 master 设置了 requirepass，那么 slave node 必须发送masterauth的口令过去进行认证

5.）master node 第一次执行全量复制，将所有数据发送给 slvae node

6.）master node 后续持续将写命令，同步复制给 slave node



### 2.数据同步相关的核心流程：

**2.1 ）master 和 slave 都会维护一个 offset**

master 会在自身不断累加 offset，slave 也会在自身不断累加 offset，slave 每秒上报自己的 offset 给master，同时master 也会保存每个 slave 的 offset。



**2.2）backlog：（复制积压缓冲区 rel_back_buffer）：**

有了slave 才创建 backlog ，也是有了 slave 之后才开始发挥作用

多个 salve 共用一个 master 的 backlog。当没有 slave 连接的时候，master 可以设置 backlog 的存活时间。

master node 有一个 backlog，默认是 1M 大小，

master node 给 slave node 复制数据时，也会将数据在 backlog 中复制一份。

防止网络中断，slave 重新连接 master ,会直接进行 增量复制的措施。



**2.3）master run id**

每个 redis 都会自己随机的 run id，一旦重启 run id发生变化，master 重启或数据发生变化，slave 根据 run id区分，run id 不同就会做全量复制。

如果需要不更改 run id 重启 redis，可以使用 redis-cli debug reload 命令



**4.）psync**

从节点使用 psync 从 master 进行复制，发送 psync、run id、offset。

master 根据自身情况返回响应信息，可能是 fullresync  runid  offset 触发全量复制，或 continue 触发增量复制。



### 3.全量复制

> backlog（复制积压缓冲区 replication_backlog_buffer）：保存在主节点固定长度的队列，默认 1MB

固定长度的 FIFO 队列，大小由配置参数 repl_backlog_size 指定，由 master 维护，有且仅有一个。

保存新的写命令，还保存了每个字节相应的复制偏移量。

master 与 slave 常规同步过程中，master 会把写命令也保存在 rel_back_buffer 中，slave 与 master 断线后，master 接收到的写命令依然写入到 复制挤压缓冲区，slave 重新连接后，master 会判断 slave 发送的 offset 判断是否在 backlog 区间之内。是否执行 增量复制。

> 复制缓冲区（replication_buffer）：在复制期间，rel_buffer持续消耗超过 64MB，或者一次性超过 256MB，停止复制，复制失败。

master 和 slave 进行全量复制时，会在 master 创建出 rel_buffer ，发送 rdb 文件时，如果又接收到了 写命令操作，就会把它缓存到 rel_buffer 中，rdb 完成后，将 rel_buffer 中的数据发送给 slave。若 rdb 发送中，rel_buffer 溢出，重新开始全量同步。可调整 client_output_buffer_limit slave 配置增加 rel_buffer 大小。（rdb 同步完后，会把 rel_buffer 进行回收）

> 造成全量复制失败的因素

1.）master 将 rdb 快照文件发送给 slave ，如果 rdb 复制时间超过 **60s（repl-timeout：默认时间）**slave node 就会认为复制失败，可以适当调节这个大小。

2.）rel_buffer：       master 与 slave rdb 同步过程中，master 会将所有新的写命令缓存在内存，在复制期间，内存缓冲区持续消耗超过 64MB，或者一次性超过 256MB，停止复制，复制失败。



### 4.增量复制（默认关闭）

master node 有一个 backlog，默认是 1M 大小，master node 给 slave node 复制数据时，也会将数据在 backlog 中复制一份。网络中断后，slave 断开连接，当所有  slave 断开连接 master 也会将命令写入 backlog 中，直到达到指定时间后，清除 backlog。

slave 无重启，当 slave 重新连接 master 时，master 会对 slave 发送过来的 offset 与 自己的 offset 进行判断，看是否在 backlog 区间内，在的话就把 backlog的数据发送给 slave，> backlog 区间的话，进行全量复制。



![全量复制](F:\自我总结qwq\消息队列面试题\照片\全量复制.png)



















# 哨兵（sentinel）



**主要功能：**

1.）集群监控：复制监控redis master、redis slave 进程是否正常工作。

2.）消息通知：如果某一个 redis 有故障，那么哨兵负责发送消息作为报警通知给管理员。

3.）故障转移：如果 master 挂掉了，从 slave 中推举出新的 master node。

4.）配置中心：如果故障转移发生了，通知 client 客户端更新新的 master 地址。



**哨兵本身也是分布式的，作为一个哨兵集群去运行，互相协同工作。**

1. 故障转移时，判断一个 master node 是否宕机，需要大部分的哨兵都同意才行，设计到了分布式选举的问题
2. 即使部分哨兵节点挂掉了，哨兵集群还是能正常运行的，如果作为一个高可用机制重要组成部分的



**哨兵的核心知识点**

- 哨兵至少需要 3 个实例，来保证自己的健壮性
- 哨兵 + redis 主从架构，是不会保证数据零丢失的，只能保证 redis 集群的高可用性
- 对于哨兵 + redis 主从这种复杂的部署架构，尽量在测试环境和生产环境进行充足的测试和演练



### 两种数据丢失的情况

主备切换的过程，可能会导致数据丢失

#### 1.异步复制导致的数据丢失

Redis 是 AP 架构，在集群中，client 向 master 发送写请求，master 成功写完之后，就会向 client 发送成功，然后再异步向 slave 发送写请求。

因为 master -> slave 的复制是异步的，所以可能有部分数据还没有复制到 slave ，master 就宕机了。此时这部分数据就丢失了。

#### 2.脑裂导致的数据丢失（网络分区）

某个 master 突然脱离了正常的网络，跟其他 slave 不能连接，但是还能进行正常的写命令，还继续写向旧 master 的数据可能丢失，

哨兵认为 master 宕机，开始选举，推举出一个 slave 切换成了新的 master，此时旧 master 回来了，集群有两个 master，就是所谓的脑裂，

client 没来得及更新 master 节点，还继续写向 旧master，此时 旧master 恢复，会被作为 slave 挂到新的 master 上，自己的数据会被清空，重新复制新的 master，造成数据丢失。 



### 解决异步复制和脑裂导致的数据丢失

（把丢失数据降低到可控范围之内）

min-slaves-to-write 1                               要求至少有 1 个slave，数据复制和同步的延时不能超过 10 s

min-salves-max-lag 10							如果说一旦所有的 slave，数据复制和延迟都超过 10 s，那么 master 拒绝写请求。

上面两个配置可以减少异步复制和脑裂导致的数据丢失

#### 1.减少异步复制的数据丢失

min-slaves-max-log ：一旦 slave 复制数据和 ACK 延时太长，就认为可能 master 宕机后损失的数据太多了，那么 master 就拒绝写请求，可以把 master 宕机时由于部分数据未同步到 slave 导致的数据丢失降低到可控范围内。

#### 2.减少脑裂导致的数据丢失

因为不做控制，  client 一直向 旧 master 写数据写入了 10 分钟，那么旧 master 重新连接上集群，那么会导致 10 分钟的数据丢失，如果配置了这两个配置参数，那么  clinet 最多向 旧master 写入 10s。





#### 1.主观与客观宕机

sdown：主观宕机，一个哨兵认为 一个 master 宕机，就是主观宕机。

odown：客观宕机，超过 quorum 数量的哨兵认为 一个 master 宕机，那么就是客观宕机。

sdown 达成的条件：如果一个哨兵 ping 一个 redis，超过了 is-master-down-after-milliseconds 指定的毫秒数之后，就主观认为 master 宕机。

sdown 到 odown 转换的条件：如果一个哨兵在指定时间内，收到了 quorum 指定数量的其他哨兵也认为那个 master 是 sdown，那么就认为是 odown（客观宕机）。





#### 2.哨兵集群的自动发现机制

哨兵之间的互相发现是通过 reids 的 pub/sub（发布订阅）实现的，_sentinel _: helle 这个 channel 发送消息，这时候其它哨兵都可以得到消息，并感知其它哨兵的存在。

每隔 2 s，每个哨兵都会往自己监控的某个 master + slaves 对应的 _sentinel _: helle  channel 发送消息（自己的 host、ip、runid还有对mater 的监控配置）

每个哨兵还会跟其它哨兵交换对 master 的监控配置，互相进行监控配置的同步。



#### 3.slave 配置的自动纠正

哨兵会自动纠正 slave 的一些配置，比如 salve 如果成为 master 候选人，哨兵会确保 salve 复制现有 master 的数据，故障转移后，哨兵为其它 salve 连接到争取的 master 上。



#### 4.salve - master 的选举算法



master 宕机，选举 slave 节点为新的 master 考虑的因素：

（1.）跟 master 断开连接的时长

（2.）slave 优先级

（3.）offset（复制偏移量）

（4.）run id

如果一个 slave 跟 master 断开连接已经超过了 dowm-after-milliseconds 的 10 倍 + master 宕机的时长，那么此 slave 被认为不适合选举为 master。

​                                                      （dowm-after-milliseconds * 10 ） + milliseconds_since_master_is_in_SDOWN_state

接下来会对 slave 进行排序：

（1.）按照 slave 优先级进行排序，salve priority （**配置参数**）越低，优先级越高。

（2.）若 slave priority 相同，看 offset ，哪个 slave 复制了越多的数据、offset 越大越靠后，优先级越高

（3.）上面两个都相同，那么选择一个 run id 比较小的 slave 推举为 master。





#### 5.quorum 与 majority（大多数）

majority 的计算方式为：sentinel 数量 / 2 + 1

- 2 个哨兵的 majority = 2，3 个哨兵的 majority = 2，4 个哨兵的 majority = 2，5 个哨兵的 majority = 3

quorum：指定的个数，在 odown（客观下线发挥作用）

一个哨兵要做主备切换，首先需要 quorum 数量的哨兵认为 odown，然后选举出一个哨兵来做切换，这个哨兵还要的到 majority 哨兵的授权，才能正式执行。

（1.）**quorum < majority** :  比如 5 个哨兵，majority = 3，quorum 设置为 2，那么 3 个哨兵授权就可以执行主备切换。

（2.）**quorum >= majority** ：比如 5 个哨兵，majority = 3，quorum 设置为 5，必须 quorum 数量的哨兵都授权，才能执行主备切换。



所以 sentinel集群的节点个数至少为3个，当节点数为2时，假如一个 sentinel 节点宕机，那么剩余一个节点是无法让自己成为 leader 的，因为2个节点的sentinel 集群的 majority是2，此时没有2个节点都给剩余的节点投票，也就无法选择出leader，从而无法进行故障转移。另外最好把quorum的值设置为 <= majority，否则即使 sentinel 集群剩余的节点满足majority数，但是有可能不能满足quorum数，那还是无法选举leader，也就不能进行故障转移。



#### 6.configuration epoch   

哨兵会对一套 redis master + slave 进行监控，有相应的监控的配置

执行切换的哨兵，会从新的 master 那里得到 configuration epoch，这是一个 version 号，每次切换的 version 号必须是唯一的

如果哨兵切换 master 节点失败,那么其它哨兵会等待 failover-timeout 时间，然后接替继续执行切换，此时会重新获取 configuration epoch 作为新的 version 号



#### 7.configuration 传播

哨兵切换成功之后，会在自己本地更新生成最新的 master 配置，然后同步给其他哨兵，就是通过 redis 的 pub/sub 消息机制

这里之前 version 号就很重要了，因为各种消息都是通过一个 channel 去发布和监听的，所以一个哨兵完成一次新的切换后，新的 master 配置 和 version 是一块的，其它哨兵都是根据 version 号的大小来更新自己的 master 配置。





### redis 如何支持 高并发、高可用

redis 高并发：采用主从架构，一主多从，一般来说，很多项目其实就足够了，单主用来写入数据是每秒 几万 QPS，多从用来查询数据，每个实例可以提供每秒 10 万的 QPS。

redis 高并发的同时，还需要容纳大量数据：一主多从，每个实例都容纳了完整的数据，这时候就需要 redis 集群。而且用了 reids 集群后，可以提供每秒几十万的读写并发。

redis 高可用：如果采用了 主从架构，其实加上哨兵就可以了。





## Redis的持久化

持久化主要是做灾难恢复，数据恢复，也可以归类到高可用的一个环节里面去。

通过持久化将数据搞一份在磁盘上，然后定期同步和备份到一些云存储服务上，可以保证数据不丢失全部。



RDB：对 Redis 中的数据执行周期性的持久化。（就是一份数据文件，恢复的时候直接加载到内存即可）

AOF：对每条写入命令作为日志，以 append-only 模式写入一个日志文件中。  存放的指令日志，做数据恢复的时候，其实是要回放和执行所有的指令日志，来恢复出来内存中的所有数据。

文件策略：如存在老的 RDB 文件，默认新替换老。

#### RDB优点

（1.）RDB 会生成多个数据文件，每个数据文件都代表了某一个时刻中 redis 的数据，这种多个数据文件的方式，非常适合做冷备，可以将这种数据发送到 阿里云 这种远程的安全存储上面去，以预定好的策略来定期备份 reids 中的数据。

（2.）RDB 对 redist 对外提供的读写服务，影响非常小，可以让 redis 保持高性能（bgsave：fork（）出一个子进程）

（3.）相对于 AOF 来说，直接基于 RDB 数据文件来来重启和恢复 redis 进程，更加快速。



#### RDB缺点

（1.）如果想要在 redis 故障时，尽可能少的丢失数据，那么 RDB 没有 AOF 好，一般来说 RDB 数据快照文件，都是每隔 5 min 或者更长时间生成一次，这个时候reids 宕机，那么会丢失最近 5 min 的数据。

（2.）RDB 的 fork（）来生成 子进程的时候 是同步，如果文件数据特别大，那么 redis 的服务就会被阻塞。

建议：一般不让生成 RDB 的时间过长，也就是不让 fock（）时间长。不适合做第一优先的恢复方案，会导致数据丢失的比较多。 



#### AOF 优点

（1.）AFO 更好的保存数据不丢失，一般 AOF 一秒一次，通过后台线程执行一次 fsync 操作。（最多丢失 2 s 数据）

（2.）AOF 日志文件以 append-only 模式写入，所以没有任何磁盘寻址开销，写入性能非常好。

（3.）AOF 文件过大，有 AOF 重写，在后台进行 重写操作。

#### AOF 缺点

（1.）对于同一份数据来说，AOF 日志文件通常比 RDB 数据快照文件要大。

（2.）AOF 开启后，支持的写 QPS 会比 RDB 支持的 QPS 要低，因为 AOF 一般 1s fsync 一次日志文件，当然 1s 一次 fsync 效率还是很高的。

#### AOF 重写

每次 rewrite 并不是基于旧的指令日志进行merge （合并）的，而是基于当时内存中的数据进行指令的重新构建，这样健壮性会高很多。













# Redis Cluster

Redis Cluster 解决的问题：单机 reids 在海量数据面前的瓶颈问题，**让 redis 支持海量数据。**

Redis Cluster主要针对于 海量数据 + 高并发 + 高可用的场景。

主从架构的缺点：能保存的数据容量，就是 master 的容量，无法进行扩展。

如果你得数据量是几G，那么可以采用主从架构的方式去搭建集群,Redis Cluster 可以保存 1T、乃至更多,因为可以保存多个 mster node 节点（**支持横向扩容**）



redis 集群模式的工作原理？

在集群模式下，redis 的 key 是如何寻址的？

分布式寻址都有哪些算法？

了解一致性 hash 算法吗？



### 一、Redis Cluster 架构

**（多 master + 读写分离 + 高可用）**

（1.）支持 N 个 master node，每个 master node 都可以挂载多个 slave node。

（2.）读写分离的架构：对于每个 master 来说，写就写到 master，读取从 master 对应的 slave 上读取。

（3.）高可用：因为每个 master 都有 slave ，如果 master 挂掉，redis cluster 这套机制，就会自动将某个 slave 切换成 master。



 我们只要基于 reids cluster 去搭建 redis 集群就可，不需要手工去搭建 replication （复制） + 主从架构 + 读写分离 + 哨兵集群 + 高可用。





### 二、核心原理分析

#### 1.基础通信协议

**redis cluster 节点间采用 gossip 协议进行通信。**

Redis Cluter 中的每个 redis 实例监听两个 TCP 端口，一个  **6379 (默认)** 用于服务 client，**16379（默认服务端口 + 10000**）用于集群内部通信。



##### gossip协议（小道流言）与 集中式存储

跟集中式不同，gossip 不是将集群元数据（节点信息，故障，等等）集中存储在某一个 节点上。而是互相之间不断通信，保持整个集群所有节点的数据是完整的

集中式的优点

- 元数据的更新和读取，时效性比较好，一旦元数据出现了变更，立即更新到集中式的存储中，其他节点读取的时候可以感知到。

集中式的缺点：

- 所有元数据的更新压力全部集中在一个节点，可能会导致元数据的存储有压力。（节点很多很多）

gossip的优点：

- 元数据的更新比较分散，不是集中在一个地方，更新请求会陆陆续续发送到所有节点上去，有一定的延时，降低了压力。

gossip的缺点：

- 元数据更新有延时，可能会导致元数据的存储有压力。



#### 2.gossip 协议的具体流程

集群中每个节点通过一定规则挑选要通信的节点，每个节点可能知道全部节点，也可能仅知道部分节点，只要这些节点彼此可以正常通信，最终它们会达到一致的状态。当节点故障、新节点加入、主从关系变化、槽信息变更等事件发生时，通过不断的ping/pong消息通信，经过一段时间后所有的节点都会知道集群全部节点的最新状态，从而达到集群状态同步的目的。



#### 3. 10000 端口 和 要交换的信息

每个节点都有一个专门用于节点间通信的端口，就是自己提供服务的端口号 + 10000，比如 client 访问 redis 7001，那么用于节点间通信的就是 17001 端口。

每个节点在固定周期内通过特定规则选择几个节点发送ping消息；接收到ping消息的节点用pong消息作为响应；

要交换的信息：故障信息、节点的增加和移除、hash slot 信息，等等。

#### 4.gossip协议

**gossip 协议：包含多种信息（ping、pong、meet、fail 等）**

meet：某个节点发送 meet 给新加入的节点，让新节点加入集群中，然后新节点就会开始与其他节点进行通信。

ping：每个节点都会频繁的给其他节点发送 ping，其中包含自己的状态还有自己维护的集群元数据，互相通过 ping 交换元数据。

pong：返回 ping 和 meet，包含自己的状态和其他信息，也可以用于信息广播和更新。

fail：某个节点判断另外一个节点 fail 之后，就发送 fail 给其它节点，通知其它节点，指定的节点宕机了。



#### 5.ping 消息深入

ping 是很频繁的，而且要携带一定元数据，所以可能会加重网络负担，

每个节点每秒会执行 10 次 ping，每次会选择 5 个最久没有通信的其它节点。（至少发送 3 个其他节点，最多包含总结点 - 2 个其它节点的）

若发现某个节点通信延迟达到了  cluster_node_timeout  /  2  ，那么就会立即发送 ping，避免数据交换延迟过长（整个集群的元数据不一致很糟糕）。

cluster_node_timeout 可以自己调节，如果调节过大，那么会降低发送频率。

每次 ping，一个是带上自己节点的信息，还有就是带上 1/10 自己保存的其它节点的数据，发送出去，进行数据交换。

至少包含 3 个其它节点的信息，最多包含 总结点 - 2 个其它节点的信息









### 三、数据分布算法

**hash 算法  --->  一致性hash 算法  --->  redis cluster 的 hash slot 算法**

用不同的算法，就决定了在多个 master 节点的时候，数据如何分布到这些节点上去。



**redis cluster hash slot :**

（1.）自动将数据进行分片，每个 master 上面放一部分数据。

（2.）提供内置的高可用支持，部分 master 不可用时，还是可以继续工作的。

redis cluster 有固定的 16384 个 hash slot，对每个 key 计算 CRC16 值，然后对 16384 取模，可以获取每个 key 的 slot。

redis cluster 中每个 master 都会持有部分 slot，会平均分配。

hash slot 让 node 的增加和移除变得很简单，增加一个 master ，就将其它 master 的 hash slot 移动部分过去，减少一个 master 就将他的 slot 移动到其它节点。（移动 slot 的成本十分低的）

![分布式13](F:\自我总结qwq\消息队列面试题\照片\分布式13.png)





**最老土的 hash 算法（大量缓存重建）。**

- 目前有三台 master，只要任意一个 master 宕机，宕机的 master 数据全部失效
- 一开始对 key 进行取余 key % 3，master 宕机后，所有请求都会基于最新的两个 master 取余 key % 2，尝试去取数据，导致几乎大部分的请求全部走 MySQL

**一致性 hash 算法**

- 哈希环
- 数据分布不一定均匀，可能集中在某个 hash 区间内的值特别多，导致大量的数据都涌入同一个 master 内，造成 master 的热点问题，性能瓶颈

 

**一致性 hash 算法（自动缓存迁移） + 虚拟节点（自动负载均衡）**

![分布式12](F:\自我总结qwq\消息队列面试题\照片\分布式12.png)



### 四、jedis smart 定位、主备切换



#### 4.1 什么是 jedis smart ？

基于重定向的客户端，很消耗网络 IO，大部分情况下，可能都会出现一次请求重定向，才能找到正确的节点

本地维护一份 hashslot  --->  node 的映射表、缓存，大部分情况下，直接走本地缓存就可以找到 hashsolt  --->  node，不需要通过节点进行 moved 重定向。



#### 4.2 JedisCluster 工作原理



#### 4.3 hash slot 迁移和 ask 重定向

如果 hash slot 正在迁移，那么会返回 ask 重定向给 jedis

jedis 收到 ask 重定向后，会重新定位到目标节点去执行，因为 ask 发生在 hash slot 迁移过程中，所以 JedisCluster API 收到 ask 是不会更新 hash slot 本地缓存

当确定 hash slot 迁移完，moved 是会更新本地  hash slot  --->  node 的映射表缓存的





### 五、高可用与主备切换

#### 5.1 判断节点宕机

如果一个节点认为另外一个节点宕机，那么就是 pfail，主观宕机

如果多个节点都认为另外一个节点宕机了，那么就是 fail，客观宕机，和哨兵的原理一样

在 cluster-node-timeout 内，某一个节点一直没有返回 pong，就被认为 pfail

如果一个节点认为某个节点 pfail 了，那么会在 gossip 消息中，ping 给其它节点，如果超过半数的节点都认为 pfail 了，那么就会变成 fail

#### 5.2 从节点过滤

对宕机的 master node，从其所有的 slave node 中，选择一个切换成 master node

检查每个 slave node 与 master node 断开连接的时间，如果超过了 cluster-node-timeout * cluster-slave-validity-factory，那么就没资格切换成 master



#### 5.3 从节点选举

每个从节点，都根据自己对 master 复制数据的 offset，来设置一个选举时间，offset 越大的从节点，选举时间越靠前

所有的 master node 开始投票，给所有的 slave 进行投票，如果大部分 master node（N / 2 + 1）都投票给了某个从节点，那么选举通过

从节点开始主备切换，从节点切换为主节点



#### 5.4 与哨兵相比

整个流程和哨兵相比，非常类似，所以说 redis cluster 非常强大，直接集成了 replication 和 sentinal 的功能





# 缓存

## 缓存雪崩

redis 挂掉，mysql 接收大量请求，直接挂死，只要 redis 没重启，mysql 开一次挂一次。

事前：redis 高可用，避免全盘崩溃。

事中：本低 ehcache 缓存 + sentinel 限流&降级，避免 mysql 直接被打死。

事后：redis 持久化，快速恢复缓存数据。



## 缓存穿透：

redis 查询不到就会去 mysql 找，在 mysql 找不到的话，证明不存在这个数据，如果有人恶意刷，就会导致 mysql 并发压力大。

### **解决方案一：**

**在 redis 对这个 key 设置 value 为 null。**

缺点：

如果大量不存在的 key 在 redis 进行了缓存，也就是设置 value 为 null，那么就会占用 redis 的大量内存空间，就算是设置了过期时间，那么也会导致 redis 的性能有所下降。



### **解决方案二：布隆过滤器**

可进行存入、查找，更新操作

不支持删除操作



布隆过滤器的数组结构： 是用 二进制 表示的

布隆过滤器是一个 bit 向量或者说 bit 数组，长这样：在 redis 中的数据结构就是 bitmap

![布隆1](F:\自我总结qwq\消息队列面试题\照片\布隆1.png)





> 用 谷歌的 封装好的工具类：Guava 已经封装好了 波隆过滤器



参数：误差率越小，消耗的时间越长，性能越差，所以误差率根据业务设置大小

误差率越小：占用的内存空间就越大，对 key 进行 hash （是不同的 hash 函数进行 hash 的） 的次数就越多



优点：

1、由一串二进制数组组成的一个数据，占据内存的空间小。

2、插入 和 查询 的速度是非常快的，基于数组的特性，根据 下标 进行 插入 和 查询 是非常快的。 

3、保密性好：存储的都是二进制数据，0  和 1，别人不知道是什么含义，本身不存储原始数据



缺点：

1、很难进行删除操作：在一个 bit 位上可能被多个 key 进行 hash 共用

2、会产生误判：在误判率设置的比较高的情况下，key 本身不在这个集合中，但是被 hash 出来的值可能被判断出来存在这个集合中。



```
public static void main(String[] args) {
	Config config = new Config();
	config.useSingleServer().setAddress("redis://127.0.0.1:6379");
	config.useSingleServer().setPassword("1234");
	
	//构造 redisson
	RedissonClient redisson = Redisson.create(config);
	
	RBloomFilter<String> bloomFilter = redisson.getBloomFilter("phoneList");
	// 初始化波隆过滤器:预计元素有 100000000L 个, 误差率为 3%
	bloomFilter.tryInit(100000000L,0.03);
	// 将号码 10086 添加进布隆过滤器中
	bloomFilter.add("10086");
	
	// 判断下面号码是否在布隆过滤器中
	System.out.println(bloomFilter.contains("123456"));                       // false
	System.out.println(bloomFilter.contains("10086"));                        // true
 }
```



### 布谷鸟过滤器









## 缓存一致性

（1.）读的时候，先读缓存，缓存没有的话，那么就读数据库，然后取出数据后放入缓存，同时返回响应。

（2.）更新的时候，先删除缓存，然后再更新数据库。



##### 2.为什么是删除缓存，而不是更新缓存呢？

原因很简单，很多时候，复杂点的缓存场景，不简单是从数据库中直接取出来的值，要经过多表查询进行复杂的运算。

更新缓存的代价是很高的。

每次修改数据库的时候，都一定要将其对应的缓存去更新一份？也许有的场景是这样，但是对于复杂的缓存数据计算的场景，就不是这样了

如果你频繁的修改某个表的一个字段，频繁的去更新缓存，但是问题在于，这个缓存会不会被频繁的访问到？？？

举个例子：一个涉及缓存的多个表， 1 min 修改了20次，那么缓存更新20次，但是这个缓存在 1 min 内就读取了 1次，有大量的冷数据。

2 8 法则，黄金法则，20% 的数据，占用了 80% 的访问量。

如果只是删除缓存，那么 1 min 内，这个缓存不过就重新计算一次而已，开销大幅度下降。

删除缓存（lazy 思想），不要每次都重新做复杂计算，不管它会不会用到，真正用到的时候再重新计算。



























