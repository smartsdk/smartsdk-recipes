# HA

## 要件

[ウェルカム・ページ](../../../index.md)を読み、[インストール・ガイド](../../../installation.md)で説明されている手順に従ってください。

## イントロダクション

フロントエンドとバックエンドの両方で複数のレプリカを持つ Comet のデプロイメントをテストしましょう。ここで考えているのは、以下に示すシナリオを得ることです。

<img src='http://g.gravizo.com/g?
digraph Cluster {
    label="Docker Swarm"
    rankdir=LR;
    compound=true;
    node [shape="record" style="filled" fillcolor=aliceblue];
    splines=line;
    "Client" [shape=oval];
    "NGSI";
    "Comet LB";
    Comet1;
    Comet2;
    Comet3;
    "Comet DB 1" [shape=egg];
    "Comet DB 2" [shape=egg];
    "Comet DB 3" [shape=egg];
    "NGSI" -> "Comet LB" [label="Notifications"];
    "Client" -> "Comet LB" [label=8666];
    "Comet LB" -> {Comet1,Comet2,Comet3};
    "Comet2" -> "Comet DB 1";
    "Comet1" -> "Comet DB 1";
    "Comet3" -> "Comet DB 1";
    "Comet DB 1" -> "Comet DB 2" [dir=both];
    "Comet DB 2" -> "Comet DB 3" [dir=both];
    "Comet DB 1" -> "Comet DB 3" [dir=both];
    {rank=same; "Comet DB 2"; "Comet DB 3"}
}
'>

後で、これは、たとえば [Orion Context Broker の HA デプロイメント](../../context-broker/ha/readme.md)
と組み合わせることができます。

## ウォークスルー

まず、Docker Swarm (docker >= 1.13) を既にセットアップしておく必要があります。
セットアップしていない場合は、local swarm をセットアップするための簡単な方法に
ついては[ツール](../../../tools/readme.md)・セクションをチェックしてください。

```
    miniswarm start 3
    eval $(docker-machine env ms-manager0)
```

Comet はバックエンド用の mongo データベースが必要です。すでにクラスタ内に Mongo
 をデプロイしていて、そのデータベースを再利用したい場合は、次のステップ (バック
エンドのデプロイ) をスキップできます。Comet が Mongo にリンクするために定義する
変数、つまり、`MONGO_SERVICE_URI` と `REPLICASET_NAME` に注意するだけで十分
です。`frontend.env` の値が正しいことを確認してください。`MONGO_SERVICE_URI`
 の値は、mongo のルーティング可能なアドレスでなければなりません。swarm 内に
デプロイされた場合は、プレフィックス付きのサービス名で十分です。
[公式 Docker ドキュメント](https://docs.docker.com/docker-cloud/apps/service-links/)
でもっと読むことができます。[Mongo Replicaset Recipe](../../../utils/mongo-replicaset/readme.md)
 を使用していれば、デフォルト値は正常です。

それ以外の場合、Comet のためだけに Mongo の新しい展開をしたい場合は、次のコマンドを実行することができます...

```
    sh deploy_back.sh
```

しばらくて、レプリカ・セットが準備できたら、次のコマンドを実行して comet をデプロイすることができます...

```
    sh deploy_front.sh
```

さて、いつものように、すべてが適切に接続されていることを確認する簡単なテストを
行います。通知のソースとして、swarm に Orion をデプロイしました。たとえば、
[Orion in HA](../../context-broker/ha/readme.md) を参照してください。

便宜上、Orion と Comet のサービスの IP アドレスを保存しましょう。このシナリオ
では、両方ともサービス・ポートを公開している Swarm に配備されているため、Swarm
 の ingress ネットワークには1つのエントリ・ポイントで十分です。

```
    ORION=http://$(docker-machine ip ms-manager0)
    COMET=http://$(docker-machine ip ms-manager0)
```

インサート :

```
    sh ../../context-broker/insert.sh $ORION
    sh ../../context-broker/query.sh $ORION
    ...
```

サブスクライブ :

```
    sh ../subscribe.sh $ORION
    {
      "subscribeResponse" : {
        "subscriptionId" : "58bd1940b97cc713f5eacdb7",
        "duration" : "PT24H"
      }
    }
```

更新 :

```
    sh ../../context-broker/update.sh $ORION
```

そして、

```
    sh ../query_sth.sh $COMET
    {
    "contextResponses": [
        {
            "contextElement": {
                "attributes": [
                    {
                        "name": "temperature",
                        "values": [
                            {
                                "attrType": "Float",
                                "attrValue": 23,
                                "recvTime": "2017-03-06T08:09:36.493Z"
                            },
                            {
                                "attrType": "Float",
                                "attrValue": 29.3,
                                "recvTime": "2017-03-06T08:11:14.044Z"
                            }
                        ]
                    }
                ],
                "id": "Room1",
                "isPattern": false,
                "type": "Room"
            },
            "statusCode": {
                "code": "200",
                "reasonPhrase": "OK"
            }
        }
    ]
    }
```
