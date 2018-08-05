# IoT Agent (JSON)

この IoT Agent の公式ドキュメントは、[ここ](http://fiware-iotagent-json.readthedocs.io/en/latest/index.html)です。

## 要件

[ウェルカム・ページ](../../index.md)を読み、[インストール・ガイド](../../installation.md)で説明されている手順に従ってください。

## MQTT トランスポート

### カスタマイズ可能な設定

#### ENV 変数によるカスタマイズ

変数のドキュメントについては、[グローバル設定ドキュメント](https://github.com/telefonicaid/iotagent-node-lib/blob/master/doc/installationguide.md)を参照してください。

- `MOSQUITTO_VERSION`: [Mosquitto Docker Image](https://hub.docker.com/\_/eclipse-mosquitto/)
   のバージョン番号 (tag)。デフォルトは `1.4.12` です

- `IOTA_MQTT_HOST`: デフォルトは`mosquitto` で、Docker サービスの名前です

- `IOTA_MQTT_PORT`: デフォルトは`1883` です

- `IOTA_VERSION`: [Agent Docker Image](https://hub.docker.com/r/telefonicaiot/iotagent-json/~/dockerfile/)
   のバージョン番号 (tag)。デフォルトは `1.6.0` です

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

- `config.js`: デプロイ前に、このファイルを自由に編集してください。これは
  エージェントによって設定ファイルとして使用されます。これは[設定](https://docs.docker.com/compose/compose-file/#configs)
  として Docker によって扱われます。ENV 変数で指定した値は、ファイルに設定されて
  いる値よりも優先されます

- `mosquitto.conf`: デプロイ前に、このファイルを自由に編集してください。設定
  ファイルとして mosquitto が使用します。これは[設定](https://docs.docker.com/compose/compose-file/#configs)
  として Docker によって扱われ ます

### このレシピの展開

[インストール](../../installation.md)で説明したように、すでに環境をセットアップしていることを前提としています。

```
    docker stack deploy -c docker-compose.yml iota-json
```

デプロイされるサービスは次のとおりです :

- [IoTAgent-json](https://github.com/telefonicaid/iotagent-json)

- [Mosquitto](http://mosquitto.org/) as MQTT Broker

### 覚えておいていただきたい重要なこと

- 今日の時点で、公式 Mosquitto Docker イメージは、mosquitto-clients を含んで
  いないので、`mosquitto_sub` と `mosquitto_pub` ようなコマンドを実行する場合、
  基本的に2つのオプションがあります：

  1. システムにそれらをインストールし、host パラメータを追加して、docker mosquitto service を指すようにします

  1. クライアントを mosquitto コンテナにインストールします。これはコンテナの
     再起動後も持続しないことに注意してください。これを必要とする場合は、
     それに応じて Docker イメージを作成してください

```
       docker exec -ti mosquitto_container sh -c "apk --no-cache add mosquitto-clients"
```

## TODO

- このレシピを確認するためのステップ・バイ・ステップ・ガイドの完全なテストは、エージェントで初めてのウォークスルーのための最小要件をすべて提供します。[この問題](https://github.com/telefonicaid/iotagent-json/issues/222)に依存します。
