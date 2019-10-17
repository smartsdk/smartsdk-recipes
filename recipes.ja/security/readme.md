<hr class="security" style="display:none" />

# セキュリティ管理

FIWARE のセキュリティは、次の機能を提供するさまざまなサービスによって保証されて
います :

* Identity Management (IDM): リファレンス実装は現在、
  [KeyRock](http://fiware-idm.readthedocs.io/en/latest/index.html) です
* Policy Decision Point PDP service: リファレンス実装は現在、
  [authzforce](http://authzforce-ce-fiware.readthedocs.io/en/latest/) です
* Policy Enforcement Point (PEP): リファレンス実装は現在、
  [Wilma](http://fiware-pep-proxy.readthedocs.io/en/latest/) ですが、
  すぐに [API Umbrella](https://apiumbrella.io) の拡張によって置き換えられます

上記のすべての要素を組み合わせると、FIWARE APIs 用の AAA ソリューションが提供
されます。

レシピでは、当面は、API Umbrella をベースにした PEP Proxy の継続的な実装のみを
カバーしています。これは、次の事実によるものです :

* KeyRock は強力な開発を受けており、すぐに新しいリリースが発表され、現在の
  FIWARE Lab IDMは、独自のインスタンスを導入する必要なしに、どのプロジェクトにも
  使用できます
* PDP は複雑なシナリオでのみ必要であり、FIWARE Lab で利用可能な PDP は、独自の
  インスタンスを展開する必要なしに、どのプロジェクトにも使用できます
