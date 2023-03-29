# buildkite-infrastructure

[![Build status](https://badge.buildkite.com/8f0b5086f09a5fbd3405610566ac66b82ae90005b8268688b2.svg)](https://buildkite.com/wellcomecollection/buildkite-infrastructure)

We use [Buildkite] to power our CI/CD.
This repo contains the configuration for our Buildkite setup.

## How it works

When you open a pull request or push a commit to main in our repositories, Buildkite parses the `.buildkite/pipeline.yml` file.
This YAML file defines the **[pipeline steps]** -- it tells Buildkite what jobs to run, e.g. *run `yarn test` in the `catalogue` folder*.

![An architecture diagram for Buildkite. The Buildkite logo has three arrows coming from it to three queues (represented by green rectangles) -- this represents jobs being distributed to queues. There's then a single arrow from each queue to an autoscaling group containing instances (respresented by an orange rectangle with smaller orange squares inside).](./architecture.png)

Buildkite distributes these jobs across one or more queues.
Each queue is attached to an EC2 autoscaling group; the EC2 instances in this group pull jobs from the queue.
These are called Buildkite **agents**.

The job runs on the instance, and the results are reported back to Buildkite.
We can see the results in the Buildkite dashboard.

We have several different queues, each backed by a different instance class.
The instance classes are matched to the sort of work that goes on that queue: for example, we have one queue with powerful instances that runs short-lived, CPU-intensive tasks, and another queue with small instances that run long-lived, CPU-light tasks.

All our EC2 instances are **[spot instances]** – we use spare EC2 capacity at a cheaper price, with the small risk that instances (and thus build jobs) might be stopped unexpectedly.

[pipeline steps]: https://buildkite.com/docs/pipelines/defining-steps
[spot instances]: https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-instances.html



## Why Buildkite?

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



## Troubleshooting

*   When a job starts, you may see **Waiting for agent** in the Buildkite dashboard -- this means it's waiting for an EC2 instance in the autoscaling group.

    Usually this disappears in a minute or so, once an instance becomes available in the autoscaling group, but occasionally it will hang.

    If this message doesn't disappear quickly, there may be an issue starting new EC2 instances – check the autoscaling group in the AWS console.

    One issue we've seen several times is when the current EC2 Spot price is higher than our maximum configured Spot bid -- check the spot pricing history for the instance class in the AWS console, and compare it to the `SpotPrice` parameter in our Terraform.
    If the current spot price is too high, consider increasing the `SpotPrice` parameter and plan/applying the Terraform.
