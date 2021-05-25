# Redis Sentinel配置

## 设置监控

- Sentinel monitor def_master  [ip] [port] [检测次数,如果失效就换其他的slave为master]

## 密码认证,设置 sentinel密码

- sentinel auth_pass **def_master** [password]

## 设置sentinel和master通信多长时间连接不上就算失效了呢？

- sentinel down-after-millisenconds def_master [3000,默认30秒](单位毫秒)

##master被当前sentinel实例认定为“失效"的间隔时间

##如果当前sentinel与master直接的通讯中,在指定的时间内没有相应或者没有相应错误代码,那么当前sentinel就会认定master失效(SDOWN,主观失效)

##<mastername><millseconds>

## 设置sentinel 允许故障转移

- sentinel can-failover **def_master** yes   (为yes的话是设置这个sentinel操作 slave 为 master)

##当sentinel实例是否允许实施 ”failover“(故障转移)

##no表示当前sentinel为"观察者" （只参与投票,不参与实施failover)

##全局中至少有一个为 yes

注意  **def_master** 他们的名称是自定义的,可以自定义但是应用的时候必须相同

## 同时指定几台slave到新的master上

- sentinel parallel-syncs master [指定的salve 数量]
- 如果同时指定太多的话会导致IO剧增

## 设置指定时间sentinel转移时间,如果没有帮助我们完成转移,就代表失败

- sentinel failover-timeout def_master [900000(单位:毫秒)]

## 设置sentinel主从替换转移的优先级

- 可以再 redis.conf配置文件中 设置 slave priority (priority  优先级) 优先级越低越好
- (官方注释:)A slave with a low priority number is considered better for promotion, so for instance if there are three slaves with priority 10, 100, 25 Sentinel will,pick the one with priority 10, that is the lowest

## 监控工具 sentinel

![Redis%20Sentinel%E9%85%8D%E7%BD%AE%20c0d269070d5e4fa388cabb050b0ba32d/a.png](Redis%20Sentinel%E9%85%8D%E7%BD%AE%20c0d269070d5e4fa388cabb050b0ba32d/a.png)

> Sentinel不断与master通信,获取master的slave信息.
监听master与slave的状态
如果某slave失效,直接通知master去除该slave.
如果master失效,,是按照slave优先级(可配置), 选取1个slave做 new master
,把其他slave--> new master
疑问: sentinel与master通信,如果某次因为master IO操作频繁,导致超时,
此时,认为master失效,很武断.
解决: sentnel允许多个实例看守1个master, 当N台(N可设置)sentinel都认为master失效,才正式失效.
Sentinel选项配置
port 26379 # 端口
sentinel monitor mymaster 127.0.0.1 6379 2 ,
给主机起的名字(不重即可),
当2个sentinel实例都认为master失效时,正式失效
sentinel down-after-milliseconds mymaster 30000 多少毫秒后连接不到master认为断开
sentinel can-failover mymaster yes #是否允许sentinel修改slave->master. 如为no,则只能监控,无权修改./
sentinel parallel-syncs mymaster 1 , 一次性修改几个slave指向新的new master.
sentinel client-reconfig-script mymaster /var/redis/reconfig.sh ,# 在重新配置new master,new slave过程,可以触发的脚本

## 开启哨兵模式

```bash
# 必须加上 --sentinel 意思是以哨兵模式启动
# 不加上会报错 sentinel directive while not in sentinel mode

src/redis-server sentinel.conf **--sentiel**
```