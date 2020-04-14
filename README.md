# Xanthus: Automated Reproducible Data Generation for Evaluating Intrusion Detection Systems

Fairly evaluating and comparing the efficacy of different intrusion detection systems (IDS) requires that experimental data
be generated in a similar mechanism and/or shared across these systems.
The reality, unfortunately, is that there exist few public repositories (e.g., DARPA 1998/1999/2000, KDD Cup99, DARPA TC Engagement 3)
containing experimental data captured solely for the purpose of security analysis.
Among those public data repositories, most are outdated because a tremendous amount of manual labor is almost always
necessary to capture the data (e.g., DARPA TC program involves a number of teams from
across the academia and the industry and it spans over many a year).
Consequently, some newly-developed systems, in order to be able to compare against older systems,
are evaluated using the data that is a decade or two older than the systems themselves
(and usually and unsurprisingly exhibit good results).
Given that there is a perpetual arms race between the defenders and the offenders in the realm of cyber security
and that new cyber-threats are manufactured every day,
a successful defence against a decade-old exploit is hardly an achievement.

Many existing systems, acknowledging this fact and ready to showcase their detection capability,
design their own experiments and produce their own dataset as a result.
Although the experiments are sometimes carefully described in their associated publications (e.g., in academic projects),
such dataset suffers from the following drawbacks:

- In the cases where the dataset is made public, later systems can but consume only a subset of the dataset for analysis.
Therefore, if they require e.g., additional features from the dataset in the analysis, they must rerun the experiments
to capture the data themselves again, instead of simply re-using the available dataset.
Moreover, some systems publish only pre-processed dataset, which usually eliminates information from the original,
raw dataset that is not relevant to their analysis, even though such information may be relevant for other systems.

- When raw dataset is made public, it provides later systems with richer information content.
However, the underlying systems that capture the raw dataset (e.g., audit systems) are also constantly evolving,
generating finer-grained, more accurate information or
offering a completely different perspective through which one understands system behavior (e.g., provenance systems).
Security systems that take advantage of such advancement in the underlying systems
may very well find even the raw data provided by previous systems insufficient.

- If later systems must resort to reproducing dataset themselves as a result of the reasons listed above,
they need to rely on descriptions provided by previous systems to ensure high-fidelity experiment replay.
Even if we assume that previous systems provide sufficiently detailed descriptions to understand the experiment
(which certainly is not always the case),
there still exist a number of challenges.

    - The experiment must be conducted using the exact software involved with matching versions.
    In many cases, security experts have since identified and patched vulnerabilities in the exploitable software
    used in security-related experiments, and thus the software itself usually has been updated to a newer version.
    Downgrading the target software and its dependencies is therefore necessary to reproduce the experiment. This
    sometimes cannot be automatically configured through existing package management systems and requires significant
    manual configuration.

    - Some vulnerability may affect only a particular version of the operating system. This requirement no doubt
    further complicates the experimental setup and demands additional engineering effort.

    - Other controllable factors may be omitted in the description that may or may not affect the final results of the
    experiment. For example, background activities may have been included in the dataset but was not discussed in detail.

Before we go into any detail about using **Xanthus** for automated, reproducible data generation for security analysis,
we describe a pipeline in which we create dataset for a *specific* attack in a push-button fashion. **Xanthus** is
a higher-level abstracted framework that generates such a pipeline for *any* attack that existing or future IDS intend to
evaluate.

## Primer to Xanthus: A Specific Pipeline

We introduce a specific pipeline that automates data capture for a particular attack.
In this pipeline, we deploy virtual machines (VM), set up a virtual environment that recreates the attack scenario,
and run the attack, while capturing data from a whole-system provenance capture system.
Code is publicly available online at [GitHub](https://github.com/crimson-unicorn/demo/tree/master/wget).
Please refer to the code while finishing off the rest of this section.

### Prerequisites

We assume that you understand the following terms and concepts.
If not, click on the item that you do not understand to read more about it:

* [Virtual machines](https://en.wikipedia.org/wiki/Virtual_machine)
* [Makefile](https://en.wikipedia.org/wiki/Makefile)
* [VirtualBox](https://www.virtualbox.org/manual/ch01.html)
* [Vagrant](https://www.vagrantup.com/intro/index.html), [Vagrantfile](https://www.vagrantup.com/docs/vagrantfile/)
and [provisioning](https://www.vagrantup.com/docs/provisioning/index.html)
* [CamFlow](http://camflow.org)

You may want to understand the following terms and concepts if you want to fully understand the attack
that we will describe in the next section:

* [Trojan software](https://en.wikipedia.org/wiki/Advanced_persistent_threat)
and [reverse shell](https://resources.infosecinstitute.com/icmp-reverse-shell/#gref)

### A Brief Attack Description

You could better understand the pipeline with the knowledge of the attack that we would like to reproduce automatically.
The attacker aims to invade a victim machine through a vulnerable (or exploitable) `wget`.
The attacker sets up a malicious (or compromised) `HTTP` server that redirects any requests to a malicious `FTP` server
that contains a `Debian` package with a Trojan backdoor.
The package appears to be the same as its legitimate version and may even work the same way,
but the moment the package is installed on the victim machine, it will initiate a reverse TCP connection to the attacker
who is listening for connections and create a reverse shell that allows the attacker to infiltrate into the victim machine.

When the victim machine attempts to download the benign package from the `HTTP` server using `wget`,
`wget` allows arbitrary remote file upload to the host system.
Meaning that, instead of fetching the intended benign package, it allows redirection of the `HTTP` server and downloads
the malicious one.
The user is unaware of such behavior and install the package through the package manager `dpkg`.
The installed Trojan software establishes a connection to the attacker and the attack succeeds.

### Software Involved

* `wget` v1.17 or older
* Any `Debian` package with a Trojan backdoor. The `Debian` package must be installable (both benign and malicious version).
* Functioning `HTTP` and `FTP` server
* `dpkg` package manager
* `CamFlow` whole-system provenance capture system

### Execution Platform

As expected, `Debian` package can only run on any `Debian`-based operating systems. This particular pipeline is run on
`Ubuntu 18.04` (both the client and the server).

### The Pipeline

#### Installation

To run this pipeline, you need to install at least the following items:

* `Vagrant`
* Oracle `VirtualBox`

#### Usage

If you `git clone` the entire repository from [GitHub](https://github.com/crimson-unicorn/demo/), `cd` into `wget` directory.
We assume this directory would be your working directory.

We write a `Makefile` to run our attack scenario for many times. If you want to run it once only,
modify this line: `[ $${cnt} -lt 25 ]` to `[ $${cnt} -lt 1 ]` in the `Makefile`.
(In `Xanthus`, we would be able to configure this easily without actually modifying the code.)

If you are running on `Mac`:
```
make test_mac
```
On `Linux`, you would run:
```
make test_linux
```
We do *not* support `Windows` operating system for now.
You would locate the output data file in `data/` directory.

#### Behind the Scenes

This pipeline seems to be very user-friendly. So, one might ask, why do we bother to design and implement `Xanthus`?
The truth is, we have done a lot of heavy-lifting for you behind the scenes. Let's take a closer look.

The `Makefile` you run starts the `vagrant` process, which would boot up two virtual machines, one `server` and one
`client` (now, take a look into `Vagrantfile`).

The `server` machine is provisioned by `provision/server.sh` script.
It configures an `FTP` and an `HTTP` server and puts the malicious `Debian` package in the `FTP` server.
Of course, the user must provide the pipeline with the package.
We build the package ourselves in [Kali Linux](https://en.wikipedia.org/wiki/Makefile)
with [TheFatRat](https://github.com/Screetsec/TheFatRat). You are free to use any tools at your disposal.
We also put the benign one in the `HTTP` server to trick the user to download it.

The `client` machine involves more operations.
First, unlike the `server` machine that simply uses a `Ubuntu 18.04` base operating system
(as seen in `server.vm.box = "bento/ubuntu-18.04"`),
the `client` machine uses our customized `VirtualBox` box called `michaelh/ubuncam`.
This box is built with the following specifications:

* It is built upon the original `Ubuntu 18.04` base box from `Vagrant`.
* It is installed with `CamFlow` as its provenance-capture system.
* It downgrades `wget` to its desired version (`v1.17`) that contains the vulnerability.
* It can install `Debian` packages in the experiment.

Note that it is always desirable to package such a box and upload it to the `VagrantCloud` so that we can
configure once and reuse many times.
One can always use a base box and configure the above specifications on-the-fly,
but it is not guaranteed that the configuration would work in the distant future.
For example, the link to download an older version of `wget` may expire without notice.
`Xanthus` allows users to either provide a customized virtual box or configure a base box through provisioning.
If an online configuration is provided, `Xanthus` would automatically generate a customized box for the user
to prevent future re-configuration or possible failure in future configuration.

The `client` machine runs the script in `provision/attack`.
The user must provide such a script.
In our case, we automatically generate attack scripts using `wget-attack-script-gen.py`.
`Xanthus` allows users to provide logic to generate scripts or simply provide scripts to run during the experiment.

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'xanthus'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xanthus

### Usage

```
xanthus version | return Xanthus version number.
xanthus dependencies | installation instructions for system dependencies.
xanthus init <project name> | initialize a new project.
xanthus run | run .xanthus file in the current folder.
```

### Development

To add more features in `Xanthus`,
clone this repository
```
git clone https://github.com/tfjmp/xanthus
cd xanthus
```
and build the gem by running 
```
gem build xanthus
```
To install this gem locally on your machine, you can also run
```
gem install xanthus
```
After you add a new feature (and test it yourself), you can release a new version of `Xanthus`.
First, please update the version number in `lib/xanthus/version.rb`, tag the repository `git tag -a x.x.x -m 'x.x.x'`, and push the tag `git push --tags`.
Then you can run 
```
gem push xanthus-x.x.x.gem
```
This last step publishes the gem at [https://rubygems.org/gems/xanthus](https://rubygems.org/gems/xanthus).

### Contribution

We welcome bug reports and pull requests on GitHub at https://github.com/[USERNAME]/xanthus.

### License

This gem is available as an open source project under the [MIT License](https://opensource.org/licenses/MIT).
