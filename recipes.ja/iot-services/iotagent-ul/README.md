# IoT Agent (UL)

この IoT Agent の公式ドキュメントは、[ここ](http://fiware-iotagent-ul.readthedocs.io/en/latest/index.html)です。

## 要件

[ウェルカム・ページ](../../index.md)を読み、[インストール・ガイド](../../installation.md)で説明されている手順に従ってください。

## HTTP トランスポート

### カスタマイズ可能な設定

#### ENV 変数によるカスタマイズ

変数のドキュメントについては、[グローバル設定ドキュメント](https://github.com/telefonicaid/iotagent-node-lib/blob/master/doc/installationguide.md)を参照してください。

- `IOTA_VERSION`: [Agent Docker Image](https://hub.docker.com/r/telefonicaiot/iotagent-ul/~/dockerfile/)
   のバージョン番号 (tag)

- `IOTA_LOG_LEVEL`: デフォルトは `DEBUG` です

- `IOTA_TIMESTAMP`: デフォルトは `true` です

- `IOTA_CB_HOST`: デフォルトは `orion` です

- `IOTA_CB_PORT`: デフォルトは `1026` です

- `IOTA_NORTH_PORT`: デフォルトは `4041` です

- `IOTA_REGISTRY_TYPE`: デフォルトは `mongodb` です

- `IOTA_MONGO_HOST`: デフォルトは `mongo` です

- `IOTA_MONGO_PORT`: デフォルトは `27017` です

- `IOTA_MONGO_DB`: デフォルトは `iotagentjson` です

- `IOTA_MONGO_REPLICASET`: デフォルトは `rs` です。レプリカ・セットのオプションを無効にする設定を解除します

- `IOTA_HTTP_PORT`: デフォルトは `7896` です

- `IOTA_PROVIDER_URL`: デフォルトは `http://iotagent:4041` です

#### ファイルによるカスタマイズ

- `config.js`: 展開する前にこのファイルを自由に編集してください。これは
  エージェントによって設定ファイルとして使用されます。これは[設定](https://docs.docker.com/compose/compose-file/#configs)
  として Docker によって扱われます

### このレシピのデプロイ

[インストール](../../installation.md)で説明したように、すでに環境をセットアップしていることを前提としています。

```
    docker stack deploy -c docker-compose.yml iota-ul
```

デプロイされるサービスは次のとおりです :

- [IoTAgent-ul](https://github.com/telefonicaid/iotagent-ul)
