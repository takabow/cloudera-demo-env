# Notes on building a custom CDSW engine image to enable GPU

## Driver
https://www.nvidia.com/Download/index.aspx?lang=en-us

|AWS Instance|NVIDIA Product|CUDA Toolkit| Driver Version | File |
|---|---|---|---|---|
|p2(.8xlarge)|K80|10.1|418.116.00| [NVIDIA-Linux-x86_64-418.116.00.run](http://us.download.nvidia.com/tesla/418.116.00/NVIDIA-Linux-x86_64-418.116.00.run)|

## Library
### TensorFlow

https://www.tensorflow.org/install/source#linux

|Version|Python version| cuDNN| CUDA |
|---|---|---|---|
|tensorflow-2.1.0|2.7, 3.3-3.7|7.6|10.1|
|tensorflow-1.15.0|2.7, 3.3-3.7|7.4|10.0|

### PyTorch

https://pytorch.org/

|Version|Python version| cuDNN| CUDA |
|---|---|---|---|
|PyTorch1.3|2.7, 3.5-3.7|-|10.1|

## Environment Setup

### OS Configuration

Instance Post Create Shell: `instance-postcreate-cdsw1_6-gpu.sh`

### Docker

#### Docker File
No change from the sample of [CDSW Document](https://docs.cloudera.com/documentation/data-science-workbench/1-6-x/topics/cdsw_gpu.html#custom_cuda_engine)

[cuda.Dockerfile]
```
FROM  docker.repository.cloudera.com/cdsw/engine:8

RUN NVIDIA_GPGKEY_SUM=d1be581509378368edeec8c1eb2958702feedf3bc3d17011adbf24efacce4ab5 && \
    NVIDIA_GPGKEY_FPR=ae09fe4bbd223a84b2ccfce3f60f4b3d7fa2af80 && \
    apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub && \
    apt-key adv --export --no-emit-version -a $NVIDIA_GPGKEY_FPR | tail -n +5 > cudasign.pub && \
    echo "$NVIDIA_GPGKEY_SUM  cudasign.pub" | sha256sum -c --strict - && rm cudasign.pub && \
    echo "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/cuda.list

ENV CUDA_VERSION 10.0.130
LABEL com.nvidia.cuda.version="${CUDA_VERSION}"

ENV CUDA_PKG_VERSION 10-0=$CUDA_VERSION-1
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION && \
    ln -s cuda-10.0 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*

RUN echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/cuda.conf && \
    ldconfig

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

ENV CUDNN_VERSION 7.5.1.10
LABEL com.nvidia.cudnn.version="${CUDNN_VERSION}"

RUN apt-get update && apt-get install -y --no-install-recommends \
            libcudnn7=$CUDNN_VERSION-1+cuda10.0 && \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*
```

#### Docker commands
```bash
$ sudo docker build --no-cache --network host -t yoshiyukikono/cdsw-cuda:8  . -f cuda.Dockerfile
$ sudo docker login -u yoshiyukikono
$ sudo docker push yoshiyukikono/cdsw-cuda:8
```

## Test: PyTorch

### Install

#### PyTorch
```bash
$ pip3 install torch
```

### Check

#### Availability
```python
from torch import cuda
assert cuda.is_available()
assert cuda.device_count() > 0
print(cuda.get_device_name(cuda.current_device()))
```
```bash
Tesla K80
```
#### GPU Usage
Tested using [SocialMediaSentimentAnalysis](https://github.com/YoshiyukiKono/SocialMediaSentimentAnalysis)

```bash
$ watch nvidia-smi
```
```bash
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 418.116.00   Driver Version: 418.116.00   CUDA Version: 10.1     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla K80           On   | 00000000:00:19.0 Off |                    0 |
| N/A   66C    P0   135W / 149W |   1160MiB / 11441MiB |     92%      Default |
+-------------------------------+----------------------+----------------------+
```

## Test: TensorFlow 1.15
### Install

##### Tensorflow
```bash
$ pip3 install tensorflow==1.15
```

##### Error message without cudatoolkit
```bash
2020-01-16 08:00:37.194299: W tensorflow/stream_executor/platform/default/dso_loader.cc:55] Could not load dynamic library 'libcublas.so.10.0'; dlerror: libcublas.so.10.0: cannot open shared object file: No such file or directory; LD_LIBRARY_PATH: /home/cdsw/.conda/pkgs/cudatoolkit-10.1.243-h6bb024c_0/lib/:/usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/nvidia/lib:/usr/local/cuda/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/opt/cloudera/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554/lib/hadoop/lib/native
```

##### Cuda Toolkit

**Referrence:**
https://github.com/tensorflow/tensorflow/issues/26182

> I just found this out myself, not sure if it's common knowledge, but got around this by doing

>> conda install cudatoolkit

>> conda install cudnn

> I have cuda-10.1 installed on my box, this installed a local conda-only cuda-10.0. Obviously this is to just keep tensorflow working while waiting for better support.

Install cudatoolkit but do not necessarily install cudnn.

```bash
$ conda install cudatoolkit==10.0.130
$ conda list | grep cud
cudatoolkit               10.0.130                      0  
```

```bash
$ find / -name libcublas.so.10.0
...
/home/cdsw/.conda/envs/python3.6/lib/libcublas.so.10.0
/home/cdsw/.conda/pkgs/cudatoolkit-10.0.130-0/lib/libcublas.so.10.0
...
```

(Project) Settings -> Engine -> Environment Variables
- Name: `LD_LIBRARY_PATH`
- Value: `.conda/envs/python3.6/lib/:$LD_LIBRARY_PATH`




### Check
#### Availability

##### Test Code
```python
from tensorflow.python.client import device_lib
device_lib.list_local_devices()
```
When you do not restart the workbench, you would face the following error.
After you stop and start the workbench, you would not meet the same error again.
```bash
RuntimeError: module compiled against API version 0xc but this version of numpy is 0xb
RuntimeError                              Traceback (most recent call last)
RuntimeError: module compiled against API version 0xc but this version of numpy is 0xb
ImportError: numpy.core.multiarray failed to import
ImportError                               Traceback (most recent call last)
ImportError: numpy.core.multiarray failed to import
ImportError: numpy.core.umath failed to import
ImportError                               Traceback (most recent call last)
ImportError: numpy.core.umath failed to import
ImportError: numpy.core.umath failed to import
ImportError                               Traceback (most recent call last)
ImportError: numpy.core.umath failed to import
Engine exited with status 134.
```

```bash
2020-01-10 01:25:59.748592: I tensorflow/core/platform/cpu_feature_guard.cc:142] Your CPU supports instructions that this TensorFlow binary was not compiled to use: AVX2 FMA
2020-01-10 01:25:59.756874: I tensorflow/core/platform/profile_utils/cpu_utils.cc:94] CPU Frequency: 2300060000 Hz
2020-01-10 01:25:59.758703: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x5782050 initialized for platform Host (this does not guarantee that XLA will be used). Devices:
2020-01-10 01:25:59.758732: I tensorflow/compiler/xla/service/service.cc:176]   StreamExecutor device (0): Host, Default Version
2020-01-10 01:25:59.761661: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcuda.so.1
2020-01-10 01:25:59.944954: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:983] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
2020-01-10 01:25:59.946237: I tensorflow/compiler/xla/service/service.cc:168] XLA service 0x5837530 initialized for platform CUDA (this does not guarantee that XLA will be used). Devices:
2020-01-10 01:25:59.946269: I tensorflow/compiler/xla/service/service.cc:176]   StreamExecutor device (0): Tesla K80, Compute Capability 3.7
2020-01-10 01:25:59.946483: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:983] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
2020-01-10 01:25:59.947678: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1618] Found device 0 with properties: 
name: Tesla K80 major: 3 minor: 7 memoryClockRate(GHz): 0.8235
pciBusID: 0000:00:1d.0
2020-01-10 01:25:59.952930: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudart.so.10.0
2020-01-10 01:25:59.990067: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcublas.so.10.0
2020-01-10 01:26:00.029653: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcufft.so.10.0
2020-01-10 01:26:00.111775: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcurand.so.10.0
2020-01-10 01:26:00.159927: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcusolver.so.10.0
2020-01-10 01:26:00.188648: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcusparse.so.10.0
[name: "/device:CPU:0"
 device_type: "CPU"
 memory_limit: 268435456
 locality {
 }
 incarnation: 2402032456903103669, name: "/device:XLA_CPU:0"
 device_type: "XLA_CPU"
 memory_limit: 17179869184
 locality {
 }
 incarnation: 2172456631417959673
 physical_device_desc: "device: XLA_CPU device", name: "/device:XLA_GPU:0"
 device_type: "XLA_GPU"
 memory_limit: 17179869184
 locality {
 }
 incarnation: 17231891383177235203
 physical_device_desc: "device: XLA_GPU device", name: "/device:GPU:0"
 device_type: "GPU"
 memory_limit: 11326753997
 locality {
   bus_id: 1
   links {
   }
 }
 incarnation: 12765325159538489270
 physical_device_desc: "device: 0, name: Tesla K80, pci bus id: 0000:00:1d.0, compute capability: 3.7"]2020-01-10 01:26:00.325691: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudnn.so.7
2020-01-10 01:26:00.325835: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:983] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
2020-01-10 01:26:00.327116: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:983] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
2020-01-10 01:26:00.328267: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1746] Adding visible gpu devices: 0
2020-01-10 01:26:00.328324: I tensorflow/stream_executor/platform/default/dso_loader.cc:44] Successfully opened dynamic library libcudart.so.10.0
2020-01-10 01:26:00.331126: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1159] Device interconnect StreamExecutor with strength 1 edge matrix:
2020-01-10 01:26:00.331158: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1165]      0 
2020-01-10 01:26:00.331169: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1178] 0:   N 
2020-01-10 01:26:00.331465: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:983] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
2020-01-10 01:26:00.332683: I tensorflow/stream_executor/cuda/cuda_gpu_executor.cc:983] successful NUMA node read from SysFS had negative value (-1), but there must be at least one NUMA node, so returning NUMA node zero
2020-01-10 01:26:00.333878: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1304] Created TensorFlow device (/device:GPU:0 with 10802 MB memory) -> physical GPU (device: 0, name: Tesla K80, pci bus id: 0000:00:1d.0, compute capability: 3.7)
```
#### GPU Usage

##### Test Code
```python
import tensorflow as tf
mnist = tf.keras.datasets.mnist

(x_train, y_train),(x_test, y_test) = mnist.load_data()
x_train, x_test = x_train / 255.0, x_test / 255.0

model = tf.keras.models.Sequential([
  tf.keras.layers.Flatten(),
  tf.keras.layers.Dense(512, activation=tf.nn.relu),
  tf.keras.layers.Dropout(0.2),
  tf.keras.layers.Dense(10, activation=tf.nn.softmax)
])
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

model.fit(x_train, y_train, epochs=5)
model.evaluate(x_test, y_test)
```

##### Command
```bash
$ watch nvidia-smi
```

###### Terminal image opened from the workbench of CDSW
During the time when GPU is being used you will find the percentage of Volatile GPU-Util is increaded.
**Note:** GPU Processes will not apprear when using the terminal opened within CDSW(Docker) but it will appeare if you do the same on the OS.
```bash
Every 2.0s: nvidia-smi                                      Fri Jan 10 02:36:36 2020
Fri Jan 10 02:36:36 2020
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 410.129      Driver Version: 410.129      CUDA Version: 10.0     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla K80           Off  | 00000000:00:17.0 Off |                    0 |
| N/A   40C    P0    60W / 149W |  10960MiB / 11441MiB |     37%      Default |
+-------------------------------+----------------------+----------------------+
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
+-----------------------------------------------------------------------------+
```

##  Test: TensorFlow 2.1
### Install

#### Tensorflow
```bash
$ pip3 install tensorflow==2.1
```
#####  Error message without cudatoolkit
The version of required libraries is 10.1
```bash
2020-01-16 08:32:59.428528: W tensorflow/stream_executor/platform/default/dso_loader.cc:55] Could not load dynamic library 'libcudart.so.10.1'; dlerror: libcudart.so.10.1: cannot open shared object file: No such file or directory; LD_LIBRARY_PATH: /usr/local/nvidia/lib64:/usr/local/cuda/lib64:/usr/local/nvidia/lib:/usr/local/cuda/lib:/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/opt/cloudera/parcels/CDH-6.3.2-1.cdh6.3.2.p0.1605554/lib/hadoop/lib/native
```
#### cudatoolkit
```bash
$ conda install cudatoolkit==10.1.243
$ conda list
# packages in environment at /home/cdsw/.conda/envs/python3.6:
#
cudatoolkit               10.1.243             h6bb024c_0
$ find / -name libcublas.so.10
...
/home/cdsw/.conda/envs/python3.6/lib/libcublas.so.10
/home/cdsw/.conda/pkgs/cudatoolkit-10.1.243-h6bb024c_0/lib/libcublas.so.10
...
```
### Check

#### Availability
```python
from tensorflow.python.client import device_lib
device_lib.list_local_devices()
```
```bash
2020-01-16 08:42:18.191722: I tensorflow/core/common_runtime/gpu/gpu_device.cc:1241] Created TensorFlow device (/device:GPU:0 with 10805 MB memory) -> physical GPU (device: 0, name: Tesla K80, pci bus id: 0000:00:1b.0, compute capability: 3.7)
```
