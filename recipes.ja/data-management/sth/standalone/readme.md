# スタンドアロン

## イントロダクション

このスタンドアロン・ウォークスルーのアイデアは、以下に示すような簡単な通知ベース
のシナリオ内で Comet Generic Enabler をテストして紹介することです。

<img src='http://g.gravizo.com/g?
digraph Cluster {
    label="Docker Swarm"
    rankdir=LR;
    compound=true;
    node [shape="record" style="filled" fillcolor=aliceblue];
    splines=line;
    "Client" [shape=oval];
    "Orion";
    "Orion DB" [shape=egg];
    "Comet LB";
    Comet1;
    Comet2;
    Comet3;
    "Comet DB" [shape=egg];
    "Orion" -> "Comet LB";
    "Orion" -> "Comet LB";
    "Orion" -> "Comet LB" [label="NGSI Notifications"];
    "Orion DB" -> "Orion"[dir=both];
    "Client" -> "Orion" [label=1026];
    "Client" -> "Comet LB" [label=8666];
    "Comet LB" -> {Comet1,Comet2,Comet3};
    "Comet2" -> "Comet DB";
    "Comet1" -> "Comet DB";
    "Comet3" -> "Comet DB";
    {rank=same; "Orion"; "Orion DB";}
}
'>

## ウォークスルー

まず、Docker Swarm (docker >= 1.13) をセットアップしておく必要があります。セット
アップしていない場合は、local swarm をセットアップするための簡単な方法については
[ツール](../../../tools/readme.md)・セクションをチェックしてください。

```
    $ miniswarm start 3
    $ eval $(docker-machine env ms-manager0)
```

スタック全体を開始するには、通常通り実行します：

```
    $ docker stack deploy -c docker-compose.yml comet
```

次に、すべてのレプリカが起動して実行されるまで待ちます :

```
    $ docker service ls
    ID            NAME               MODE        REPLICAS  IMAGE
    1ysxmrxrqvp4  comet_comet-mongo  replicated  1/1       mongo:3.2
    8s9acybjxo0m  comet_orion        replicated  1/1       fiware/orion:latest
    ra84eex0zsd0  comet_comet        replicated  3/3       telefonicaiot/fiware-sth-comet:latest
    xg8ds3szkoi7  comet_orion-mongo  replicated  1/1       mongo:3.2
```

さて、いくつかの検査を開始しましょう。便宜上、Orion と Comet のサービスの IP
 アドレスを保存しましょう。このシナリオでは、両方ともサービス・ポートを公開して
いる Swarm に配備されているため、Swarm の ingress ネットワーク には1つのエントリ
ポイントで十分です。

```
    ORION=http://$(docker-machine ip ms-manager0)
    COMET=http://$(docker-machine ip ms-manager0)
```

Orion が稼動していることを確認してから、いくつかの点検を始めましょう。

```
    $ sh ../../context-broker/query.sh $ORION
    {
    "orion" : {
      "version" : "1.7.0-next",
      "uptime" : "0 d, 0 h, 1 m, 39 s",
      "git_hash" : "f710ee525f0fa55f665e578e309fc716c12cfd99",
      "compile_time" : "Wed Feb 22 10:14:18 UTC 2017",
      "compiled_by" : "root",
      "compiled_in" : "b99744612d0b"
    }
    }
    []
```

簡単なデータ (Room1 測定値) を挿入しましょう :

```
    $ sh ../../context-broker/insert.sh $ORION
```

次に、Room1 の温度変化の通知に Comet をサブスクライブしましょう。

```
    $ sh ../subscribe.sh $COMET
    {
      "subscribeResponse" : {
        "subscriptionId" : "58b98c0cdb69948641065907",
        "duration" : "PT24H"
      }
    }
```

Orion の温度値を更新しましょう...

```
    $ sh ../../context-broker/update.sh $ORION
```

そして両方の測定の短期履歴ビューを見ることができます。

```
    $ sh ../query_sth.sh $COMET
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
                                    "recvTime": "2017-03-03T15:30:20.650Z"
                                },
                                {
                                    "attrType": "Float",
                                    "attrValue": 29.3,
                                    "recvTime": "2017-03-03T15:32:48.741Z"
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
