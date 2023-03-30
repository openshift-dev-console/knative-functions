# Function project

Welcome to your new Function project!

This sample project contains a single function based on Spring Cloud Function: `echo.EchoFunction`, which returns an echo of the data passed via CloudEvents.

## Local execution

Make sure that `Java 17 SDK` is installed since Spring Boot 3.0 requires Java 17.

To start server locally run `./mvnw spring-boot:run`.
The command starts http server and automatically watches for changes of source code.
If source code changes the change will be propagated to running server. It also opens debugging port `5005`
so a debugger can be attached if needed.

To run tests locally run `./mvnw test`.

## The `func` CLI

It's recommended to set `FUNC_REGISTRY` environment variable.

```shell script
# replace ~/.bashrc by your shell rc file
# replace docker.io/johndoe with your registry
export FUNC_REGISTRY=docker.io/johndoe
echo "export FUNC_REGISTRY=docker.io/johndoe" >> ~/.bashrc
```

### Building

This command builds an OCI image for the function. By default, this will build a JVM image.

```shell script
func build -v                  # build image
```

**Note**: If you want to enable the native build, you need to edit the `func.yaml` file and
set the `BP_NATIVE_IMAGE` BuilderEnv variable to true:

```yaml
buildEnvs:
  - name: BP_NATIVE_IMAGE
    value: "true"
```

**Note**: If you have issues with the [Spring AOT](https://docs.spring.io/spring-framework/docs/current/reference/html/core.html#core.aot) processing in your build, you can turn this off by editing the `func.yaml` file and remove the `-Pnative` profile from the `BP_MAVEN_BUILD_ARGUMENTS` BuilderEnv variable:

```yaml
buildEnvs:
  - name: BP_MAVEN_BUILD_ARGUMENTS
    value: -Pnative -Dmaven.test.skip=true --no-transfer-progress package
```

> Removing the `-Pnative` profile means that you no longer will be able to build as a native image.

### Running

This command runs the func locally in a container
using the image created above.

```shell script
func run
```

### Deploying

This command will build and deploy the function into cluster.

```shell script
func deploy -v # also triggers build
```

### For ARM processor based systems

Building Spring Boot apps with Paketo Buildpacks on an ARM processor based system, like an Apple Macbook with an M1 or M2 chip, doesn't work well at the moment.
To work around this you can build the image on your local system using [Jib](https://github.com/GoogleContainerTools/jib).
Then, you would deploy the Jib generated image.

```
./mvnw compile com.google.cloud.tools:jib-maven-plugin:3.3.1:dockerBuild -Dimage=$FUNC_REGISTRY/echo
func deploy --build=false --image=$FUNC_REGISTRY/echo
```

## Function invocation

Spring Cloud Functions allows you to route CloudEvents to specific functions using the `Ce-Type` attribute.
For this example, the CloudEvent is routed to the `echo` function. You can define multiple functions inside this project
and then use the `Ce-Type` attribute to route different CloudEvents to different Functions.
Check the `src/main/resources/application.properties` file for the `functionRouter` configurations.
Notice that you can also use `path-based` routing and send the any event type by specifying the function path,
for this example: "$URL/echo".

For the examples below, please be sure to set the `URL` variable to the route of your function.

You get the route by following command.

```shell script
func info
```

Note the value of **Routes:** from the output, set `$URL` to its value.

__TIP__:

If you use `kn` then you can set the url by:

```shell script
# kn service describe <function name> and show route url
export URL=$(kn service describe $(basename $PWD) -ourl)
```

### func

Using `func invoke` command with CloudEvents `Ce-Type` routing:

```shell script
func invoke --type "echo"
```

Using Path-Based routing:

```shell script
func invoke --target "$URL/echo"
```

### cURL

Using CloudEvents `Ce-Type` routing:

```shell script
curl -v "$URL/" \
  -H "Content-Type:application/json" \
  -H "Ce-Id:1" \
  -H "Ce-Subject:Echo" \
  -H "Ce-Source:cloud-event-example" \
  -H "Ce-Type:echo" \
  -H "Ce-Specversion:1.0" \
  -w "\n" \
  -d "hello"
```

Using Path-Based routing:

```shell script
curl -v "$URL/echo" \
  -H "Content-Type:application/json" \
  -H "Ce-Id:1" \
  -H "Ce-Subject:Echo" \
  -H "Ce-Source:cloud-event-example" \
  -H "Ce-Type:echo" \
  -H "Ce-Specversion:1.0" \
  -w "\n" \
  -d "hello"
```

### HTTPie

Using CloudEvents `Ce-Type` routing:
```shell script
echo hello | http -v "$URL/" \
  Content-Type:application/json \
  Ce-Id:1 \
  Ce-Subject:Echo \
  Ce-Source:cloud-event-example \
  Ce-Type:MyEvent \
  Ce-Specversion:1.0
```

Using Path-Based routing:
```shell script
echo hello | http -v "$URL/echo" \
  Content-Type:application/json \
  Ce-Id:1 \
  Ce-Subject:Echo \
  Ce-Source:cloud-event-example \
  Ce-Type:MyEvent \
  Ce-Specversion:1.0
```

## Cleanup

To remove the deployed function from your cluster, run:

```shell
func delete
```
