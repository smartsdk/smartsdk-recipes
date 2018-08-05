# Orion in HA

このレシピでは、MongoDB インスタンスのスケーラブルな[レプリカ・セット](https://docs.mongodb.com/v3.2/replication/)
でバックアップされたスケーラブルな [Orion Context Broker](https://github.com/telefonicaid/fiware-orion/blob/master/README.md)
 サービスをデプロイする方法を示します。

すべての要素は docker-compose ファイルで定義された docker コンテナで実行
されます。実際、このレシピは、バックエンド用の mongodb レプリカ・レシピを
再利用して、Orion フロントエンドのデプロイに重点を置いています。

最終的なデプロイは、次の図で表されます :

<img src='http://g.gravizo.com/g?
  digraph G {
      rankdir=LR;
      	compound=true;
      	node [shape="record" style="filled"];
      	splines=line;
      	Client [fillcolor="aliceblue"];
      	subgraph cluster {
      		label="Docker Swarm Cluster";
      		"Load Balancer" [fillcolor="aliceblue"];
      		subgraph cluster_0 {
      			label="Orion Context Broker stack";
      			Orion1 [fillcolor="aliceblue"];
      			Orion2 [fillcolor="aliceblue"];
      			Orion3 [fillcolor="aliceblue"];
      		}
      		subgraph cluster_1 {
      			label="MongoDB Replica Set stack";
      			Mongo1 [fillcolor="aliceblue"];
      			Mongo2 [fillcolor="aliceblue"];
      			Mongo3 [fillcolor="aliceblue"];
      		}
      	}
      	Client -> "Load Balancer" [label="1026",lhead=cluster_0];
      	"Load Balancer" -> {Orion1,Orion2,Orion3};
      	Orion1 -> Mongo1 [lhead=cluster_1];
      	Orion2 -> Mongo1 [lhead=cluster_1];
      	Orion3 -> Mongo1 [lhead=cluster_1];
      	Mongo1 -> {Mongo2, Mongo3} [dir="both"];
  }
'>

## 前提条件

[ウェルカム・ページ](../../../index.md)を読み、[インストール・ガイド](../../../installation.md)
で説明されている手順に従ってください。

## 使い方

まず、Docker Swarm (docker >= 1.13) を既にセットアップしておく必要があります。
あなたが持っていない場合は、ローカルの swarm をセットアップするための簡単な方法
については[ツール](../../../tools/readme.md)セクションをチェックしてください。

```
$ miniswarm start 3
$ eval $(docker-machine env ms-manager0)
```

Orion は、バックエンド用の mongo データベースが必要です。すでにクラスタ内に
 Mongo をデプロイしていて、そのデータベースを再利用したい場合は、次のステップの
バックエンドのデプロイをスキップできます。Orion が Mongo にリンクするために定義
した変数、つまり、`MONGO_SERVICE_URI` に注意する必要があります。`settings.env`
 または Windows の `settings.bat` に正しい値を持っていることを確認してください。
`MONGO_SERVICE_URI` の値は、mongo のルーティング可能なアドレスでなければなりま
せん。swarm 内にデプロイされた場合は、stack プレフィックスを持つサービス名で
十分です。[公式 Docker ドキュメント](https://docs.docker.com/docker-cloud/apps/service-links/)
で詳細を読むことができます。[Mongo ReplicaSet Recipe](../../../utils/mongo-replicaset/readme.md)
 を使用した場合、デフォルト値はうまくいくはずです。

これで、設定を有効にして Orion を展開できます...

```
$ source settings.env  # In Windows, simply execute settings.bat instead.
$ docker stack deploy -c docker-compose.yml orion
```

ある時点で、デプロイは次のようになります...

```
$ docker service ls
ID            NAME                       MODE        REPLICAS  IMAGE
nrxbm6k0a2yn  mongo-rs_mongo             global      3/3       mongo:3.2
rgws8vumqye2  mongo-rs_mongo-controller  replicated  1/1       martel/mongo-replica-ctrl:latest
zk7nu592vsde  orion_orion                replicated  3/3       fiware/orion:1.3.0
```

上記のように、レプリカ列に `3/3` が表示されている場合は、3つのレプリカが起動して
実行中であることを意味します。

## ウォークスルー

次のコマンドを実行して、swarm から、サービス (別名タスク) のコンテナの配布を確認することができます...

```
$ docker service ps orion_orion
ID            NAME           IMAGE               NODE         DESIRED STATE  CURRENT STATE               ERROR  PORTS
wwgt3q6nqqg3  orion_orion.1  fiware/orion:1.3.0  ms-worker0   Running        Running 9 minutes ago
l1wavgqra8ry  orion_orion.2  fiware/orion:1.3.0  ms-worker1   Running        Running 9 minutes ago
z20v0pnym8ky  orion_orion.3  fiware/orion:1.3.0  ms-manager0  Running        Running 25 minutes ago
```

良いニュースは、上の出力からわかるように、デフォルトでは、Docker はすでに
サービスのすべてのレプリカの `context-broker_orion` を別のホストに配備して
いました。

もちろん、ラベル、制約、または展開モードを使用すると、swarm ノード間でタスクの
配布をカスタマイズする権限があります。`mongo-replica_mongo` サービスの展開を
理解するため、[mongo レプリカ・レシピ](../../../utils/mongo-replicaset/readme.md)
を表示できます。

さて、Orion にクエリを実行して、本当に稼働していることを確認しましょう。質問は、
今、Orion が実際に走っているところはどこですか？ 後でネットワーク内部をカバー
しますが、今はマネージャ・ノードに問い合わせましょう...

```
$ sh ../query.sh $(docker-machine ip ms-manager0)
```

次のようなものが得られます...

```
{
  "orion" : {
  "version" : "1.3.0",
  "uptime" : "0 d, 0 h, 18 m, 13 s",
  "git_hash" : "cb6813f044607bc01895296223a27e4466ab0913",
  "compile_time" : "Fri Sep 2 08:19:12 UTC 2016",
  "compiled_by" : "root",
  "compiled_in" : "ba19f7d3be65"
}
}
[]
```

docker swarm の内部ルーティング・メッシュのおかげで、実際に swarm の任意の
ノードに前のクエリを実行することができます。ポート `1026` のリクエストに
応答できるノード 、つまり、Orion を実行しているノードにリダイレクトされます。

いくつかのデータを挿入しましょう...

```
$ sh ../insert.sh $(docker-machine ip ms-worker1)
```

そして、それがそこにあることを確認してください...

```
$ sh ../query.sh $(docker-machine ip ms-worker0)
...
[
    {
        "id": "Room1",
        "pressure": {
            "metadata": {},
            "type": "Integer",
            "value": 720
        },
        "temperature": {
            "metadata": {},
            "type": "Float",
            "value": 23
        },
        "type": "Room"
    }
]
```

はい、3つのノードのいずれかをクエリすることができます。

Swarm の内部ロード・バランサは、ラウンド・ロビン方式で負荷分散され、swarm 内で
実行されている Orion タスク間で Orion サービスに対するすべてのリクエストが
行われます。

## Orion のリスケール

Orion をスケール・アップやスケール・ダウンすることは、簡単で、次のようなコマンドを実行します...

```
$ docker service scale orion_orion=2
```

(これは docker-compose の `replicas` 引数にマップされます)

その結果、ノードの1つ (この場合は ms-worker1) は Orion を実行しなくなりました...

```
$ docker service ps orion_orion
ID            NAME                    IMAGE               NODE         DESIRED STATE  CURRENT STATE           ERROR  PORTS
2tibpye24o5q  orion_orion.2  fiware/orion:1.3.0  ms-manager0  Running        Running 11 minutes ago
w9zmn8pp61ql  orion_orion.3  fiware/orion:1.3.0  ms-worker0   Running        Running 11 minutes ago
```

しかし、上記のように依然としてクエリに応答します...

```
$ sh ../query.sh $(docker-machine ip ms-worker1)
{
  "orion" : {
  "version" : "1.3.0",
  "uptime" : "0 d, 0 h, 14 m, 30 s",
  "git_hash" : "cb6813f044607bc01895296223a27e4466ab0913",
  "compile_time" : "Fri Sep 2 08:19:12 UTC 2016",
  "compiled_by" : "root",
  "compiled_in" : "ba19f7d3be65"
}
}
[]
```

[mongob レプリカのレシピ](../../../utils/mongo-replicaset/readme.md)を見れば、
mongodb バックエンドをどのようにスケーリングするかを知ることができます。
しかし、基本的には、それが "グローバル" サービスであるという事実のために、
前に示したようにそれを縮小することができます。しかし、それを拡大するには、
ノードごとにインスタンスが1つしかないため、新しいノードを追加する必要が
あります。


## 障害に対応

Docker は、コンテナがダウンした場合のサービスの調整を担当しています。マネージャ
・ノード上で、次のコマンドを実行してみましょう :

```
$ docker ps
CONTAINER ID        IMAGE                                                                                                COMMAND                  CREATED             STATUS              PORTS               NAMES
abc5e37037f0        fiware/orion@sha256:734c034d078d22f4479e8d08f75b0486ad5a05bfb36b2a1f1ba90ecdba2040a9                 "/usr/bin/contextB..."   2 minutes ago       Up 2 minutes        1026/tcp            orion_orion.1.o9ebbardwvzn1gr11pmf61er8
1d79dca4ff28        martel/mongo-replica-ctrl@sha256:f53d1ebe53624dcf7220fe02b3d764f1b0a34f75cb9fff309574a8be0625553a   "python /src/repli..."   About an hour ago   Up About an hour                        mongo-rs_mongo-controller.1.xomw6zf1o0wq0wbut9t5jx99j
8ea3b24bee1c        mongo@sha256:0d4453308cc7f0fff863df2ecb7aae226ee7fe0c5257f857fd892edf6d2d9057                        "/usr/bin/mongod -..."   About an hour ago   Up About an hour    27017/tcp           mongo-rs_mongo.ta8olaeg1u1wobs3a2fprwhm6.3akgzz28zp81beovcqx182nkz
```

orion コンテナがダウンしたとします...

```
$ docker rm -f abc5e37037f0
```

それが消えたことが確認できますが、しばらくすると自動的に戻ってきます。

```
$ docker ps
CONTAINER ID        IMAGE                                                                                                COMMAND                  CREATED             STATUS              PORTS               NAMES
1d79dca4ff28        martel/mongo-replica-ctrl@sha256:f53d1ebe53624dcf7220fe02b3d764f1b0a34f75cb9fff309574a8be0625553a   "python /src/repli..."   About an hour ago   Up About an hour                        mongo-rs_mongo-controller.1.xomw6zf1o0wq0wbut9t5jx99j
8ea3b24bee1c        mongo@sha256:0d4453308cc7f0fff863df2ecb7aae226ee7fe0c5257f857fd892edf6d2d9057                        "/usr/bin/mongod -..."   About an hour ago   Up About an hour    27017/tcp           mongo-rs_mongo.ta8olaeg1u1wobs3a2fprwhm6.3akgzz28zp81beovcqx182nkz

$ docker ps
CONTAINER ID        IMAGE                                                                                                COMMAND                  CREATED             STATUS                  PORTS               NAMES
60ba3f431d9d        fiware/orion@sha256:734c034d078d22f4479e8d08f75b0486ad5a05bfb36b2a1f1ba90ecdba2040a9                 "/usr/bin/contextB..."   6 seconds ago       Up Less than a second   1026/tcp            orion_orion.1.uj1gghehb2s1gnoestup2ugs5
1d79dca4ff28        martel/mongo-replica-ctrl@sha256:f53d1ebe53624dcf7220fe02b3d764f1b0a34f75cb9fff309574a8be0625553a   "python /src/repli..."   About an hour ago   Up About an hour                            mongo-rs_mongo-controller.1.xomw6zf1o0wq0wbut9t5jx99j
8ea3b24bee1c        mongo@sha256:0d4453308cc7f0fff863df2ecb7aae226ee7fe0c5257f857fd892edf6d2d9057                        "/usr/bin/mongod -..."   About an hour ago   Up About an hour        27017/tcp           mongo-rs_mongo.ta8olaeg1u1wobs3a2fprwhm6.3akgzz28zp81beovcqx182nkz
```

ノード全体がダウンしても、冗長化された orion インスタンスと、冗長された DB レプリカの両方があるため、サービスは引き続き機能します。

```
$ docker-machine rm ms-worker0
```

まだリプライを受け取ります...

```
$ sh ../query.sh $(docker-machine ip ms-manager0)
$ sh ../query.sh $(docker-machine ip ms-worker1)
```

## ネットワークの考慮事項

この場合、すべてのコンテナは、互いに通信する同じオーバーレイ・ネットワーク
 (バックエンド) に接続されます。ただし、構成が異なり、ファイアウォールの背後に
あるコンテナを実行している場合は、ポート1026 (Orion のデフォルト) と27017
 (Mongo のデフォルト) で TCP のトラフィックを開けたままにしてください。

サービスのコンテナ (タスク) が起動されると、このオーバーレイ・ネットワーク内の
 IP アドレスが割り当てられます。たとえば、動的な再スケジューリングのために、
アプリケーションのアーキテクチャの他のサービスは、変更される可能性があるため、
これらの IP に依存するべきではありません。良い点は、Docker がサービス全体の
仮想 IP を作成するため、このアドレスへのすべてのトラフィックがタスクのアドレスに
負荷分散されることです。

swarms docker の内部 DNS のおかげで、サービスの名前を使って接続することも
できます。このレシピの `docker-compose.yml` ファイルを見ると、Orion は、mongo
 サービスの名前を `dbhost` param として起動します。これは、レプリカ・セット全体
の単一の mongo インスタンスであるかどうかにかかわらずです。

ただし、オーバーレイ・ネットワークの外部から (たとえばホストから) コンテナに
アクセスするには、`docker_gwbridge` へのコンテナのインターフェイスの ip に
アクセスする必要があります。その情報を外部から入手するのは簡単な方法はないよう
です。[この open issue](https://github.com/docker/libnetwork/issues/1082)
 を見てください。ウォークスルーでは、docker ingress ネットワーク がコンテナ化
された orion サービスのいずれかにトラフィックをルーティングしているため、
swarm ノードの1つを介して orion にクエリしました。

## オープンな興味深い問題

- [https://github.com/docker/swarm/issues/1106](https://github.com/docker/swarm/issues/1106)

- [https://github.com/docker/docker/issues/27082](https://github.com/docker/docker/issues/27082)

- [https://github.com/docker/docker/issues/29816](https://github.com/docker/docker/issues/29816)

- [https://github.com/docker/docker/issues/26696](https://github.com/docker/docker/issues/26696)

- [https://github.com/docker/docker/issues/23813](https://github.com/docker/docker/issues/23813)

Docker network の内部情報の詳細については、以下を参照してください :

- [Docker Reference Architecture](https://success.docker.com/KBase/Docker_Reference_Architecture%3A_Designing_Scalable%2C_Portable_Docker_Container_Networks)
