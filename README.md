# buildkite-infrastructure

[![Build status](https://badge.buildkite.com/8f0b5086f09a5fbd3405610566ac66b82ae90005b8268688b2.svg)](https://buildkite.com/wellcomecollection/buildkite-infrastructure)

We use [Buildkite] to power our CI/CD setup.
This repo contains the configuration for our Buildkite setup.

We use Buildkite so that we can use EC2 instances in our own account as [Buildkite agents][agents], which has several benefits:

*   **We can choose which instances to use.**
    We can run as many parallel EC2 instances as we're willing to pay for, and we can choose instance types that are best suited to our particular tasks.

*   **The build runners are inside our AWS account.**
    This means we can use EC2 instance roles for permissions management, rather than creating permanent credentials that we have to trust to a third-party CI provider.
    We're more comfortable doing powerful things in CI (e.g. deploying to prod) because it's within our account boundary.

*   **We can reuse the same instance in multiple builds.**
    Because we're the only organisation using our build runners, we don't have to worry about information leaking from another tenant's builds, or our information leaking into their builds.
    This means we can reuse build instances, which gets us more caching and faster builds.

[Buildkite]: https://buildkite.com/wellcomecollection
[agents]: https://buildkite.com/docs/agent/v3



## How we configure Buildkite

We use the [Elastic CI Stack for AWS][elastic_ci], which is provided by Buildkite and configured in Terraform.

We run multiple instances of the stack, mostly varying by EC2 instance type, to get a good balance of fast builds and a reasonable build.

[elastic_ci]: https://buildkite.com/docs/agent/v3/elastic-ci-aws/elastic-ci-stack-overview



## How to get to our Buildkite pipelines

You can see our Buildkite pipelines at <https://buildkite.com/wellcomecollection>.

If you're a Wellcome developer who wants to log in to Buildkite, visit <https://buildkite.com/sso/wellcomecollection>
