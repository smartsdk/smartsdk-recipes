# SmartSDK Recipes
[![License badge](https://img.shields.io/badge/license-AGPL-blue.svg)](https://opensource.org/licenses/AGPL-3.0)
[![Documentation badge](https://img.shields.io/badge/docs-WIP-yellow.svg)](https://martel-innovate.github.io/smartsdk-recipes/)

## Introduction
This repository is part of the [SmartSDK](http://smartsdk.eu/) project and contains recipes for different [FIWARE Generic Enablers](https://catalogue.fiware.org).

For more info, refer to the _readme.md_ of each subfolder or directly to the [docs](https://martel-innovate.github.io/smartsdk-recipes/).

## How to use

    $ git clone --recursive https://github.com/martel-innovate/smartsdk-recipes.git

## License
This repository is licensed under Affero General Public License (GPL) version 3.

## Documentation

For now we are using [Mkdocs](http://www.mkdocs.org) deploying on [Github Pages](https://pages.github.com), but we might change to [readthedocs](https://readthedocs.org) to keep aligned with most of fiware GEs.

You will also notice that instead of having a separate _docs_ folder, the documentation is composed of the readme.md content of all subfolders so as to keep docs as close to the respective recipes as possible.

###### Updating docs
If you change the structure of the index or add new pages, remember to update _mkdocs.yml_ accordingly.
Then run:

    $ mkdocs gh-deploy

## To-do
- Automatic docs updates (consider readthedocs with webhooks)
- Create a how-to-contribute section.
