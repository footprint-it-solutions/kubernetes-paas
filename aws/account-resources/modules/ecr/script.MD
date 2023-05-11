# Capture output of kubectl command into a variable

`import-images.sh`:

```bash
#!/bin/bash

IMAGES=$(kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}" |\
tr -s '[[:space:]]' '\n' |\
sort |\
uniq)

```

* Iterate over the lines in the variable

```bash
while read -r image; do
  echo $image
  # Do the bullet point steps below inside this while loop
done <<< $IMAGES
```

* Docker pull the image
* Check the first segment of the line, up to (but not including the first /); there are various ways to do this step and it is the most important in this script
* If it contains a `.` (e.g. gcr.io) it is a fully-qualified image source, else it is source relative to the default
repo, which is the Docker Hub
* For fully-qualified sources, replace the repo domain with the ECR domain, so that `gcr.io/istio-testing/pilot:latest` becomes
`AWS_ACCOUNT_NUMBER.dkr.ecr.eu-west-1.amazonaws.com/istio-testing/pilot:latest`
* Prepend the ECR domain to any relative sources, so that `coredns/coredns:1.6.6` becomes `AWS_ACCOUNT_NUMBER.dkr.ecr.eu-west-1.amazonaws.com/coredns/coredns:1.6.6`
* Docker tag the image with the ECR source
* Docker push
