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

This operation supports the options `secret` for client secret and `output` for format of output. For a full description of these options and their allowed values, see:

```
bundle exec bin/receiver help get
```
