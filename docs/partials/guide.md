## Tools Included

This container includes namely two different tools used for testing Docker containers. 

1. **[ContainerStructureTest](https://github.com/GoogleContainerTools/container-structure-test)** is a framework used to validate the structure of a container image. It can do things like check to make sure commands exit with a certain code, ensure metadata is correct, verify the contents of a file system, and ensure the output of commands match a certain RegEx pattern.
2. **[GitLab Runner](https://docs.gitlab.com/runner/)** is used to emulate the behavior of Docker containers in GitLab CI environments.
