This folder contains the Terraform configuration for our Buildkite setup.

These are based on the [Elastic CI Stack for AWS][elastic_ci].

To update to a new version of the Elastic CI Stack:

1.  Download the `aws-stack.yml` CloudFormation stack definition from the [desired release][release].
2.  Save it in this folder as `buildkite-{version}.yml`.
3.  Update the `elastic_ci_stack_version` parameter in our pipeline definitions in `main.tf`.

This mechanism allows you to run different stacks with different versions of the Elastic CI Stack.
This gives you a lot of flexibility when upgrading, e.g. you can roll out changes incrementally, or even create an entire new stack with to test a new version before rolling it out everywhere.

[elastic_ci]: https://github.com/buildkite/elastic-ci-stack-for-aws
[release]: https://github.com/buildkite/elastic-ci-stack-for-aws/releases
