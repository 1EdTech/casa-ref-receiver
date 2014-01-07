# CASA Receiver Module

[![Build Status](https://travis-ci.org/AppSharing/casa-receiver.png)](https://travis-ci.org/AppSharing/casa-receiver) [![Dependency Status](https://gemnasium.com/AppSharing/casa-receiver.png)](https://gemnasium.com/AppSharing/casa-receiver) [![Code Climate](https://codeclimate.com/github/AppSharing/casa-receiver.png)](https://codeclimate.com/github/AppSharing/casa-receiver)

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
