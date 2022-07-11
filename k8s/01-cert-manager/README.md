# Cert Manager
* Source: https://github.com/jetstack/cert-manager/tree/v1.5.3/deploy/manifests

To generate the k8s manifest, you should install Bazel first
## Ubuntu 
One time setup
```
sudo apt install apt-transport-https curl gnupg
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
```

Installation

```
sudo apt update && sudo apt install bazel
```

Ref: https://docs.bazel.build/versions/main/install-ubuntu.html

## MacOS
One time setup
```
/bin/bash -c "$(curl -fsSL \
https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Installation
```
brew install bazel
```
### Generate k8s manifest
Clone cert-manager repo to local machine 
```
git clone git@github.com:jetstack/cert-manager.git
```

Checkout to the tag version you want to generate the manifest
```
cd cert-manager
git checkout v1.5.3
```

Then run this command 
```
bazel build //deploy/manifests:cert-manager.yaml
```

This will generate the static deployment manifests at `bazel-bin/deploy/manifests/cert-manager.yaml`
