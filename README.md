<hr />

<div align="center">
    <a href="https://websiteshot.app/">
        <img src="./assets/logo-mini.png">
    </a>
</div>

<div align="center">
<p>Never spend time again to create awesome screenshots of your websites.</p>
</div>

<div align="center">
<a style="margin: 1em;" href="https://websiteshot.app">Website</a> | <a style="margin: 1em;" href="https://console.websiteshot.app">Console</a> | <a style="margin: 1em;" href="https://github.com/websiteshot/community/discussions">Community</a> | <a style="margin: 1em;" href="https://docs.websiteshot.app">Documentation</a>
</div>

<hr />

# Simple Script

Simple Script to use the Websiteshot API.

## Available Options

```bash
-h, --help      Print this help and exit
-v, --verbose   Print script debug info
-p, --project   Argument: ProjectId
-a, --apikey    Argument: API Key
-t, --template  Argument: TemplateId
-j, --job       Argument: JobId
-w, --website   Argument: URL of Website
-vw, --width    Argument: Width of View
-vh, --height   Argument: Height of View
-c, --create    Creates a new Screenshot Job
-g, --get       Get needed data for JobId
-d, --download  Download first Screenshot of Job
```

## Prerequisites

You need a Project at [Websiteshot](https://websiteshot.app) and an API Key. Set both as environment variables:

```bash
export PROJECT=...
export APIKEY=...
```

If you want to trigger a Screenshot by Template Id add an environment variable for the template:

```bash
export TEMPLATE=...
```

The Script uses cURL and [jq](https://stedolan.github.io/jq/). Both tools need to be installed on your system.

## Example

### Create a new Screenshot

```bash
./simple-script.sh -a $APIKEY -p $PROJECT -c
```

Or by Template Id:

```bash
./simple-script.sh -a $APIKEY -p $PROJECT -t $TEMPLATE -c
```

The Script executes the follwing cURL command:

```bash
curl -H 'Authorization: '"${apikey}"'' -H "Content-Type: application/json" -d '{"screenshotParameter":{"width":'"${width}"', "height":'"${height}"'}, "urls":[{"url":"'"${website}"'", "name":"'"${website}"'"}]}' -X POST ${baseurl}/api/projects/${project}
```

Output:

```bash
Create Request for Project abcdef...
Project: abcdef...
Website: https://websiteshot.app
Job: abcdef...
Screenshot Url: unset
Width: 1200
Height: 720
```

### Get a Screenshot

```bash
./simple-script.sh -a $APIKEY -p $PROJECT -j $JOBID -g
```

Output:

```bash
Get Request for Job abcdef... of Project abcdef...
Project: abcdef...
Website: https://websiteshot.app
Job: abcdef...
Screenshot Url: https://...
Width: 1200
Height: 720
```

### Download Screenshot

```bash
./simple-script.sh -a $APIKEY -p $PROJECT -j $JOBID -d
```
