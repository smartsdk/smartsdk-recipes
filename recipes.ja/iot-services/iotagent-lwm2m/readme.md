# IoT Agent (LWM2M)

この IoT Agent の公式ドキュメントは、[ここ](https://fiware-iotagent-lwm2m.readthedocs.io/)です。

## 要件

[ウェルカム・ページ](../../index.md)を読み、[インストール・ガイド](../../installation.md)で説明されている手順に従ってください。

## HTTP トランスポート

### カスタマイズ可能なもの

#### ENV 変数によるカスタマイズ

- `IOTA_VERSION`: [Agent Docker Image](https://hub.docker.com/r/telefonicaiot/lightweightm2m-iotagent/tags/)
   のバージョン番号 (tag)。デフォルトは `latest` です。

- `IOTA_LWM2M_PORT`: デフォルトは `5684` です

- `IOTA_LOG_LEVEL`: デフォルトは `DEBUG` です

- `IOTA_CB_HOST`: デフォルトは `orion` です

- `IOTA_CB_PORT`: デフォルトは `1026` です

- `IOTA_NORTH_PORT`: デフォルトは `4041` です

- `IOTA_REGISTRY_TYPE`: デフォルトは `mongodb` です

- `IOTA_MONGO_HOST`: デフォルトは `mongo` です

- `IOTA_MONGO_PORT`: デフォルトは `27017` です

- `IOTA_MONGO_DB`デフォルトは `iotagentjson` です

- `IOTA_MONGO_REPLICASET`: デフォルトは `rs` です。レプリカ・セットのオプションを無効にする設定を解除します

- `IOTA_PROVIDER_URL`: デフォルトは `http://iotagent:4041` です

変数のドキュメントについては、[グローバル設定ドキュメント](https://github.com/telefonicaid/iotagent-node-lib/blob/master/doc/installationguide.md)を参照してください。

#### ファイルによるカスタマイズ

- `config.js`: デプロイ前にこのファイルを自由に編集してください。これは
  エージェントによって設定ファイルとして使用されます。これは[設定](https://docs.docker.com/compose/compose-file/#configs)
  として Docker によって扱われます

### このレシピの展開

[インストール](../../installation.md)で説明したように、すでに環境をセットアップしていることを前提としています。

```
    docker stack deploy -c docker-compose.yml iota-lwm2m
```

デプロイされるサービスは次のとおりです :

- [IoTAgent-lwm2m](https://github.com/telefonicaid/lightweightm2m-iotagent)

``Note``

[公式ステップ・バイ・ステップのガイド](https://fiware-iotagent-lwm2m.readthedocs.io/en/latest/userGuide/index.html)
に従えば、次のようにして lwm2m クライアントをすぐに起動することができます：

```
    docker exec -ti [AGENT_CONTAINER_ID_HERE] node_modules/lwm2m-node-lib/bin/iotagent-lwm2m-client.js
```
