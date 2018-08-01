# QuantumLeap

## イントロダクション

ここでは、QuantumLeap のさまざまな用途を目的としたレシピを見つけることができます。すでにあなたが QuantumLeapに精通していることを前提としてい ます。そでなければ、[公式ドキュメント](https://smartsdk.github.io/ngsi-timeseries-api/)を参照してください。

これらのレシピをテストするための環境の準備方法については、[インストールのセクション](../../installation.md)を参照してください。

## 要件

[ウェルカム・ページ](../../index.md)を読み、[インストール・ガイド](../../installation.md)で説明されている手順に従ってください。

## HA デプロイの概要

<img src='http://g.gravizo.com/g?
  digraph G {
      rankdir=LR;
      	compound=true;
      	node [shape="record" style="filled"];
      	splines=line;
      	Client [fillcolor="aliceblue"];
      	subgraph cluster {
      		label="3-Nodes Docker Swarm Cluster";
      		"Traefik" [fillcolor="aliceblue"];
      		"Swarm LB" [fillcolor="aliceblue"];
      		subgraph cluster_0 {
      			label="QuantumLeap";
                QL2 [fillcolor="aliceblue"];
                QL1 [fillcolor="aliceblue"];
                QL3 [fillcolor="aliceblue"];
      		}
      		subgraph cluster_1 {
      			label="CrateDB stack";
      			Crate1 [fillcolor="aliceblue"];
      			Crate2 [fillcolor="aliceblue"];
      			Crate3 [fillcolor="aliceblue"];
      		}
      		subgraph cluster_2 {
      			label="Grafana";
      			Grafana1 [fillcolor="aliceblue"];
      		}
      	}
      	Client -> "Swarm LB" [label="8668",lhead=cluster_0];
      	Client -> "Traefik" [label="4200",lhead=cluster_0];
      	Client -> "Grafana1" [label="3000",lhead=cluster_0];
      	"Swarm LB" -> {QL1,QL2,QL3};
      	Traefik -> Crate1 [lhead=cluster_1];
        Grafana1 -> Crate1 [lhead=cluster_1];
      	QL1 -> Crate1 [lhead=cluster_1];
      	QL2 -> Crate1 [lhead=cluster_1];
      	QL3 -> Crate1 [lhead=cluster_1];
      	Crate1 -> {Crate2, Crate3} [dir="both"];
        Crate2 -> {Crate3} [dir="both"];
  }
'>


## 簡単なウォークスルー

### 始める前に

スタックを起動する前に、docker クラスタのエントリ・ポイントのドメインを定義する必要があります。そのドメインを次のような環境変数に保存します :

```
$ export CLUSTER_DOMAIN=mydomain.com
```

ローカルでテストしていて、ドメインを所有していない場合、`/etc/hosts` ファイルを編集して Swarm Cluster のノードの IP を指し示すエントリを追加することができます。クラスタ・エントリ・ポイントの場合は、192.168.99.100 を IP で置き換えてください。以下の例を参照してください。

```
# End of /etc/hosts file
192.168.99.100  mydomain.com
192.168.99.100  crate.mydomain.com
```

[Traefik](https://traefik.io) プロキシ経由で CrateDB クラスタ UI にアクセスするため、`crate.mydomain.com` のための1つのエントリが含まれています。

また、クラスタの構造に応じて、以下の3つの特別な環境変数の値を設定する必要があります。デフォルト値では、クラスタにノードが1つしかないと想定されます。クラスタに複数のノードがある場合は理想的ではありません。`settings.env` (Windowsでは `settings.bat`) に正しい値を持っていることを確認してください。

- `EXPECTED_NODES`: クラスタ状態が回復するまで待機するノード数。値は、クラスタ内のノードの数と等しくなければなりません

- `RECOVER_AFTER_NODES`: クラスタ状態の回復が始まる前に開始する必要があるノードの数

- `MINIMUM_MASTER_NODES`: quorum をクラスタの最大ノード数の半分より大きく設定することを強くお勧めします。すなわち、(N / 2) + 1 です。ここで、N はクラスタ内のノードの最大数です

詳細は、[これらのドキュメント](https://crate.io/docs/crate/guide/en/latest/scale/multi_node_setup.html#id10) または、[elasticsearch のドキュメント](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-gateway.html)の対応するセクションを参照してください。

これらに加えて、次の環境変数を使用してデプロイメントをカスタマイズすることもできます。

- `QL_VERSION`: 展開したい [Quantumleap image](https://hub.docker.com/r/smartsdk/quantumleap/) イメージの Docker タグ

### デプロイ

これで名前 `ql` をスタックに入れる準備が整いました。

QuantumLeap の基本スタックを展開したい場合は、単に実行することができます...

```
$ source settings.env  # In Windows, execute settings.bat instead.
$ docker stack deploy -c docker-compose ql
```

それ以外の場合は、データ視覚化のために Grafana などの追加サービスを追加したい場合は、`docker-compose-addons.yml` に現在表示されているアドオンを統合することができます。残念ながら、docker は現在、[単一の展開を行うために複数の compose ファイル](https://github.com/moby/moby/issues/30127)を直接サポートしていません。それゆえ、提案する方法は次のとおりです...

```
# First we merge the two compose files using docker-compose
$ docker-compose -f docker-compose.yml -f docker-compose-addons.yml config > ql.yml
# Now we deploy the "ql" stack from the generated ql.yml file.
$ docker stack deploy -c ql.yml ql
```

すべてのインスタンスが起動していることを確認するまで待ってください。これには数分かかる場合があります。

```
$ docker service ls
ID                  NAME                MODE                REPLICAS            IMAGE                             PORTS
2vbj18blsqje        ql_traefik          global              1/1                 traefik:1.3.5-alpine              *:80->80/tcp,*:443->443/tcp,*:4200->4200/tcp,*:4300->4300/tcp,*:8080->8080/tcp
bvs32e81jcns        ql_viz              replicated          1/1                 dockersamples/visualizer:latest   *:8282->8080/tcp
e8kyp4vylvev        ql_quantumleap      replicated          1/1                 smartsdk/quantumleap:latest       *:8668->8668/tcp
ignls7l57hzn        ql_crate            global              3/3                 crate:1.0.5
tfszxc2fcmxx        ql_grafana          replicated          1/1                 grafana/grafana:latest            *:3000->3000/tcp
```

これで、[公式ドキュメント](https://docs.docker.com/engine/swarm/swarm-tutorial/scale-service/)で説明されているシンプルな docker service scale command を使用して、必要に応じてサービスを拡張できます。

### 探査

今、エクスプローラで [http://crate.mydomain.com](http://crate.mydomain.com) を開くと 、CRATE.IO ダッシュボードが表示されます。"cluster" タブには、swarm クラスタ内にある同じ数のノードが表示されます。

クイックテストの場合は、このフォルダ内の `insert.sh` スクリプトを使用できます。

```
$ sh insert.sh IP_OF_ANY_SWARM_NODE 8668
```

それ以外の場合は、お気に入りの API テスターを開き、QuantumLeap に下に示す通知を送信して、後で Crate Dashboard を介してデータベースに保持されていることを確認してください。

```
# Simple examples payload to send to IP_OF_ANY_SWARM_NODE:8668/notify
{
    "subscriptionId": "5947d174793fe6f7eb5e3961",
    "data": [
        {
            "id": "Room1",
            "type": "Room",
            "temperature": {
                "type": "Number",
                "value": 27.6,
                "metadata": {
                    "dateModified": {
                        "type": "DateTime",
                        "value": "2017-06-19T11:46:45.00Z"
                    }
                }
            }
        }
    ]
}
```

典型的なシナリオでは、ペイロードを `/notify` エンドポイントに直接送信するのではなく、通知 (notifications) の形式で、*Orion Context Broker* に送信することになります。詳細は[公式ドキュメント](https://smartsdk.github.io/ngsi-timeseries-api/)を参照してください。

これらのすべてのクエリについては、[ツール・セクション](../../tools/readme.md)で利用可能な、postman コレクションを使用できます。

詳細については、[QuantumLeap のユーザ・マニュアル](https://smartsdk.github.io/ngsi-timeseries-api/)を参照してください。
