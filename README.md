## Sources for the Apache Airflow official Docker/Container image

This is a read-only repository Containing Apache Airflow Dockerfile and corresponding
scripts that are needed to build the Official Airflow production-ready Docker/Container image.

This repo keeps only the necessary files in `airflow` branch synchronized with the main
Apache Airflow repository. Note! You will not find docker image in the "main" branch of this repo,
you need checkout the `airflow` branch! The `main` branch keeps the code to synchronize the sources.

You should check out the `airflow` branch and follow instructions found in
https://airflow.apache.org/docs/docker-stack/build.html#customizing-the-image

```shell
git clone -b airflow https://github.com/apache/airflow-docker.git

docker build . =-tag "my-airflow:0.0.1"
```

## How the repository synchronization works

There is a GitHub Workflow that runs periodically (daily) and keeps the relevant branches in sync with the
Apache Airflow repository. The script only keeps files and commits relevant to the Dockerfile building.
This is done thanks to fantastic [git-filter-repo](https://github.com/newren/git-filter-repo)
project that allows for automation of branch and path filtering.

## Official release disclaimer

Note that this repository is just a convenience one. It is maintained by the Apache Airflow community, and
you can clone and check it out if you wish, but the only official sources of Apache Airflow releases
are at [Airflow Downloads](https://downloads.apache.org/airflow/). There youf ind the packages .tar.gz
sources of the releases which have been officially voted on by PMC and released following the
[ASF Release Policy](https://www.apache.org/legal/release-policy.html).
