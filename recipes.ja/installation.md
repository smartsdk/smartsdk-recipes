# レシピを入手

git リポジトリから最新バージョンを入手してください。

```
$ git clone https://github.com/smartsdk/smartsdk-recipes
```

## 要件

レシピは最新の [Docker](https://docs.docker.com) バージョン (最小 1.13+、理想的
には 17.06.0+ 以上) を使用して実行する準備を整えました。Docker をインストール
するには、[インストール手順](https://docs.docker.com/engine/installation/)を参照
してください。

いくつかのテストとチュートリアルでは、[curl](https://curl.haxx.se/) がシステムで
また利用できない場合は、curl をインストールする必要があり ます。

最後に、ローカル環境でクラスタを作成してレシピをテストする場合は、[VirtualBox](https://www.virtualbox.org/wiki/Downloads)
 をインストールする必要が あります。次のセクションを参照してください。

**注** : 多くのチュートリアルと検証手順は、通常 Linux/macOS 環境にあるツールを
実行するように設計されています。したがって、Windows ユーザの場合、時折互換性の
ある回避策を検討する必要があります。


## ローカル Swarm クラスタの準備

### クラスタの作成

[docker-compose](https://docs.docker.com/compose/install/) を使用してレシピの
ほとんど (すべてではないが) を実行することができますが 、レシピは
 Docker Swarm Clusters のサービスとしてデプロイされるように調整されています。

以下を単純に実行することで、ローカルの Docker クライアントを単一ノードの Swarm クラスタにすることができます :

```
$ docker swarm init
```

しかし、実際にマルチ・ノード・クラスタで作業しているときは、より面白くなります。

作成する最も速い方法は、[miniswarm](https://github.com/aelsabbahy/miniswarm) を使用することです。始めるのは簡単です：

```
# First-time only to install miniswarm
$ curl -sSL https://raw.githubusercontent.com/aelsabbahy/miniswarm/master/miniswarm -o /usr/local/bin/miniswarm
$ chmod +rx /usr/local/bin/miniswarm

# Every time you create/destroy a swarm
$ miniswarm start 3
$ miniswarm delete
```

これ以外の場合は、[docker-machine](https://docs.docker.com/machine/overview/) を
使用して自分で作成することもできます。

### ネットワークの作成

便宜上、レシピのすべてではないにしても、ほとんどがオーバレイ・ネットワークを使用
してサービスに接続します。私たちは少なくとも2つのオーバーレイ・ネットワークを
利用できるという慣習に同意しました。"バックエンド" と "フロントエンド" です。
後者は、通常、外部への露出を必要とするサービスを接続します。

時間稼ぎをしたい場合、レシピでトライアルを開始する前に2つのネットワークを作成
することができます。これは、次のコマンドを実行することで実行できます :

```
$ docker network create -d overlay --opt com.docker.network.driver.mtu=${DOCKER_MTU:-1400} backend
$ docker network create -d overlay --opt com.docker.network.driver.mtu=${DOCKER_MTU:-1400} frontend
```

または、`tools` フォルダにスクリプトがあります。

```
$ sh tools/create_networks.sh
```

繰り返しますが、これはレシピでの実験を簡単にするための慣習です。最終的には、
特定のネットワーキングのニーズに合わせてレシピを編集することができます。


#### 仮想化された環境

FIWARE Lab などの仮想化された環境でレシピを実行している場合、ある時点でコンテナ
の外部への接続に問題が発生する場合があります。パケット落下の原因が [MTU](https://en.wikipedia.org/wiki/Maximum_transmission_unit)
 の不一致に起因する可能性があります。

FIWARE Lab では、VMのブリッジのデフォルトの MTU は `1400` に設定されているため、
これがレシピで使用されるネットワークのデフォルトの MTU になっています。その値を
変更する必要がある場合は、ネットワークを作成する前に自由に `DOCKER_MTU` の環境
変数を設定してください。
