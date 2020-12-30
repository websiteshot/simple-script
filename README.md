# Simple Script

Simple Script to use the Websiteshot API.

## Prerequisites

You need a Project at [Websiteshot](https://websiteshot.app) and an API Key. Set both as environment variables:

```bash
export PROJECT=...
export APIKEY=...
```

## Example

### Create a new Screenshot

```bash
./simple-script.sh -a $APIKEY -p $PROJECT -c
```

### Get a Screenshot

```bash
./simple-script.sh -a $APIKEY -p $PROJECT -j $JOBID -g
```

### Download Screenshot

```bash
./simple-script.sh -a $APIKEY -p $PROJECT -j $JOBID -d
```
