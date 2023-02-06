# aws-url-shortner-api

This project contains the necessary infrastructure as code and lambda code to host a URL shortener API.

# Installation

To begin, open the `provider.tf` file and under the aws provider change the profile used. Put your own profile name in `<YOUR_AWS_CONFIGURE_PROFILE>`. 

If you have not configured a profile you can do so by executing this:

```
aws configure --profile <YOUR_PROFILE_NAME>
```


Then change the `<YOUR_AWS_REGION>` to `us-east-1`.

```
provider "aws" {
  region = "us-east-1"
  profile = "profile_name"
}
```

Execute the following commands to deploy the infrastructure and lambdas:

Lambda build:

```sh
npm install --prefix ./functions/get-short-url
```

Terraform init and apply:
```sh
terraform init
terraform apply
```

Once deployed, you should see in the outputs the URL's pointing to your lambdas.

# API Usage

The API contains 3 different lambdas. Below we explain how to use each:

* get_short_url: Generates the short url from a long url and stores it in a DynamoDB table.
* get_original_url: Fetches the original URL by passing a `shortValue` generated by the first API call.
* get_url_stats: Fetches details about a URL without increasing the `viewsCount` property.

## Get Short URL API

Method: `POST`

URL Example: (See Terraform output for `get_short_url_function_url` for actual URL)
```
https://<ID.lambda-url.us-east-1.on.aws/
```

Request Body:

```
{
    "url": "https://google.com"
}
```

Response Body:

```
{
    "lastViewedDate": "2023-02-06T00:15:05.319Z",
    "createdDate": "2023-02-06T00:15:05.319Z",
    "shortUrl": "https://cutmyurl.com/oaIL23dz",
    "viewsCount": 0,
    "shortValue": "oaIL23dz",
    "originalUrl": "https://google.com"
}
```


## Get Original URL

Method: `GET`

URL Example: (See Terraform output for `get_original_url_function_url` for actual URL)
```
https://<ID.lambda-url.us-east-1.on.aws
```

Request Query:

```
https://<ID.lambda-url.us-east-1.on.aws?shortValue=<SHORT_VALUE>
```

Response Body:

```
{
    "viewsCounter": "2",
    "lastViewedDate": "2023-02-06T00:47:44.471Z",
    "createdDate": "2023-02-06T00:44:01.242Z",
    "shortUrl": "https://<YOUR_DOMAIN_NAME>/lgatGICp",
    "shortValue": "lgatGICp",
    "originalUrl": "https://google.com"
}
```


## Get URL Statistics
  
Method: `GET`

URL Example: (See Terraform output for `get_url_stats_function_url`)
```
https://<ID.lambda-url.us-east-1.on.aws
```

Request Query:

```
https://<ID.lambda-url.us-east-1.on.aws?shortValue=<SHORT_VALUE>
```

Response Body:

```
{
    "viewsCounter": "2",
    "lastViewedDate": "2023-02-06T00:47:44.471Z",
    "createdDate": "2023-02-06T00:44:01.242Z",
    "shortUrl": "https://<YOUR_DOMAIN_NAME>/lgatGICp",
    "shortValue": "lgatGICp",
    "originalUrl": "https://google.com"
}
```