# API Umbrella の HA 構成

このレシピでは、MongoDB インスタンスのスケーラブルな[レプリカ・セット](https://github.com/telefonicaid/fiware-orion/blob/master/README.md)を使用してスケーラブルな API Umbrella インスタンス・サービス をデプロイする方法を示します。

すべての要素は docker-compose ファイルで定義された docker コンテナで実行されます。実際、このレシピは、[mongodb のレプリカ・レシピ](../../utils/mongo-replicaset/readme.md)をバックエンドとして再利用する API Umbrella フロントエンドのデプロイメントに重点を置いています。

当面は、 API のインタラクション をログするための Elastic Search や QoS などの他のサービスは展開されていません。これは主に、API Umbrella が古いバージョンの Elastic Search (すなわち、バージョン2、現在のバージョンは 6 です) のみをサポートしているためです。

最終的なデプロイメントは、次の図で表されます :

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
      			label="API Umbrella stack";
      			APIUmbrella1 [fillcolor="aliceblue"];
      			APIUmbrella2 [fillcolor="aliceblue"];
      			APIUmbrella3 [fillcolor="aliceblue"];
      		}
      		subgraph cluster_1 {
      			label="MongoDB Replica Set stack";
      			Mongo1 [fillcolor="aliceblue"];
      			Mongo2 [fillcolor="aliceblue"];
      			Mongo3 [fillcolor="aliceblue"];
      		}
      	}
      	Client -> "Load Balancer" [label="80",lhead=cluster_0];
      	"Load Balancer" -> {APIUmbrella1,APIUmbrella2,APIUmbrella3};
      	APIUmbrella1 -> Mongo1 [lhead=cluster_1];
      	APIUmbrella2 -> Mongo1 [lhead=cluster_1];
      	APIUmbrella3 -> Mongo1 [lhead=cluster_1];
      	Mongo1 -> {Mongo2, Mongo3} [dir="both"];
  }
'>

## 前提条件

[ウェルカム・ページ](../../index.md)を読み、[インストール・ガイド](../../installation.md)で説明されている手順に従ってください。

## 使い方

まず、Docker Swarm (docker >= 17.06-ce) をセットアップする必要があります。セットアップが必要な場合は、ローカルの swarm をセットアップするための簡単な方法については[ツール](../../tools/readme.md)・セクションをチェックしてください。

```
$ miniswarm start 3
$ eval $(docker-machine env ms-manager0)
```

他のレシピのためにそれをまだ行っていない場合は、[インストール・ガイド](../../installation.md#creating-the-networks)で説明しているように、`backend` と `frontend` をデプロイしてください。

API Umbrella にはバックエンド用の mongo データベースが必要です。すでにクラスタ内に Mongo をデプロイしていて、そのデータベースを再利用したい場合は、次のステップ (バックエンドのデプロイ) をスキップできます。API Umbrella が Mongo にリンクするために定義する変数、つまり、`MONGO_SERVICE_URI` および `REPLICASET_NAME` に注意する必要があります。

そうでなければ、API Umbrella のためだけに MongoDB の新しい展開をしたい場合は、ショートカットして、次のコマンドを実行することができます...

```bash
$ sh deploy_back.sh

Creating config mongo-rs_mongo-healthcheck
Creating service mongo-rs_mongo
Creating service mongo-rs_controller
```

それに加えて、MongoDB の Ruby ドライバがサービス・ディスカバリーをサポートしていない場合、MongoDB サーバのポートをクラスタに公開して、API Umbrella のレプリカ・セットへの接続を許可する必要があります。

これは、スクリプトのように、MongoDB をグローバル・モードでデプロイする場合にのみ機能することに注意してください。

```bash
$ docker service update --publish-add published=27017,target=27017,protocol=tcp,mode=host mongo-rs_mongo

mongo-rs_mongo
overall progress: 1 out of 1 tasks
w697ke0djs3c: running   [==================================================>]
verify: Service converged
```

バックエンドが準備完了するまでしばらくお待ちください。実行されているバックアップされたデプロイメントを確認できます :

```bash
$ docker stack ps mongo-rs
ID                  NAME                                       IMAGE                              NODE                DESIRED STATE       CURRENT STATE             ERROR               PORTS
mxxrlexvj0r9        mongo-rs_mongo.z69rvapjce827l69b6zehceal   mongo:3.2                          ms-worker1          Running             Starting 9 seconds ago
d74orl0f0q7a        mongo-rs_mongo.fw2ajm8zw4f12ut3sgffgdwsl   mongo:3.2                          ms-worker0          Running             Starting 15 seconds ago
a2wddzw2g2fg        mongo-rs_mongo.w697ke0djs3cfdf3bgbrcblam   mongo:3.2                          ms-manager0         Running             Starting 6 seconds ago
nero0vahaa8h        mongo-rs_controller.1                      martel/mongo-replica-ctrl:latest   ms-manager0         Running             Running 5 seconds ago
```

Swarm Cluster の IPs に基づいて mongo の接続 URL を設定するか、`frontend.env` ファイルを編集します :

```bash
$ MONGO_REPLICATE_SET_IPS=192.168.99.100:27017,192.168.99.101:27017,192.168.99.102:27017
$ export MONGO_REPLICATE_SET_IPS
```

`miniswarm` クラスタの作成に使用した場合は、次のように `docker-machine ip` コマンドを使用して異なる IPs を取得できます。たとえば、 :

```bash
$ docker-machine ip ms-manager0

$ docker-machine ip ms-worker0

$ docker-machine ip ms-worker1
```

すべてのサービスがステータス・レディになると、バックエンドを使用できる状態になります :

```bash
$ sh deploy_front.sh

generating config file
replacing target file  api-umbrella.yml
replace mongodb with mongo-rs_mongo
replacing target file  api-umbrella.yml
replace rs_name with rs
Creating config api_api-umbrella
Creating service api_api-umbrella
```

フロントエンド・サービスも実行されると、デプロイメントは次のようになります :

```bash
$ docker service ls

ID                  NAME                  MODE                REPLICAS            IMAGE                                 PORTS
ca11lmx40tu5        api_api-umbrella      replicated          2/2                 martel/api-umbrella:0.14.4-1-fiware   *:80->80/tcp,*:443->443/tcp
te1i0vhwtmnw        mongo-rs_controller   replicated          1/1                 martel/mongo-replica-ctrl:latest
rbo2oe2y0d72        mongo-rs_mongo        global              3/3                 mongo:3.2
```

レプリカ列に `3/3` が表示されている場合は、計画した 3つのレプリカのうち 3つが稼働中であることを意味します。

## ウォークスルー

次のウォークスルーでは、API Umbrella の初期設定を行い、最初の API を登録する方法について説明します。詳細については、[API Umbrella のドキュメント](https://api-umbrella.readthedocs.io/en/latest/)を参照してください。

1. API Umbrella で管理ユーザを作成しましょう。まず、マスターノードの IP を取得します :

```bash
$ docker-machine ip ms-manager0
```

次のエンドポイントをブラウザで開きます:
`http://<your-cluster-manager-ip>/admin`.

サーバー用の証明書を作成していない限り、API Umbrella は安全でないインスタンスへの接続を受け入れるよう求めます。

表示されるページでは、管理者のユーザ名とパスワードを入力できます。

これでログインし、バックエンド APIs を設定できます。

**注意:** クラスタ・マスター IP の使用法は単なる慣習であり、ワーカー・ノードの IPs でもサービスにアクセスできます。

1. `X-Admin-Auth-Token` アクセス と `X-Api-Key` を取得します。メニューで、`Users->Admin Accounts` を選択し、作成したユーザ名をクリックします。あなたのアカウントの `Admin API Access` をコピーします。

メニューで、`Users->Api Users` を選択し、ユーザ名 `web.admin.ajax@internal.apiumbrella` をクリックして API キーをコピーします。もちろん、API Umbrella のデフォルトを再利用するのではなく、新しいものを作成できます。

1. 新しい API を登録してください。すべてが動作することをテストするためのシンプルな API を作成します :

```bash
$ curl -k -X POST "https://<your-cluster-manager-ip>/api-umbrella/v1/apis" \
  -H "X-Api-Key: <your-API-KEY>" \
  -H "X-Admin-Auth-Token: <your-admin-auth-token>" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" -d @- <<EOF
{
  "api": {
    "name": "distance FIWARE REST",
    "sort_order": 100000,
    "backend_protocol": "http",
    "frontend_host": "<your-cluster-manager-ip>",
    "backend_host": "maps.googleapis.com",
    "servers": [
      {
        "host": "maps.googleapis.com",
        "port": 80
      }
    ],
    "url_matches": [
      {
        "frontend_prefix": "/distance2/",
        "backend_prefix": "/"
      }
    ],
    "balance_algorithm": "least_conn",
    "settings": {
      "require_https":"required_return_error",
      "require_idp": "fiware-oauth2",
      "disable_api_key":"false",
      "api_key_verification_level":"none",
      "rate_limit_mode":"unlimited",
      "error_templates": {},
      "error_data": {}
    }
  }
}
EOF

Response:
{
  "api": {
    "backend_host": "maps.googleapis.com",
    "backend_protocol": "http",
    "balance_algorithm": "least_conn",
    "created_at": "2018-02-26T13:47:02Z",
    "created_by": "c9d7c2cf-737c-46ae-974b-22ebc12cce0c",
    "deleted_at": null,
    "frontend_host": "<your-cluster-manager-ip>",
    "name": "distance FIWARE REST",
    "servers": [
      {
        "host": "maps.googleapis.com",
        "port": 80,
        "id": "f0f7a039-d88c-4ef8-8798-a00ad3c8fcdb"
      }
    ],
    "settings": {
      "allowed_ips": null,
      "allowed_referers": null,
      "anonymous_rate_limit_behavior": null,
      "api_key_verification_level": "none",
      "api_key_verification_transition_start_at": null,
      "append_query_string": null,
      "authenticated_rate_limit_behavior": null,
      "disable_api_key": false,
      "error_data": null,
      "error_templates": {},
      "http_basic_auth": null,
      "pass_api_key_header": null,
      "pass_api_key_query_param": null,
      "rate_limit_mode": "unlimited",
      "require_https": "required_return_error",
      "require_https_transition_start_at": null,
      "require_idp": "fiware-oauth2",
      "required_roles": null,
      "required_roles_override": null,
      "error_data_yaml_strings": {},
      "headers_string": "",
      "default_response_headers_string": "",
      "override_response_headers_string": "",
      "id": "4dfe22af-c12a-4733-807d-0a668c413a96",
      "default_response_headers": null,
      "headers": null,
      "override_response_headers": null,
      "rate_limits": null
    },
    "sort_order": 100000,
    "updated_at": "2018-02-26T13:47:02Z",
    "updated_by": "c9d7c2cf-737c-46ae-974b-22ebc12cce0c",
    "url_matches": [
      {
        "backend_prefix": "/",
        "frontend_prefix": "/distance2/",
        "id": "ec719b9f-2020-4eb9-8744-5cb2bae4b625"
      }
    ],
    "version": 1,
    "id": "cbe24047-7f74-4eb5-bd7e-211c3f8ede22",
    "rewrites": null,
    "sub_settings": null,
    "creator": {
      "username": "xxx"
    },
    "updater": {
      "username": "xxx"
    }
  }
}
EOF
```

1. 新しく登録した API を公開します。

```bash
$ curl -k -X POST "https://<your-cluster-manager-ip>/api-umbrella/v1/config/publish" \
  -H "X-Api-Key: <your-API-KEY>" \
  -H "X-Admin-Auth-Token: <your-admin-auth-token>" \
  -H "Accept: application/json" \
  -H "Content-Type: application/json" -d @- <<EOF
{
  "config": {
    "apis": {
      "cbe24047-7f74-4eb5-bd7e-211c3f8ede22": {
        "publish": "1"
      }
    },
    "website_backends": {
    }
  }
}
EOF

Response:

{
  "config_version": {
    "config": {
      "apis": [
        {
          "_id": "cbe24047-7f74-4eb5-bd7e-211c3f8ede22",
          "version": 2,
          "deleted_at": null,
          "name": "distance FIWARE REST",
          "sort_order": 100000,
          "backend_protocol": "http",
          "frontend_host": "192.168.99.100",
          "backend_host": "maps.googleapis.com",
          "balance_algorithm": "least_conn",
          "updated_by": "c9d7c2cf-737c-46ae-974b-22ebc12cce0c",
          "updated_at": "2018-02-26T14:02:08Z",
          "created_at": "2018-02-26T13:47:02Z",
          "created_by": "c9d7c2cf-737c-46ae-974b-22ebc12cce0c",
          "settings": {
            "require_https": "required_return_error",
            "disable_api_key": false,
            "api_key_verification_level": "none",
            "require_idp": "fiware-oauth2",
            "rate_limit_mode": "unlimited",
            "error_templates": {},
            "_id": "4dfe22af-c12a-4733-807d-0a668c413a96",
            "anonymous_rate_limit_behavior": "ip_fallback",
            "authenticated_rate_limit_behavior": "all",
            "error_data": {}
          },
          "servers": [
            {
              "host": "maps.googleapis.com",
              "port": 80,
              "_id": "f0f7a039-d88c-4ef8-8798-a00ad3c8fcdb"
            }
          ],
          "url_matches": [
            {
              "frontend_prefix": "/distance2/",
              "backend_prefix": "/",
              "_id": "ec719b9f-2020-4eb9-8744-5cb2bae4b625"
            }
          ]
        }
      ],
      "website_backends": []
    },
    "created_at": "2018-02-26T14:03:53Z",
    "updated_at": "2018-02-26T14:03:53Z",
    "version": "2018-02-26T14:03:53Z",
    "id": {
      "$oid": "5a9413c99f9d04008c5a0b6c"
    }
  }
}
```

1. クエリを発行して、新しい API をテストします :

* FIWARE からトークンを取得します :

```bash
$ wget --no-check-certificate https://raw.githubusercontent.com/fgalan/oauth2-example-orion-client/master/token_script.sh
$ bash token_script.sh

Username: your_email@example.com
Password:
Token: <this is the token you need>
```

* API を使用してクエリを作成します :

```bash
$ curl -k "https://<your-cluster-manager-ip>/distance2/maps/api/distancematrix/json?units=imperial&origins=Washington,DC&destinations=New+York+City,NY&token=<your-FIWARE-token>"

Response:
{
   "destination_addresses" : [ "New York, NY, USA" ],
   "origin_addresses" : [ "Washington, DC, USA" ],
   "rows" : [
      {
         "elements" : [
            {
               "distance" : {
                  "text" : "225 mi",
                  "value" : 361940
               },
               "duration" : {
                  "text" : "3 hours 50 mins",
                  "value" : 13816
               },
               "status" : "OK"
            }
         ]
      }
   ],
   "status" : "OK"
}
```

## ネットワークの考慮事項

この場合、すべてのコンテナは、互いに通信する同じオーバーレイ・ネットワーク (バックエンド) に接続されます。ただし、設定が異なり、ファイアウォールの背後にあるコンテナを実行している場合は、ポート `80` と `443` (API Umbrellas のデフォルト) と `27017` (Mongo のデフォルト) で TCP のトラフィックを開いたままにしてください。

サービスのコンテナ (タスク) が起動されると、このオーバーレイ・ネットワーク内の IP アドレスが割り当てられます。アプリケーションのアーキテクチャの他のサービスは、例えば、動的な再スケジューリングのために、変更される可能性があるため、これらの IP に依存するべきではありません。良い点は、Docker がサービス全体の仮想 IP を作成するため、このアドレスへのすべてのトラフィックがタスク・アドレスに負荷分散されることです。

Docker Swarm の内部 DNS のおかげで、サービスの名前を使って接続することもできます。このレシピの `docker-compose.yml` ファイルを見ると、orion は mongo サービスの名前を `dbhost` param として開始されます。これは、レプリカ・セット全体の単一のmongoインスタンスであっても関係ありません。

ただし、オーバーレイ・ネットワークの外部から、たとえばホストから)、コンテナにアクセスするには、`docker_gwbridge` へのコンテナのインターフェイスの ip にアクセスする必要があります。この情報を外部から取得するのは簡単な方法ではないようです。この[未解決の問題](https://github.com/docker/libnetwork/issues/1082)を参照してください。ウォークスルーでは、swarm ノードの1つを介して、API Umbrella をクエリしました。これは、docker ingress  ネットワークがコンテナ化された API Umbrella サービスのいずれかにトラフィックをルーティングすることに依存しているためです。

## 未解決の問題

* [https://github.com/docker/swarm/issues/1106](https://github.com/docker/swarm/issues/1106)

* [https://github.com/docker/docker/issues/27082](https://github.com/docker/docker/issues/27082)

* [https://github.com/docker/docker/issues/29816](https://github.com/docker/docker/issues/29816)

* [https://github.com/docker/docker/issues/26696](https://github.com/docker/docker/issues/26696)

* [https://github.com/docker/docker/issues/23813](https://github.com/docker/docker/issues/23813)

Docker ネットワークの内部情報の詳細については、以下を参照してください :

* [Docker Reference Architecture](https://success.docker.com/KBase/Docker_Reference_Architecture%3A_Designing_Scalable%2C_Portable_Docker_Container_Networks)
