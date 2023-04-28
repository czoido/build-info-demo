# Using Build Info with Conan

## Conan extensions

The custom commands to manage the Build Info currently are in the conan-extensions repo,
it's a work in progress (completely experimental at the moment).

```
git clone https://github.com/conan-io/conan-extensions.git
cd conan-extensions
conan config install .
```

## Demo

To show basic usage of Build Info.

We have two repositories: develop and production

We will create a BuildInfo with build_name=<config>_build build_number=1

mypkg depending on liba, liba already in Artifactory, we are only building mypkg.

Two paralell jobs creating Release and Debug, each one with a BuildInfo, then aggregate
them

![Alt build](diagram.png?raw=true)

```
conan remove "*" -r=develop -c
conan remove "liba*" -c

conan create liba -s build_type=Release
conan create liba -s build_type=Debug

# we upload to Artifactory, we will pick that from there

conan upload "liba*" -r=develop -c

# Release CI JOB

# build mypkg Release, will pick liba from Artifactory

conan create mypkg --format=json -s build_type=Release --build="mypkg*" > create_release.json

conan upload "mypkg*" -r=develop -c

# create the Build Info for Release and set the properties to the Artifacts in Artifactory

conan art:build-info create create_release.json release_build 1 develop --with-dependencies > release_build.json

conan art:property build-info-add release_build.json http://localhost:8081/artifactory --user=admin --password=password

# Upload the Build Info

conan art:build-info upload release_build.json http://localhost:8081/artifactory --user=admin --password=password

# Debug CI JOB

# build mypkg Debug, will pick liba from Artifactory

conan create mypkg --format=json -s build_type=Debug --build="mypkg*" > create_debug.json

conan upload "mypkg*" -r=develop -c

# create the Build Info for Debug and set the properties to the Artifacts in Artifactory

conan art:build-info create create_debug.json debug_build 1 develop --with-dependencies > debug_build.json

conan art:property build-info-add debug_build.json http://localhost:8081/artifactory --user=admin --password=password

# Upload the Build Info

conan art:build-info upload debug_build.json http://localhost:8081/artifactory --user=admin --password=password

# parent CI job

conan art:build-info append aggregated_build 1 --build-info=release_build.json --build-info=debug_build.json > aggregated_build.json
conan art:build-info upload aggregated_build.json http://localhost:8081/artifactory --user=admin --password=password
conan art:property build-info-add aggregated_build.json http://localhost:8081/artifactory --user=admin --password=password

# Still in Beta

conan art:build-info create-bundle aggregated_build.json develop aggregated_bundle 1.0 http://localhost:8081/artifactory test_key_pair --user=admin --password=password
```


## Future improvements

https://github.com/conan-io/conan-extensions/issues

- Set the artifact properties when publishing the BuildInfo (#19)
- art:build info append from BI’s in Artifactory instead of local (#17)
- Support Artifactory projects (#29)
- Add promotion command with release bundles
