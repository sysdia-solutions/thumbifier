# Thumbifier Engine

The thumbify.me Thumbifier Engine for converting various media file
formats into resized jpgs.

## Introduction

The Thumbifier Engine is a RESTful service that allows an authenticated
user to provide a URL to a media file, convert it into a jpg and
resize the output to the provided dimensions. The output jpg is then
POSTed to a provided callback URL for consumption.

The Thumbifier Engine uses pooled processes to run the conversion
as background processes but limiting the number of spawned processes
to prevent the system resources from being exhausted.

In short, this service is great for taking various file formats and
creating jpg thumbnails.

## Prerequisites

The Thumbifier Engine requires the following:

* Erlang/OTP 0.17 [erts-6.4]
* Elixir 1.0.4
* PostgresSQL 9+ database
* ImageMagick 6+
* FFmpeg

## Getting Started

### Installation

* `git clone git@github.com:sysdia/thumbifier.git`
* `cd thumbifier/`
* `mix deps.get`
* Configure the required environments (see below)

### Configuration

There are two ways the Thumbifier can be configured:

1. `<env>.secret.exs` file for the executing environment
1. Environment Variables

#### env.secret.exs Configuration

This method is the best way to configure the dev and test environment.
Located in the `config/` directory is an example secret.exs file:

`env.secret.exs.example`

This file contains all of the required configuration fields.

To create an environment configuration file:

* Copy the example file replacing `env` with the required environment
  * Test -> `cp config/env.secret.exs.example config/test.secret.exs`
  * Dev -> `cp config/env.secret.exs.example config/dev.secret.exs`
  * Prod -> `cp config/env.secret.exs.example config/prod.secret.exs`
* Edit the newly created secret.exs file and amend accordingly

#### Environment Variables

To use Environment variables to configure is ideal for a production
server especially where secret.exs config files cannot be created.

All Thumbifier environment variables begin with `ENV_THUMBIFIER` to
aid easier identification of any existing set variables.

To set the environment variables, please refer to the hosting solution.

#### Configuration Fields

The configuration fields are as follows (including the ENV name):

* config :thumbifier
  * __poolboy_size__ `ENV_THUMBIFIER_POOLBOY_SIZE`
    * [int] Number of converter workers to run concurrently
  * __poolboy_max_overflow__ `ENV_THUMBIFIER_POOLBOY_MAX_OVERFLOW`
    * [int ]Number of reserve converter workers to be on standby
  * __max_file_size__ `ENV_THUMBIFIER_MAX_FILE_SIZE`
    * [int] Maximum file size of the media URL that will be processed
* config :thumbifier, Thumbifier.Endpoint
  * __secret_key_base__ `ENV_THUMBIFIER_SECRET_KEY_BASE`
    * [binary] A unique key for encryption, part of Phoenix Framework
* config :thumbifier, Thumbifier.Repo
  * __hostname__ `ENV_THUMBIFIER_DB_HOSTNAME`
    * [binary] The URL to where the database is being hosted
  * __port__ `ENV_THUMBIFIER_DB_PORT`
    * [int] The port in which the database is running on
  * __database__ `ENV_THUMBIFIER_DB_DATABASE`
    * [binary] The name of the database
  * __username__ `ENV_THUMBIFIER_DB_USERNAME`
    * [binary] The username for authenticating with the database
  * __password__ `ENV_THUMBIFIER_DB_PASSWORD`
    * [binary] The password for authenticating with the database
* config :thumbifier, Thumbifier.Util.Email
  * __hostname__ `ENV_THUMBIFIER_EMAIL_HOSTNAME`
    * [binary] The SMTP hostname/relay URL
  * __username__ `ENV_THUMBIFIER_EMAIL_USERNAME`
    * [binary] The username for authenticating with SMTP service
  * __password__ `ENV_THUMBIFIER_EMAIL_PASSWORD`
    * [binary] The password for authenticating with the SMTP service
  * __port__ `ENV_THUMBIFIER_EMAIL_PORT`
    * [int] The port for connecting to the SMTP service
  * __from__ `ENV_THUMBIFIER_EMAIL_FROM`
    * [binary] The email to use as the FROM address from engine emails

### Running

Once the dependencies have been installed and the environment
configuration has been set, then the Thumbifier Engine is ready to run.

* `mix ecto.migrate` to create the required database tables
* `mix phoenix.server` to run the engine at `http://127.0.0.1:4000`


### Deployment

Deployment of the Thumbifier Engine service is achieved by using the
[exrm](https://github.com/bitwalker/exrm) Elixir Release Manager.

The Elixir Release Manager is a build tool that makes generating
project releases really easy.

The following instructions show how to create a release using exrm:

* Ensure the production environment is configured. See [Configuration](#configuration)
  * It is recommended to configure it using the [prod.secret.exs](#envsecretexs-configuration) file
* Run the mix release task specifying the port and environment
  * `PORT=8888 MIX_ENV=prod mix release`
  * This will run the build process for the project and bundle it up
* The bundled project is collected into a .tar.gz file located in:
  * `./rel/thumbifier/thumbifier-0.0.1.tar.gz`
  * This compressed file contains all components to run the service
* Copy the `thumbifier-0.0.1.tar.gz` file to the production server
  * Example using scp: `scp thumbifier-0.0.1.tar.gz user@remote-ip:~/`
* On the remote server, extract the bundled project and start it
  * `tar -xf ~/thumbifier-0.0.1.tar.gz`
  * Start the service: `~/thumbifier/bin/thumbifier start`
    * The service will now accept requests on the configured port
    * Example: `http://remote-ip:8888`
  * To run the database setup and migrations:
    * `~/thumbifier/bin/thumbifier rpc Elixir.Ecto.Storage up "['Elixir.Thumbifier.Repo']".`
    * `~/thumbifier/bin/thumbifier rpc Elixir.Ecto.Migrator run "['Elixir.Thumbifier.Repo', <<\"~/thumbifier/lib/thumbifier-0.0.1/priv/repo/migrations\">>, up, [{all, true}]]."`
  * To stop the service if needed: `~/thumbifier/bin/thumbifier stop`

#### Quick Docker Deployment

A simple way to test deployment is to use the provided docker
container (requires Docker 0.8+). The docker container builds with
all of the required dependencies except a database server.

To utilise the docker container:

  * Ensure a `config/prod.secret.exs` file exists correctly configured.
    * Requires database configuration for production with the correct
      `hostname` as it won't be `localhost` inside the container.
    * Requires the http port setting to `port 80`

      ```
      config :thumbifier, Thumbifier.Endpoint,
        http: [port: 80]
      ```
  * Run the Ecto migrations for production `MIX_ENV=prod mix ecto.migrate`
  * Start the docker container `./docker-deploy.sh start`

    _note: this command may require being run as sudo_

The script should run the `exrm` build and release process then start
the docker build process adding the build to the container.

Once the process is complete, the service should be accessible by
visiting `http://127.0.0.1` as docker is configured to map the host
port 80 to the docker container port 80 (where the service is running).

To terminate the docker container, simply run `./docker-deploy.sh kill`

## Using the Thumbifier

### Introduction

The Thumbifier Engine requires an authenticated user to perform a
conversion. An authorised user can use the engine for a set number
of times within a 10 minute period before the usage limit is exceeded.
The usage counter will reset after the 10 minute period has passed.

When a new user is created, an API key will be automatically generated
for the user, which can be used to get the user details from the engine
and these details contain an access token which is a time limited
token to make a conversion call to the engine.

Access tokens expire within 10 minutes of being generated.

When the engine is called, it will convert the given media URL to a jpg
and then POST the resulting jpg as a base64 encoded string to the
provided callback URL.

The engine is not a timed service as the conversion process runs as a
background task meaning if the process pool has been exceeded then jobs
to convert will take longer to complete, but they are queued up so they
should complete eventually.

### Routes

* `/users` - User actions
  * `POST /users` - Create new user
    * Parameters
      * `email` - The unique email address for the newly created user
    * Returns [201 Created] - JSON payload
      * `email` - The provided email address
      * `api_key` - A uniquly generated key for authenticating
  * `GET /users/:email` - Retrieve user information and access token
    * Parameters
      * `email` - The email address to retrieve details for
      * `api_key` - The authentication key passed in a HTTP Header
    * Returns [200 OK] - JSON payload
      * `email` - The provided email address
      * `access_token` - A one time generated token for using the API
      * `usage_limit` - Max number of uses within a 10 minute period
      * `usage_counter` - Current number of uses within the usage limit
      * `usage_reset_at` - DateTime of when the usage counter was reset
      * `total_usage` - Total number of uses since account creation
  * `PUT /users/:email` - Updates existing user data
    * Parameters
      * `email` - The email address for the account to update
      * `api_key` - The authentication key passed in a HTTP Header
      * `new_email` - The email address to change the account email to
    * Returns [200 OK] - JSON payload
      * `previous_email` - The previous email address on the account
      * `current_email` - The updated email address on the account
  * `DELETE /users/:email`
    * Parameters
      * `email` - The email address for the account to delete
      * `api_key` - The authentication key passed in a HTTP Header
    * Returns [204 No Content]
* `/` - Thumbifier actions
  * `GET /` - List all supported file mime-types
    * Returns [200 OK] - JSON array of supported mime-types
  * `GET /:type` - Check if given mime-type is supported
    * Parameters
      * `type` - The mime-type to check for support against
        The `/` in the mime-type is replaced with a `_`
        Example: `application/pdf` is entered as `application_pdf`
    * Returns [200 OK] - JSON encoded boolean denoting support
  * `POST /` - Create request to convert given data to jpg
    * Parameters
      * `access_token` - The generated token to authorize service call
      * `media_url` - The remote URL to the file to be converted
      * `callback_url` - The remote URL to POST the converted data to
      * `dimensions` - The output image size width/height dimensions
        provided as an [ImageMagick geometry parameter](http://www.imagemagick.org/script/command-line-processing.php#geometry)
      * `quality` - The compression quality for the output jpg (0-100)
      * `personal_reference` - [opt] A useful reference to the POSTed
        result to the original service call
      * `page` - [opt] The page of the input file to convert
      * `frame` - [opt] The frame of the video file to convert (hh:mm:ss)
    * Returns [201 Created] - JSON encoded response GUID

### Users

A user is required to access the Thumbifier Engine. A user account is
required to generate an access token for using the conversion process.

#### Creating a User

A user can be created by providing an email address to the user
creation route. The email address must be unique as it is used as the
unique identifier for the account.

To create a user, call the `POST /users` route passing the email
address as a form field to the route.

A `201 Created` HTTP response is returned after successfully creating
a user along with the following payload:

```
  {
    "email": "my@email.address",
    "api_key": "ed94e27a-76ce-46ee-9af5-f79aa34c5aa4"
  }
```

The email address is the address provided to the route and the
API key which is auto generated is used to make authenticated calls
to the user routes.

An email will also be sent to the provided email address containing
these details.

The API key is randomly generated and cannot be changed by the user.

#### Getting User Details

Obtaining the details of the user account will generate an access token
which is required to use the Thumbifier Engine conversion process.

The user details response will also contain useful information about
whether the usage limits have been exceeded for the given time period
and also how many total conversions the account has performed.

Accessing the user details requires authentication using the API key
associated with the account.

To retrieve the user details, call the `GET /users/:email` route with
the email address of the user to obtain the details for.

This route must be called server side as the API key is required and
this is a private key that must never be shared with the public.

##### Authentication

To authenticate the call to this route, the API key must be passed
as an Authorization Header as part of the HTTP request.

The format for the header is: `Authorization: Bearer <api-key>`

Example:

```
# api-key = 123456789

Header = Authorization: Bearer 123456789
```

##### Response Payload

Upon successfully calling the route, it returns the following payload:

```
{
  "email": "your@email.address",
  "access_token": "ed94e27a-76ce-46ee-9af5-f79aa34c5aa4",
  "usage_limit": "10",
  "usage_counter": "3",
  "usage_reset_at": "2015-07-22T08:37:14Z",
  "total_usage": "100"
}
```

###### Usage Information

The JSON payload provides useful information about the account, such as
the current restrictions on service usage and if the usage_counter has
exceeded the usage_limit then the service will be unavailable and a
`429 Too Many Requests` HTTP response will be returned.

The usage_counter will be reset after 10 minutes after the last
usage_reset_at DateTime and the service will be available to use for
the number of times denoted in the usage_limit for the next 10 minutes.

###### Access Token

The access token is a unique generated string that is used to call the
conversion route. A new access token is generated every time the
`GET /users:email` route is successfully called but they will expire
after 10 minutes from creation and no longer be able to be used to
authorize the conversion route.

The access token is deleted after first use so a new one has to be
created for every call to the conversion route.

The access token can be embedded in client side code (e.g. JavaScript)
as it is temporary and can only be used once so the public exposure of
the access token does not pose a security risk to the account.

#### Updating User Details

To update a user's email address call the `PUT /users/:email` route
with the email address of the user to update as part of the route URL
and passing the new_email as a form field to the route.

This route must be called server side as the API key is required and
this is a private key that must never be shared with the public.

To authenticate the call to this route, the API key must be passed
as an Authorization Header as part of the HTTP request.

See [Authentication](#authentication) for more details.

A `200 OK` HTTP response is returned after successfully updating a user
along with the following payload:

```
  {
    "previous_email": "old@email.address",
    "current_email": "new@email.address"
  }
```

#### Deleting a User

To delete a user account call the `DELETE /users/:email` route with
the email address of the user to delete.

This route must be called server side as the API key is required and
this is a private key that must never be shared with the public.

To authenticate the call to this route, the API key must be passed
as an Authorization Header as part of the HTTP request.

See [Authentication](#authentication) for more details.

A `204 No Content` HTTP response is returned after successfully
deleting a user.

### Thumbifier

The Thumbifier Engine is the core of the product and is responsible for
taking a remote URL for a supported mime-type and converting it to a
jpg and then POSTing a base64 encoded representation of the output jpg
to a given remote callback URL for consumption by an external system.

Accessing the conversion route requires an access token, which can be
obtained by creating a user account and requesting the user's details,
which will return an access token for that user account to use.

#### Supported Mime-Types

Many file mime-types are supported by the Thumbifier Engine and there
are two ways of determining if a file mime-type is supported.

##### Listing Supported Mime-Types

To list the current supported file mime-types call the `GET /` route.

A `200 OK` HTTP response will be returned with a JSON array containing
a list of the supported mime-types.

Example:

```
[
  "image/gif",
  "image/png",
  "image/bmp",
  "image/x-bmp"
]
```

##### Checking Support for Specific Mime-Type

To check if a specific file mime-type is supported call the
`GET /:type` route when the mime-type to check support for.

A `200 OK` HTTP response will be returned with a response body of:

* `true` - The given mime-type is supported
* `false` - The given mime-type is not supported

#### Converting

##### Conversion Request

To convert a supported file to a newly resized jpg call the `POST /`
route passing the following form fields to the route:

* access_token [_required_]
  * Generated on a per user basis by calling the [User Details](#getting-user-details) route.
    The access token expires after it is used so a new one is required
    per request. If an invalid access token is provided then the
    request will fail.
* media_url [_required_]
  * A publically accessible web URL that points to the file to be
    converted. The Thumbifier Engine will attempt to download this
    file for conversion. The remote file must not be larger than the
    `max_file_size` set in the [Configuration Fields](#configuration-fields).
    If no media URL is provided then the request will fail, if an
    invalid media URL is provided then the POSTed response will be an
    error response.
* callback_url [_required_]
  * A publically accessible web URL that points to a script that will
    accept a POST request from the Thumbifier Engine and digest the
    payload containing the converted jpg. If an invalid callback URL
    is provided then the conversion process will silently as there
    is no where to report the failure to.
* dimensions
  * The new size dimensions for the output jpg to be sized as specified
    as an [ImageMagick gemometry parameter](http://www.imagemagick.org/script/command-line-processing.php#geometry)
    The dimensions field will default to `100x100` if no value
    is provided.
* quality
  * The compression level to be used on the output jpg (between 0-100).
    The higher the quality number, the better the output quality but
    the lower the compression and therefore a larger output jpg
    file size will be created. The quality field will default to `72`
    if no value is provided.
* personal_reference
  * A specified identifier that can be provided at point of request
    and received at point of conversion response to make it easy to
    tie up the corresponding input file to the converted output file.
* page
  * Some input file formats may contain multiple pages, such as PDF or
    Office documents but the output jpg can only be a representation of
    a single page. The page option allows to specify the page from the
    input file to use in the conversion process. The page field will
    default to `1` if no value is provided.
* frame
  * Video input file formats require a specific frame to be supplied as
    this will be the frame from the video used to create the output jpg
    file. The frame field is supplied in this format `hh:mm:ss` so if
    the required frame is at 1 minute 32 seconds of the video file then
    the frame would be `00:01:32`. The frame field will default to `1`
    if no value is provided.

###### Request Failure

* `401 Unauthorized` - Invalid access token has been provided
* `429 Too Many Requests` - User's usage limit has been exceeded
* `400 Bad Request` - Invalid media URL has been provided

###### Request Success

A `201 Created` will be returned after successfully creating a
conversion request along with a JSON payload containing a unique
conversion reference known as the response_id.

Example:

```
  ed94e27a-76ce-46ee-9af5-f79aa34c5aa4
```

The response_id is also included in the payload POSTed to the
callback URL so it can be used to link the conversion request to the
output POSTed response.

##### Conversion Response

The Thumbifier Engine will queue up and attempt to convert the
given media URL if the conversion request was successful.

Once the Thumbifier Engine has processed the request it will POST
the results of the task to the provided callback URL.

This callback URL must be publically accessible and be able to process
a POST request containing a JSON payload in the following format:

```
{
  "status": "<error or ok>",
  "response_id": "ed94e27a-76ce-46ee-9af5-f79aa34c5aa4",
  "personal_reference": "my-personal-reference",
  "payload": "<results of conversion"
}
```

The status can either be `error` if something has gone wrong or `ok` if
the conversion process has been successful.

The response_id is the unique reference returned in the JSON payload
after a successful conversion request.

The personal_reference is the custom unique reference provivded in the
conversion request POST.

The payload will either contain the error message if something went
wrong or it will contain the base64 encoded converted jpg if the
conversion process has been successful.

###### Conversion Failure

The following responses can be POSTed if something went wrong:

* File not found
  * If the provided media URL is not valid and does not resolve then
    this error will be returned
  * Response Payload

    ```
    {
      "status": "error",
      "response_id": "ed94e27a-76ce-46ee-9af5-f79aa34c5aa4",
      "personal_reference": "my-personal-reference",
      "payload": "[001] File not found"
    }
    ```
* File limit exceeded
  * If the provided media URL is larger in file size than the allowed
    specified size in the `max_file_size` set in the
    [Configuration Fields](#configuration-fields) then this error will be returned.
  * Response Payload

    ```
    {
      "status": "error",
      "response_id": "ed94e27a-76ce-46ee-9af5-f79aa34c5aa4",
      "personal_reference": "my-personal-reference",
      "payload": "[002] File limit exceeded"
    }
    ```
* Mime-type not supported
  * If the provided media URL is a mime-type that isn't supported then
    this error will be returned.
  * Response Payload

    ```
    {
      "status": "error",
      "response_id": "ed94e27a-76ce-46ee-9af5-f79aa34c5aa4",
      "personal_reference": "my-personal-reference",
      "payload": "[003] mime-type <invalid-mime-type> not supported"
    }
    ```

###### Conversion Success

If everything went well and the conversion was successful then the
following payload will be POSTed to the provided callback URL:

```
{
  "status": "ok",
  "response_id": "ed94e27a-76ce-46ee-9af5-f79aa34c5aa4",
  "personal_reference": "my-personal-reference",
  "payload": "<base64 encoded jpg>"
}
```

The payload contains the base64 encoded output jpg the callback URL
could take this string, convert it back to a binary by base64 decoding
it and then saving the binary string to a file.

The conversion process is now complete.

## Running the Tests

There are a complete set of `ExUnit` tests that ensure the engine is
working as expected.

`mix test`

  > #### Note
  > The tests currently rely on an internet connection as they download
  > remote fixtures to test various file formats. As some of these
  > formats are large file size files, then the tests can take longer to
  > run on slower network connections.

## License

The Thumbifier source code is released under MIT License.

Check [LICENSE](https://github.com/sysdia/thumbifier/blob/master/LICENSE) file for more information.
