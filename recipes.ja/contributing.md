# コントリビューション

コントリビューションは[プルリクエスト](https://help.github.com/articles/about-pull-requests/)
の形でより歓迎されます。

何か間違って見える場合は、いつでも[問題 (issues) をオープン](https://github.com/smartsdk/smartsdk-recipes/issues)
できます。

CI プロセス中に、多数の Linter が実行されることに注意してください :

* yml ファイルの正確性を保証するため、[yaml linting ルール](https://yamllint.readthedocs.io/en/latest/rules.html)
をチェックすることをお勧めします

* ドキュメンテーション・スタイルの一貫性を保つために、MD の [linting ルール](https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md)
に従うことをお勧めします。

リポジトリへのプルリクエスト (PR) を作成すると、PR でのコンプライアンス検証の
結果を確認することができます。CI プロセスが正常に終了した場合にのみマージが
可能です。

## Portainer レシピへの貢献

SmartDSK レシピは、このガイドの後にコマンドライン・ツールを使用するか、または、
Portainer テンプレートを使用してデプロイ可能であることを目指しています。

Portainer テンプレート・ファイルのドキュメントは、[Stack テンプレート定義フォーマット](https://portainer.readthedocs.io/en/stable/templates.html#stack-template-definition-format)
で文書化されています。

しかし、json ファイルは人間が編集しやすいわけではないので、このプロジェクトでは
テンプレートを `portainer-template.yaml` ファイルに書き込む必要があります。
変更をコミットする前に、`portainer/templates.json` ファイルを更新するために、
プロジェクトのルート・ディレクトリから `make` を実行してください。次に、
`portainer-template.yaml` と `portainer/templates.json` ファイルを一緒に追加して
コミットします。

## ドキュメンテーション

今のところ、[Github Pages](https://pages.github.com) に [Mkdocs](http://www.mkdocs.org)
 を配備しています。

また、別の `docs` フォルダを用意する代わりに、ドキュメントは README のすべての
サブ・フォルダの内容で構成されているため、ドキュメントを可能な限り、それぞれの
レシピに近づけるようにしています。

索引の構造を変更したり、新しいページを追加したりする場合は、それに応じて
 `mkdocs.yml` を更新してください。

変更をローカルでプレビューすることができます。

```
    # from the location of mkdocs.yml
    $ mkdocs serve
```

すべての変更の後、次のコマンドを実行することを忘れないでください。

```
    # from the location of mkdocs.yml
    $ mkdocs gh-deploy
```
