# ツール

このセクションでは、有用な、そして時には一時的な、スクリプトと、ツール、プロジェクト、およびレシピの開発に使用されるドキュメントのリファレンスを紹介します。

基本的な環境設定については、ドキュメントの[インストール](../installation.md)の部分で説明しています。

## レシピで遊ぶ？

### [miniswarm](https://github.com/aelsabbahy/miniswarm)


テスト目的でローカルの virtualbox ベースの swarm クラスタをすばやくセットアップするのに役立つ便利なツールです。

### [wait-for-it](https://github.com/vishnubob/wait-for-it)

サービスの開始を待つ必要がある場合に使用する便利なシェルスクリプトです

*注* : Docker が[ヘルスチェック](https://docs.docker.com/engine/reference/builder/#/healthcheck)機能を導入したので、これはもう必要ではないかもしれません。

### [docker-swarm-visualizer](https://github.com/dockersamples/docker-swarm-visualizer)

swarm クラスタのコンテナの配布に関する基本的な方法には、次のフォルダに用意されている
 `visualzer.yml` ファイルを使用できます。

```
docker stack deploy -c visualizer.yml vis
```

### [portainer](https://portainer.readthedocs.io)

swarm に関する情報を得るための、より洗練された UI が必要な場合は、このように portainer をデプロイできます。

```
docker service create \
  --name portainer \
  --publish 9000:9000 \
  --constraint 'node.role == manager' \
  --mount type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  portainer/portainer \
  -H unix:///var/run/docker.sock
```

あるいは、このフォルダにある docker-compose ファイルを利用することもできます。

```
docker stack deploy -c portainer.yml portainer
```

### [postman](https://www.getpostman.com/)

API を試すためのよく知られたツールです。Postman からのレシピの curl ベースの例を
試したいですか？ このフォルダにある ```postman_collection.json`` ファイルを
インポートし、テストを簡単にします。注：このコレクションは進行中の作業のため、
自由に[コントリビューション](../contributing.md)できます！

## ドキュメントを書くには？

私たちは、通常、[markdown](https://daringfireball.net/projects/markdown/) 形式で
ドキュメントを作成します。次に、[mkdocs](http://www.mkdocs.org/) を使用して
 html 形式を生成します。このプロジェクトのルートに `mkdocs.yml` 設定ファイルが
あります。

アーキテクチャ図では、[PlantUML](http://plantuml.com/) を使用します。
ダイアグラムについては、[このプロジェクト](https://github.com/smartsdk/architecture-diagrams)
で見つけることができるフィーチャの表記規則に従います。

このドキュメントでは図をアップロードする代わりに、[gravizo](http://www.gravizo.com)
 の機能を使って `.dot` ファイルや PlantUML ファイルを変換し、それらをオンライン
で図として提供しています。[gravizo のコンバータ](http://www.gravizo.com/#converter)
で行われる中間変換があります。レシピのソース `readme.md` を調べて例を見て
ください。

有用であるかもしれないドキュメンテーションのための他のツールは...

### [draw.io](https://www.draw.io)

ダイアグラムが最初から複雑になることが予想されるときに、ダイアグラムが複雑すぎる
ようになると、このツールを使用します。

単純な変更を加えることは、手動で gui ベースの変更を行うよりも、`.dot` ファイルを
理解するのに時間がかかります。

draw.io を使用する場合は、リポジトリ内のソースファイルを `/doc` 対応するレシピの
サブフォルダの下に保持します。


### [色の名前](http://www.graphviz.org/doc/info/colors.html)

`.dot` ファイルで使用される色の名前のリファレンスです。

### [diagramr](http://diagramr.inventage.com) (廃止予定)

より多くの Docker 関連の詳細を提供するために、このツールを使用して、
docker-compose ファイルから図を作成することができます。ツールは、最終的に
カスタマイズされ、[graphviz](http://www.graphviz.org) を使用して `png` ファイル
に変換される `.dot` ファイルも提供します。

```
$ dot compose.dot -Tpng -o compose.png
```
