## Contributions

Contributions are more than welcome in the form of [Pull Requests](https://help.github.com/articles/about-pull-requests/).

Feel free to [open issues](https://github.com/smartsdk/smartsdk-recipes/issues)
if something looks wrong.


## Documentation

For now we are using [Mkdocs](http://www.mkdocs.org) deploying on
[Github Pages](https://pages.github.com).

You will also notice that instead of having a separate `docs` folder,
the documentation is composed of the README's content of all subfolders so as
to keep docs as close to the respective recipes as possible.

If you change the structure of the index or add new pages, remember to update
`mkdocs.yml` accordingly.

Note you can preview your changes locally by running

```
    # from the location of mkdocs.yml
    $ mkdocs serve
```

After all your changes, remember to run

```
    # from the location of mkdocs.yml
    $ mkdocs gh-deploy
```
