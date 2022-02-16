# buildkite-infrastructure

[![Build status](https://badge.buildkite.com/8f0b5086f09a5fbd3405610566ac66b82ae90005b8268688b2.svg)](https://buildkite.com/wellcomecollection/buildkite-infrastructure)

We use [Buildkite] to power our CI/CD setup.

The main reason we use Buildkite is that we can use EC2 instances in our own account as [Buildkite agents][agents], which has several advantages:

*   We can have CI agents that are as parallel or as powerful as we're willing to pay for; we're not bound by provider limits.

*   We can use IAM permissions management within AWS, rather than creating credentials that are hard-coded in our CI provider.

*   We can reuse the same instance in multiple builds; we don't have to worry about information leaking from another tenant.
    This gets us more caching between builds.

[Buildkite]: https://buildkite.com/wellcomecollection
[agents]: https://buildkite.com/docs/agent/v3



## How we configure Buildkite

We use the [Elastic CI Stack for AWS][elastic_ci], which is provided by Buildkite and configured in Terraform.

We run multiple instances of the stack, mostly varying by EC2 instance type, to get a good balance of fast builds and a reasonable build.

[elastic_ci]: https://buildkite.com/docs/agent/v3/elastic-ci-aws/elastic-ci-stack-overview



## How to get to our Buildkite pipelines

You can see our Buildkite pipelines at <https://buildkite.com/wellcomecollection>.

If you're a Wellcome developer who wants to log in to Buildkite, visit <https://buildkite.com/sso/wellcomecollection>
