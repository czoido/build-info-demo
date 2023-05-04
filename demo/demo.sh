# Begin with an empty Arti repo

# We will create a BuildInfo with build_name=<config>_build build_number=1

# Two paralell jobs creating Release and Debug, each one with a BuildInfo, then aggregate them

conan remove "*" -r=develop -c
conan remove "liba*" -c
conan remove "mypkg*" -c

conan create liba -s build_type=Release --build="liba*"
conan create liba -s build_type=Debug --build="liba*"

# we upload to Artifactory, we will pick that from there

conan upload "liba*" -r=develop -c

conan remove "liba*" -c

##################
# Release CI JOB #
##################

# build mypkg Release, will pick liba from Artifactory

conan create mypkg --format=json -s build_type=Release --build="mypkg*" -r=develop > create_release.json

conan upload "mypkg*" -r=develop -c

# create the Build Info for Release

conan art:build-info create create_release.json release_build 1 develop --url=http://localhost:8081/artifactory --user=admin --password=password --with-dependencies > release_build.json

# Upload the Build Info

conan art:build-info upload release_build.json http://localhost:8081/artifactory --user=admin --password=password

################
# Debug CI JOB #
################

# build mypkg Debug, will pick liba from Artifactory

conan create mypkg --format=json -s build_type=Debug --build="mypkg*" -r=develop  > create_debug.json

conan upload "mypkg*" -r=develop -c

# create the Build Info for Debug

conan art:build-info create create_debug.json debug_build 1 develop --url=http://localhost:8081/artifactory --user=admin --password=password --with-dependencies > debug_build.json

# Upload the Build Info

conan art:build-info upload debug_build.json http://localhost:8081/artifactory --user=admin --password=password

#################
# parent CI job #
#################

conan art:build-info append aggregated_build 1 http://localhost:8081/artifactory --build-info=debug_build,1 --build-info=release_build,1 --user=admin --password=password > aggregated_build.json
conan art:build-info upload aggregated_build.json http://localhost:8081/artifactory --user=admin --password=password

#################
# Still in Beta #
#################

conan art:build-info create-bundle aggregated_build.json develop aggregated_bundle 1.0 http://localhost:8081/artifactory test_key_pair --user=admin --password=password
