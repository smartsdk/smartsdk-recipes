# MongoDB レプリカ・セット

このレシピは、MongoDB インスタンスの[レプリカ・セット](https://docs.mongodb.com/manual/replication/)を
 Docker Swarm にデプロイして制御することを目的としています。

<img src='http://g.gravizo.com/g?
digraph Cluster {
    rankdir=LR;
       compound=true;
       node [shape="record" style="filled"];
       splines=line;
       subgraph cluster {
               label="Docker Swarm";
        style=filled;
               color=aliceblue;
        subgraph cluster_1 {
            label="ms-worker0";
            color=white;
            Mongo2 [fillcolor="aliceblue"];
        }
        subgraph cluster_0 {
            label="ms-manager0";
            color=white;
            Controller [fillcolor="aliceblue"];
            Mongo1 [fillcolor="aliceblue"];
        }
        subgraph cluster_2 {
            label="ms-worker1";
            color=white;
            Mongo3 [fillcolor="aliceblue"];
        }
       }
    Mongo1 -> Mongo2 [dir="both"];
    Mongo2 -> Mongo3 [dir="both"];
    Mongo3 -> Mongo1 [dir="both"];
    Controller -> Mongo1;
}
'>

## 要件

[ウェルカム・ページ](../../index.md)を読み、[インストール・ガイド](../../installation.md)で説明されている手順に従ってください。

## 使い方

まず、Docker Swarm (docker >= 1.13) を既にセットアップしておく必要があります。セットアップが必要な場合は、ローカルの swarm をセットアップするための簡単な方法については[ツール・セクション](../../tools/readme.md)をチェックしてください。

```
$ miniswarm start 3
$ eval $(docker-machine env ms-manager0)
```

次に、この同じフォルダから単純に次のコマンドを実行します...

```
$ source settings.env  # In Windows, simply execute settings.bat instead.
$ docker stack deploy -c docker-compose.yml mongo-rs
```

イメージがノードでプルされ、サービスが展開されている間、少し時間を置いてください。数分後に、いつものようにすべてのサービスが稼働しているかどうかを確認できます...

```
$ docker service ls
ID            NAME                            MODE        REPLICAS  IMAGE
fjxof1n5ce58  mongo-rs_mongo             global      3/3       mongo:latest
yzsur7rb4mg1  mongo-rs_mongo-controller  replicated  1/1       martel/mongo-replica-ctrl:latest
```

## ウォークスルー

以前に示したように、レシピは基本的に2つのサービス、すなわち mongo インスタンス用とレプリカ・セット用の2つのサービスで構成されています。

mongo サービスは "global" モードで展開されます。つまり、Docker はクラスタ内の swarm ノードごとに mongod のインスタンスを1つ実行します。

swarm のマスター・ノードでは、mongodb のレプリカ・セットを設定して維持するための Python ベースのコントローラ・スクリプトがデプロイされます。

コントローラが `mongo-rs_controller` サービスのログを精査したことを確認しましょう。これはいずれかで行うことができます...

```
$ docker service logs mongo-rs_controller
```

または、以下を実行します...

```
$  docker logs $(docker ps -f "name=mongo-rs_controller" -q)
INFO:__main__:Waiting some time before starting
INFO:__main__:Initial config: {'version': 1, '_id': 'rs', 'members': [{'_id': 0, 'host': '10.0.0.5:27017'}, {'_id': 1, 'host': '10.0.0.3:27017'}, {'_id': 2, 'host': '10.0.0.4:27017'}]}
INFO:__main__:replSetInitiate: {'ok': 1.0}
```

ご覧のとおり、レプリカ・セットは、同じオーバーレイ・ネットワーク上で動作する
コンテナによって表される 3つのレプリカで構成されていました。mongo コンテナの
いずれかで mongo コマンドを実行して、同じ結果を表示するために `rs.status()` を
実行することもできます。

```
$ docker exec -ti d56d17c40f8f mongo rs:SECONDARY> rs.status()
```

## レプリカ・セットの再スケーリング

新しいノードを `swarm` に追加して、docker が mongo サービスの新しいタスクを
どのようにデプロイし、コントローラーがそれを自動的にレプリカ・セットに追加する
かを見てみましょう。

```
# First get the token to join the swarm
$ docker swarm join-token worker

# Create the new node
$ docker-machine create -d virtualbox ms-worker2
$ docker-machine ssh ms-worker2

docker@ms-worker2:~$ docker swarm join \
--token INSERT_TOKEN_HERE \
192.168.99.100:2377

docker@ms-worker2:~$ exit
```

ホストに戻って、数分後に...

```
$ docker service ls
ID            NAME                            MODE        REPLICAS  IMAGE
fjxof1n5ce58  mongo-rs_mongo             global      4/4       mongo:latest
yzsur7rb4mg1  mongo_mongo-controller  replicated  1/1       martel/mongo-replica-ctrl:latest

$ docker logs $(docker ps -f "name=mongo_mongo-controller" -q)
...
INFO:__main__:To add: {'10.0.0.8'}
INFO:__main__:New config: {'version': 2, '_id': 'rs', 'members': [{'_id': 0, 'host': '10.0.0.5:27017'}, {'_id': 1, 'host': '10.0.0.3:27017'}, {'_id': 2, 'host': '10.0.0.4:27017'}, {'_id': 3, 'host': '10.0.0.8:27017'}]}
INFO:__main__:replSetReconfig: {'ok': 1.0}
```

ノードがダウンすると、レプリカ・セットは mongo によってアプリケーションのレベルで自動的に再構成されます。一方、Docker は、ノードごとに1つしか実行されないため、レプリカのスケジュールを変更しません。

_注_ : swarm のすべてのノードにレプリカを配置したくない場合は、現在の解決策は、
制約とノード・タグの組み合わせを使用することです。これについて、
[Github の issue](https://github.com/docker/docker/issues/26259) で詳しく
読むことができます。

詳細は、[mongo-rs-controller-swarm](https://github.com/smartsdk/mongo-rs-controller-swarm)
リポジトリ、特に [docker-compose.yml](https://github.com/smartsdk/mongo-rs-controller-swarm/blob/master/docker-compose.yml)
ファイルまたは [replica_ctrl.py](https://github.com/smartsdk/mongo-rs-controller-swarm/blob/master/src/replica_ctrl.py)
 コントローラのスクリプトを参照してください。
