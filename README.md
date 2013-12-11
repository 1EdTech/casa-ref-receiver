# CASA Receiver Module

## Setup

Install gems via Bundler:

```
bundle
```

## Run

This module is intended to be run as part of the [CASA Engine reference implementation](https://github.com/AppSharing/casa-engine); however, it may also be run directly standalone to query publishers as detailed herein.

To query a manually via the command line:

```
thor receiver:get_payloads
```

This will request a URL for the server and an optional secret, then issuing a query and returning the result/error; it will then the user whether to issue another query or not.
