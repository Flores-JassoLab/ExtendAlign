condor-mk
=========

A helper to send jobs to condor at INMEGEN cluster.

# Usage

Create a job.

```
condor
```

Send pending jobs to the cluster.


```
condor clean
# edit to ask for anything else than default resources
$EDITOR condor.header
condor submit
```

Customize jobs to send to the cluster.

```
bin/targets | [filter] | condor-sub condor.header > condor.sub
condor submit
```

# Options

@@How can you customize the analysis using environment vars or config.mk@@

# Design considerations

@@What was taken into account to build this project?@@

# Requirements

- [`mk`](http://doc.cat-v.org/bell_labs/mk/mk.pdf "A successor for `make`.")

- [`findutils`](https://www.gnu.org/software/findutils/ "Basic directory searching utilities of the GNU operating system.")

- [`coreutils`]( "basic file, shell and text manipulation utilities of the GNU operating system.")

- [@@aditional software@@](@@software URL@@ "@@Description@@")

# References

@@What documents did you used for making this module?@@

@@Where is the documentation for the software used?@@
