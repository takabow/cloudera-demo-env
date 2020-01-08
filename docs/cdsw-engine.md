# Notes on building a custom CDSW engine image to enable GPU

## Dockerfile

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
No change from a sample of Document

# Docker commands
```
sudo docker build --no-cache --network host -t yoshiyukikono/cdsw-cuda:8  . -f cuda.Dockerfile
sudo docker login -u yoshiyukikono
sudo docker push yoshiyukikono/cdsw-cuda:8
```

# Compatibility
## TensorFlow

Instance Post Create Shell: `instance-postcreate-cdsw1_6-gpu-tf.sh`

https://www.tensorflow.org/install/source#linux

|Version|Python version| cuDNN| CUDA |
|---|---|---|---|
|tensorflow_gpu-1.**14.0**|2.7, 3.3-3.7|7.4|10.0|

**Note:** 
When using tensorflow_gpu-1.13.1, I faced the following error.
```
ImportError: libcublas.so.10.0
```
There was no `libcublas.so.10.0` under `/usr/local/cuda/lib64` but `libcudart.so.10.0`.
Then, when I tried to install the upper version, I succeeded the test mentioned below.

## PyTorch

Instance Post Create Shell: `instance-postcreate-cdsw1_6-gpu-pytorch.sh`

https://pytorch.org/

|Version|Python version| cuDNN| CUDA |
|---|---|---|---|
|PyTorch1.3|2.7, 3.5-3.7|-|10.1|

## Driver
https://www.nvidia.com/Download/index.aspx?lang=en-us

|AWS Instance|NVIDIA Product|CUDA Toolkit| Driver Version | Link | for | 
|---|---|---|---|---|---|
|p2(.8xlarge)|K80|10.0|410.129| http://us.download.nvidia.com/tesla/410.129/NVIDIA-Linux-x86_64-410.129-diagnostic.run| TensorFlow |
|p2(.8xlarge)|K80|10.1|418.116.00| hhttp://us.download.nvidia.com/tesla/418.116.00/NVIDIA-Linux-x86_64-418.116.00.run| PyTorch |
## Test

#### PyTorch
```
!pip3 install torch
from torch import cuda
assert cuda.is_available()
assert cuda.device_count() > 0
print(cuda.get_device_name(cuda.current_device()))
```
```
Tesla K80
```

GPU-Util tested with [SocialMediaSentimentAnalysis](https://github.com/YoshiyukiKono/SocialMediaSentimentAnalysis)

```
watch nvidia-smi
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

#### TensorFlow
https://github.com/tensorflow/tensorflow/issues/30748

>I met the same problem on ubuntu 18.04, cuda 10.1 and Tensorflow 1.14.0. However, I uninstalled the pip version tensorflow using pip uninstall tensorflow-gpu and then use conda install -c anaconda tensorflow-gpu to install conda version, and it works for me. You can have a try. @AmitMY
```
!conda install tensorflow-gpu==1.14.0
```
```
#!pip3 install tensorflow-gpu==1.13.1
!pip3 install tensorflow-gpu==1.14.0
from tensorflow.python.client import device_lib
assert 'GPU' in str(device_lib.list_local_devices())
device_lib.list_local_devices()
```
With pip3-installed-tensorflow-gpu and driver settting for PyTorch/TF device was not identified but `XLA_GPU`
```
[name: "/device:CPU:0"
 device_type: "CPU"
 memory_limit: 268435456
 locality {
 }
 incarnation: 4236483043395514120, name: "/device:XLA_GPU:0"
 device_type: "XLA_GPU"
 memory_limit: 17179869184
 locality {
 }
 incarnation: 16029027632270183099
 physical_device_desc: "device: XLA_GPU device", name: "/device:XLA_CPU:0"
 device_type: "XLA_CPU"
 memory_limit: 17179869184
 locality {
 }
 incarnation: 2554181575927509532
 physical_device_desc: "device: XLA_CPU device"]
```
```
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


