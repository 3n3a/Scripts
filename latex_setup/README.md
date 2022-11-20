# Latex Setup

* [Setup Eisvogel Template for Pandoc](./setup-latex-eisvogel.sh)
  * [Eisvogel Dokumentation Github](https://github.com/Wandmalfarbe/pandoc-latex-template/blob/master/README.md)
  * [Template für mich](./template-eisvogel.md)

### `build-pdf`

Helps you build a pdf from a given entrypoint
LateX file. It then uses a custom docker image which 
has support for Minted and so on to build
the PDF.

### Workflow

Takes the build script and runs it on every push, on github actions.
