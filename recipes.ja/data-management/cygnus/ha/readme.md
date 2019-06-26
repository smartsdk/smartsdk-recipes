# Cygnus

## 要件

[ウェルカム・ページ](../../../index.md)を読み、[インストール・ガイド](../../../installation.md)
で説明されている手順に従ってください。

## 入門

このレシピでは、MySQL バックエンドでデフォルトの cygnus-ngsi 設定をデプロイする
方法を説明します。この Generic Enabler は実際には[他の多くのバックエンド](http://fiware-cygnus.readthedocs.io/en/latest/cygnus-common/backends_catalogue/introduction/index.html)
とともにデプロイできることに注意してください。

このレシピは特に [docker "configs"](https://docs.docker.com/compose/compose-file/#configs)
 の使用を必要 とするため、docker versions 17.06.0 以降でサポートされている
 docker-compose file version "3.3" に依存します。

これらのレシピをテストするための環境の準備方法については、ドキュメントの
[インストール](../../../installation.md)・セクションに記載されています。
3ノードの Swarm セットアップを作成したと仮定すると、このデプロイは次のように
なります...

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
            subgraph clustern3 {
          		label="Node 3";
                "Cygnus Agent 3" [fillcolor="aliceblue"];
            }
            subgraph clustern2 {
          		label="Node 2";
                "Cygnus Agent 2" [fillcolor="aliceblue"];
            }
            subgraph clustern1 {
          		label="Node 1";
                "Cygnus Agent" [fillcolor="aliceblue"];
            }
  			MySQL [fillcolor="aliceblue"];
      	}
      	Client -> "Load Balancer" [label="5050",lhead=cluster_0];
      	"Load Balancer" -> {"Cygnus Agent","Cygnus Agent 2","Cygnus Agent 3"};
      	"Cygnus Agent" -> MySQL [lhead=cluster_1];
      	"Cygnus Agent 2" -> MySQL [lhead=cluster_1];
      	"Cygnus Agent 3" -> MySQL [lhead=cluster_1];
  }
'>

[ドキュメント](http://fiware-cygnus.readthedocs.io/en/latest/cygnus-ngsi/installation_and_administration_guide/configuration_examples/index.html)
 からすでに分かっ ているように、cygnus を設定するには、特定のエージェント設定
ファイルを提供する必要があります。この場合、`conf` フォルダ内の
 `cygnus_agent.conf` および `cartodb_keys.conf` ファイルをカスタマイズできます。
これらのファイルの内容は、Docker によって対応する設定にロードされ、cygnus
 サービスのすべてのレプリカで使用可能になります。

`docker-compose.yml` を見ると、環境変数 `CYGNUS_MYSQL_USER` と
 `CYGNUS_MYSQL_PASS` を設定することによって、MySQL ユーザとパスワードの値を
カスタマイズできることに気づくでしょう。

サンプルをそのまま起動するには、次のコマンドを実行します :

```
    docker stack deploy -c docker-compose.yml cygnus
```

数分後に2つのサービスが起動して実行されていることを確認できます。

```
    $ docker service ls
    ID                  NAME                   MODE                REPLICAS            IMAGE                       PORTS
    l3h1fsk36v35        cygnus_mysql           replicated          1/1                 mysql:latest                *:3306->3306/tcp
    vmju1turlizr        cygnus_cygnus-common   replicated          3/3                 fiware/cygnus-ngsi:latest   *:5050->5050/tcp
```

説明のために、単純な `notification.sh` スクリプトを使用して、cygnus の
エントリポイントに NGSI 通知を送信してみましょう。

```
    $ sh notification.sh http://0.0.0.0:5050/notify
    *   Trying 0.0.0.0...
    * TCP_NODELAY set
    * Connected to 0.0.0.0 (127.0.0.1) port 5050 (#0)
    > POST /notify HTTP/1.1
    > Host: 0.0.0.0:5050
    > User-Agent: curl/7.54.0
    > Content-Type: application/json; charset=utf-8
    > Accept: application/json
    > Fiware-Service: default
    > Fiware-ServicePath: /
    > Content-Length: 607
    >
    * upload completely sent off: 607 out of 607 bytes
    < HTTP/1.1 200 OK
    < Transfer-Encoding: chunked
    < Server: Jetty(6.1.26)
    <
    * Connection #0 to host 0.0.0.0 left intact
```

Docker Swarm クラスタ上でサービスとして稼働している cygnus を持つことで、他の
 docker サービスと同様にスケーラビリティを達成できます。詳細については、 
[Orionのレシピ](../../context-broker/ha/readme.md)を参照して Docker でこれを
行う方法を参照してください。それ以外の場合は、[Docker サービスのドキュメント](https://docs.docker.com/engine/swarm/swarm-tutorial/scale-service/)
を参照してください。

## カスタマイズ

### 別のバックエンドが必要な場合はどうすればよいですか？

cygnus デプロイメントのために別のバックエンドを試したい場合は、3つの手順を実行する必要があります。

1. ニーズに合わせて、`cygnus_agent.conf` を設定してください。詳細は
   [ドキュメント](http://fiware-cygnus.readthedocs.io/en/latest/cygnus-ngsi/installation_and_administration_guide/configuration_examples/index.html)
   を参照してください。

1. `docker-compose.yml` を更新してください。特に cygnus サービス用に構成された
   環境変数です。たとえば、MySQL ではなく MongoDB を使用する場合は、変数
   `CYGNUS_MONGO_USER` と `CYGNUS_MONGO_PASS` を使用する必要があります。
   必要な変数の完全なリストについては、[cygnus のドキュメント](http://fiware-cygnus.readthedocs.io/en/latest/cygnus-ngsi/installation_and_administration_guide/install_with_docker/index.html#section3.2)
   を参照してください。

1. mysql サービスの定義を削除し、あなたの好みのものを導入するよう、
   `docker-compose.yml`を更新してください。また、cygnus の `depends_on:` の
   セクションを新しいサービスの名前で更新することを忘れないでください。

### 別のチャンネルを使用

`conf/cygnus_agent.conf` の設定ファイルを見てみると、メモリベースのチャネルと
ファイルベースのチャネルのどちらからでも選択できます。チャンネルタイプの設定から
コメントにする/コメントを外す (つまり、`#` キャラクターを残す/削除する) ように
してください。

```
    cygnus-ngsi.channels.main-channel.type = memory
    #cygnus-ngsi.channels.main-channel.type = file
```

チャネルの詳細については、公式ドキュメントの [channels considerations](https://github.com/telefonicaid/fiware-cygnus/blob/master/doc/cygnus-ngsi/installation_and_administration_guide/performance_tips.md#channel-considerations)
 をチェックしてください。
