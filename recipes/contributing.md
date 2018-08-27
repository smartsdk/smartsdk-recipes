# Contributing

Contributions are more than welcome in the form of
[Pull Requests](https://help.github.com/articles/about-pull-requests/).

Feel free to [open issues](https://github.com/smartsdk/smartsdk-recipes/issues)
if something looks wrong.

Be aware that during the CI process, a number of linters are run:

* To ensure correctness of yml files, we recommend you to check
  [yaml linting rules](https://yamllint.readthedocs.io/en/latest/rules.html).

* To ensure consistency of the documentation style, we recommend you to adhere
  to the MD [linting rules](https://github.com/markdownlint/markdownlint/blob/master/docs/RULES.md).

Once you make a pull request to the repository, you will be able to observe
the results of the compliancy verification in your PR. Merge will be only
possible after a successful CI run.

## Important observations for new recipes

1. Please add a `README.md` with an introduction on how to use the recipe and
    which things MUST be set in order for it to work.

1. State which services are **stateful** and which are **stateless**.

1. Provide the recipe with sensible defaults that work out of the box in the
    FIWARE Lab. Use as much defaults as possible, so users need little to none
    configuration before the first testing deployment.

1. Please keep recipes in order (respect the folder structure) following
    categories.

## Contributing to Portainer Recipes

The SmartDSK Recipes aim to be deployable both using command line
tools following this Guide or by using a portainer template.

The documentation of the portainer template file is documented in the
[Stack template definition format](https://portainer.readthedocs.io/en/stable/templates.html#stack-template-definition-format)

The json file is however not human friendly to edit, so in this
project the templates should be written in the
`portainer-template.yaml` files, and before committing changes, call
the `make` from the root directory of the project in order to update
the file `portainer/templates.json`.  Then Add and commit the files
`portainer-template.yaml` and `portainer/templates.json` together.

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
