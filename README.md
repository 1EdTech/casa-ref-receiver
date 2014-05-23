# CASA Receiver Module

The [Community App Sharing Architecture (CASA)](http://imsglobal.github.io/casa) provides a mechanism for
discovering and sharing metadata about web resources such as websites, mobile
apps and LTI tools. It models real-world decision-making through extensible
attributes, filter and transform operations, flexible peering relationships,
etc.

This Ruby gem is part of the CASA reference implementation. It provides an
implementation of the CASA Receiver Module as a command-line tool; further,
it can be hooked into a larger environment such as the [CASA engine](https://github.com/IMSGlobal/casa-engine).

## License

This software is **open-source** and licensed under the Apache 2 license.
The full text of the license may be found in the `LICENSE` file.

## Setup

Install gems via Bundler:

```
bundle
```

## Run

This module is intended to be run as part of the [CASA Engine reference implementation](https://github.com/AppSharing/casa-engine); however, it may also be run directly standalone to query publishers as detailed herein.

To query a manually via the command line:

```
bundle exec bin/receiver get SERVER_URL
```

For example, if a publisher resides at `http://example.com` (publishing payloads under `http://example.com/payloads`), then the query would be executed as:

```
bundle exec bin/receiver get http://example.com
```

If the publisher were to require a secret:

```
bundle exec bin/receiver get http://example.com --secret=qwerty1
```

The `--output` option may be used to specify `yaml` or `none`:

```
bundle exec bin/receiver get http://example.com --output=yaml
```

The `--store` option should be used if one wishes to write the result to persistence:

```
bundle exec bin/receiver get http://example.com --store --output=none
```

When using `--store`, you can empty your existing persistence with:

```
bundle exec bin/receiver reset
```

Full documentation may be found via `help` and `help COMMAND`:

```
bundle exec bin/receiver help
bundle exec bin/receiver help get
bundle exec bin/receiver help reset
```
