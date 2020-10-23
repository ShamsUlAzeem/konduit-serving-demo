# KONDUIT-SERVING 

# What is konduit-serving?
In a nutshell konduit-serving is a system for deploying machine learning models pipelines of nearly any type to production. 
It also allows embedding Python/Java code (pre/post processing, custom models). It primarily focuses on server and edge deployments using REST and gRPC endpoints.
Pipelines are deployed and defined by JSON/YAML or a command line interface.

# KEY CONCEPTS

## Pipeline 
In other words, a machine learning deployment (which contains models and optional code). The main logic of a pipeline is to have output of one step being sent as an input to the next step. Finally, output of the last step will be returned as an output to the user.
A typical pipeline may look like: 
- preprocess input -> pass it to the model -> output
```json
{ 
  "steps" : [ {
      "@type" : "IMAGE_TO_NDARRAY",
      "config" : {
        "height" : 28,
        "width" : 28,
        "dataType" : "FLOAT",
        "includeMinibatchDim" : true,
        "aspectRatioHandling" : "CENTER_CROP",
        "format" : "CHANNELS_FIRST",
        "channelLayout" : "GRAYSCALE",
        "normalization" : {
          "type" : "SCALE"
        },
        "listHandling" : "NONE"
      },
      "keys" : [ "image" ],
      "outputNames" : [ "Input3" ],
      "keepOtherValues" : true,
      "metadata" : false,
      "metadataKey" : "@ImageToNDArrayStepMetadata"
    }, {
      "@type" : "ONNX",
      "modelUri" : "mnist-8.onnx",
      "inputNames" : [ "Input3" ],
      "outputNames" : [ "Plus214_Output_0" ]
    } ] 
}
```
## Pipeline Step
A pipeline step is a single component of a whole machine learning pipeline. Configurations are done through individual pipeline steps.
```json
{
  "@type" : "ONNX",
  "modelUri" : "mnist-8.onnx",
  "inputNames" : [ "Input3" ],
  "outputNames" : [ "Plus214_Output_0" ]
}
```

## Configuration
JSON/YAML formatted data which defines a pipeline which could be model plus code and also contains server configuration as to what type of server to use and which host and post to use to run the server on.

### Example
Following is an example of a multi-step machine learning pipeline through konduit-serving:
```json
{
  "customEndpoints": [ "ai.konduit.OCREndPoints" ],
  "host" : "localhost",
  "port" : 0,
  "protocol" : "HTTP",
  "pipeline" : {
    "steps" : [ {
      "@type" : "IMAGE_TO_NDARRAY",
      "config" : {
        "height" : 28,
        "width" : 28,
        "dataType" : "FLOAT",
        "includeMinibatchDim" : true,
        "aspectRatioHandling" : "CENTER_CROP",
        "format" : "CHANNELS_FIRST",
        "channelLayout" : "GRAYSCALE",
        "normalization" : {
          "type" : "SCALE"
        },
        "listHandling" : "NONE"
      },
      "keys" : [ "image" ],
      "outputNames" : [ "Input3" ],
      "keepOtherValues" : true,
      "metadata" : false,
      "metadataKey" : "@ImageToNDArrayStepMetadata"
    }, {
      "@type" : "LOGGING",
      "logLevel" : "INFO",
      "log" : "KEYS_AND_VALUES"
    }, {
      "@type" : "ONNX",
      "modelUri" : "mnist-8.onnx",
      "inputNames" : [ "Input3" ],
      "outputNames" : [ "Plus214_Output_0" ]
    } ]
  }
}
```

The above configuration converts an image file sent to the server into a 28x28 n-dimensional array and logs the output to the console and then passes it to an ONNX model for final output.

## Supported model types
 
### ONNX
Open Neural Network Exchange is a multi-framework/platform interchange format for trained deep learning models.
 
#### Models Supported Via Onnx
- Pytorch
- MXNet 
- Others which can be converted into ONNX)

### PMML (Experimental) 
Predictive Model Markup Language also a platform interchange format for mostly all of the traditional ML models such as random forest.

#### Models supported via PMML 
- Scikit-learn 
- SparkML
- XGBoost 
- Others with supports PMML conversion

### Custom models
Through custom Python or Java code

### Other step types
- Logging (for logging the data that's passing through a pipeline)
```json
{
  "@type" : "LOGGING",
  "logLevel" : "INFO",
  "log" : "KEYS_AND_VALUES"
}
```
- Image_to_ndarray (for converting image data to desired n-dimensional array)
```json
 {
  "@type" : "IMAGE_TO_NDARRAY",
  "config" : {
    "height" : 100,
    "width" : 100,
    "dataType" : "FLOAT",
    "includeMinibatchDim" : true,
    "aspectRatioHandling" : "CENTER_CROP",
    "format" : "CHANNELS_FIRST",
    "channelLayout" : "RGB",
    "normalization" : {
      "type" : "SCALE"
    },
    "listHandling" : "NONE"
  },
  "keys" : [ "key1", "key2" ],
  "outputNames" : [ "output1", "output2" ],
  "keepOtherValues" : true,
  "metadata" : false,
  "metadataKey" : "@ImageToNDArrayStepMetadata"
}
```
- Camera (for taking input from a webcam)
- ShowImage (for showing image output)
- Video (for taking input from a video file)
- Others 

# How konduit-serving will be used?
- For users who want to host their machine learning model and code to production
- Packaging and distribution platform for apps (marketplace)
- Software + management for end-to-end products/solutions (verticals)

## Example applications:
- IoT/Edge
    - Smart home, smart factory, smart city etc
    - Telecommunication, facilities management
- On-prem ("on-premises" - running locally on a company's server)
    - Important for some industries - banking, healthcare etc (no private data in cloud)
- Cloud hosting of models (konduit-serving on cloud)

# KONDUIT SERVING CLI
A user friendly command line interface to interact with konduit-serving. Convenient to be used for launching deployments, predicting outputs, inspecting servers and stopping them.

The most used commands are:
- config (for creating boilerplate configurations)
```bash
- Saves 'dl4j -> logging' config in a 'config.json' file:
$ konduit config -p dl4j,logging -o config.json
```
- serve (for creating and running the server)
```bash
- Starts a server in the foreground with an id of 'inf_server' using
'config.json' as configuration file:
$ konduit serve -id inf_server -c config.json
```
- stop (for stopping the server)
```bash
- Stops the server with an id of 'inf_server':
$ konduit stop inf_server
```
- list (lists the current running servers)
```bash
- Lists all the running servers
$ konduit list
```
- logs (shows logs for a particular server)
```bash
- Outputs and tail the log file contents of server with an id of 'inf_server'
  from the last 10 lines:
$ konduit logs inf_server -l 10 -f
```
- inspect (for inspecting configuration of a particular server such as host port or number of steps)
```bash
- Queries the inference configuration of server with an id of 'inf_server'
  based on the given pattern and gives output similar to
  'localhost:45223-{<pipeline_details>}'. The curly brackets can be escaped.
$ konduit inspect inf_server -q {host}:{port}-\{{pipeline}\}
```
- pythonpaths (for finding out the installed python binaries in the current server)
```bash
- Lists all the installed and registered CONDA python binaries:
$ konduit pythonpaths list --type CONDA
```

# Support for custom REST Endpoints
Custom rest endpoints can be defined through Java code (which can be easily created through jupyter). The following parameters should be defined for a custom endpoint definition:
- consumes (such as application/json or multipart/form-data)
- produces (same as consumes but for the REST output)
- endpoint-name (such as /output)
- logic-code (could be anything that processes the data in a specific format)

## Example
Following is a useful example for a custom endpoint code
```java
package ai.konduit;

import ai.konduit.serving.endpoint.Endpoint;
import ai.konduit.serving.pipeline.api.data.Data;
import ai.konduit.serving.pipeline.api.data.Image;
import ai.konduit.serving.pipeline.api.pipeline.Pipeline;
import ai.konduit.serving.pipeline.api.pipeline.PipelineExecutor;
import io.vertx.core.Handler;
import io.vertx.core.http.HttpMethod;
import io.vertx.ext.web.RoutingContext;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.nd4j.linalg.factory.Nd4j;
import ai.konduit.serving.pipeline.api.data.NDArray;
import ai.konduit.serving.pipeline.util.ObjectMappers;

import ai.konduit.serving.pipeline.registry.NDArrayConverterRegistry;
import ai.konduit.serving.data.nd4j.format.ND4JConverters;
    
public class IrisEndPoint implements Endpoint {

    private PipelineExecutor pipelineExecutor;

    public IrisEndPoint(PipelineExecutor pipelineExecutor) { 
        this.pipelineExecutor = pipelineExecutor; 
        NDArrayConverterRegistry.addConverter(new ND4JConverters.Nd4jToSerializedConverter()); 
        NDArrayConverterRegistry.addConverter(new ND4JConverters.SerializedToNd4jArrConverter()); }

    public HttpMethod type() { return HttpMethod.POST; }

    public String path() { return "/infer"; }

    public List<String> consumes() { return Arrays.asList("application/json"); }

    public List<String> produces() { return Arrays.asList("application/json"); }

    @Override
    public Handler<RoutingContext> handler() {
        return handler -> {
            handler.vertx().executeBlocking(taskHandler -> {
                Data data = Data.empty();
                
                try {
                    data.put("input", NDArray.create(Nd4j.create(new float[] {
                        handler.getBodyAsJson().getFloat("sepal_length"),
                        handler.getBodyAsJson().getFloat("sepal_width"),
                        handler.getBodyAsJson().getFloat("petal_length"),
                        handler.getBodyAsJson().getFloat("petal_width")}, new int[] { 1, 4 })));
                } catch (Exception e) {
                    e.printStackTrace();
                }

                Data exec = pipelineExecutor.exec(data);
                
                handler.response().end(ObjectMappers.toJson(exec.getNDArray("output").getAs(float[].class)));
                taskHandler.complete();
            },resultHandler -> {
                if(resultHandler.failed()) {
                    if(resultHandler.cause() != null)
                        if(handler.vertx().exceptionHandler() != null)
                            handler.vertx().exceptionHandler().handle(resultHandler.cause());
                        else {
                            resultHandler.cause().printStackTrace();
                        }
                    else {
                        System.err.println("Failed to process classification endpoint async task. Unknown cause.");
                    }
                }
            });

        };
    }
}
```

and (just a wrapper for the list of created endpoints)

```java
package ai.konduit;

import ai.konduit.serving.endpoint.Endpoint;
import ai.konduit.serving.endpoint.HttpEndpoints;
import ai.konduit.serving.pipeline.api.pipeline.Pipeline;
import ai.konduit.serving.pipeline.api.pipeline.PipelineExecutor;

import java.util.Arrays;
import java.util.List;

public class IrisEndPoints implements HttpEndpoints {

    @Override
    public List<Endpoint> endpoints(Pipeline pipeline, PipelineExecutor pipelineExecutor) {
        return Arrays.asList(new IrisEndPoint(pipelineExecutor));
    }
}
```

This can be set inside the configuration through the key of `custom_endpoints` as: `custom_endpoints: [ "ai.konduit.IrisEndPoints" ]` 
For resolving the new code, the compiled code can be sent as an extra classpaths to the konduit-serving server.

# Packaging 
We can make custom builds through the konduit-serving `build` cli command. Example of the custom builds are:
- HTTP (REST) server on x86 Windows (CPU), packaged as a stand-alone .exe
- HTTP and GRPC server on CUDA 10.2 + Linux, packaged as a docker image

Build command is useful for creating minimal packages that can be distributed for different purposes. 

The typical format for running the `build` command would look like this: 
`konduit build` 

```
konduit build --arch x86,armhf,ppc64le --modules onnx,python,tensorflow,dl4j --serverTypes http,grpc --config jar.outputdir=output,jar.name=konduit-linux.jar --os linux --deploymentType UBERJAR
```

## Upcoming Support
```
konduit build --arch CPU,aurora --modules onnx,python,tensorflow,dl4j --serverTypes http,grpc --config jar.outputdir=output,jar.name=konduit-aurora.jar --os linux --deploymentType UBERJAR
```