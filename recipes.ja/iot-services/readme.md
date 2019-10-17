<hr class="iotagents" style="display:none" />

# バックエンドデバイス管理 (IDAS)

このチャプターの詳細については、[こちら]( https://catalogue.fiware.org/chapter/internet-things-services-enablement)を参照してください。

この GE の詳細については、[こちら](https://catalogue.fiware.org/enablers/backend-device-management-idas)を参照してください。

## IoT Agents

### なぜ、IoT Agent を使うのですか？

- IoT デバイス固有のプロトコルを NGSI に変換します。アクティブ属性とも呼ばれます

- いくつかの間隔で IoT デバイスからデータをリクエストします。レイジー属性とも呼ばれます

- Context Broker 内のコンテキストに基づいて、IoT デバイス通信に関するコマンドを実行します

利用可能な IoT Agent の各レシピのサブフォルダを確認します。エージェントは
ステートレス・サービスと見なすことができます。したがって、ルーティングの目的で
エージェントのサービス名を使用して設定を保持する場合、必要な量のレプリカを持つ
 swarm のレプリカ・モードで展開できます。

優れたスケーラビリティのために、永続性が必要なケースでエージェントが使用する
 mongo データベースをデプロイする場合は、mongo レプリカ・セット用に提供された
レシピで展開するようにしてください。詳細は[こちら](../utils/mongo-replicaset/readme.md)を参照してください。

### テスト

現地の開発環境で IoT Agent を試したい場合は、対応するレシピを使用して、補完的な
サービス (OrionとMongo) を展開することができます。[Orion](../data-management/context-broker/ha/readme.md)
 と [Mongo](../utils/mongo-replicaset/readme.md) の説明を参照してください。

公式ドキュメント・ガイドのステップ・バイ・ステップを実行している場合は、`test`
 サブフォルダ内のスクリプトが役立つことがあります。urls を調整する必要がある
場合、、ローカルホストですべてを実行していることを忘れないでください。Docker
 ネットワーク内にいる場合はサービス名を使用し、クラスタ外の場合は、Docker swarm
 ノード (いずれか) の IP を使用できます。`setup.sh` をチェックアウトして
ください。
