## Copy Product

This command makes a copy of the referenced product.
Target product will be searched by the source product system name.
System name can be overridden with `--target-system-name` option.
If a product with the selected `system-name` is not found, it will be created.

Components of the backend being copied:
* product configuration
* product settings: Staging/Production Public Base URL only copied for self-managed deployments.
* product methods&metrics: Only missing metrics&methods will be created.
* product mapping rules: Only missing mapping rules will be created.
* product application plans & pricing rules & limits: Only missing application plans & pricing rules & limits will be created.
* product application usage rules
* product policies
* product backends: Only missing backends will be created.
* product activedocs: Only missing activedocs will be created.

3scale instances can be either a [URL](docs/remotes.md#remote-urls) or the name of a [remote](docs/remotes.md).

```shell
NAME
    copy - Copy product

USAGE
    3scale product copy [opts] -s <source-remote>
    -d <target-remote> <source-product>

DESCRIPTION
    This command makes a copy of the referenced product. Target product will
    be searched by the source product system name. System name can be overridden
    with `--target-system-name` option. If a product with the selected
    `system_name` is not found, it will be created.

    Components of the product being copied:

    product configuration

    product settings

    product methods&metrics: Only missing metrics&methods will be created.

    product mapping rules: Only missing mapping rules will be created.

    product application plans & pricing rules & limits: Only missing
    application plans & pricing rules & limits will be created.

    product application usage rules

    product policies

    product backends: Only missing backends will be created.

    product activedocs: Only missing activedocs will be created.

OPTIONS
    -d --destination=<value>            3scale target instance. Url or remote
                                        name
    -s --source=<value>                 3scale source instance. Url or remote
                                        name
    -t --target-system-name=<value>     Target system name. Default to source
                                        system name

OPTIONS FOR PRODUCT
    -c --config-file=<value>            3scale toolbox configuration file
                                        (default: $HOME/.3scalerc.yaml)
    -h --help                           show help for this command
    -k --insecure                       Proceed and operate even for server
                                        connections otherwise considered
                                        insecure
    -v --version                        Prints the version of this command
       --verbose                        Verbose mode

```

```shell
3scale product copy [-t target-system-name] -s 3scale1 -d 3scale2 product_01
```
