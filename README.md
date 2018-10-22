# PBS script Writer (PBSW)

This bash script generates PBS job scripts based on user-specified inputs

## Creating a local config file
In many cases, multiple qsub jobs will be submitted with the same or similar parameters. Rather than specifying all the PBS variables for each run, you can create a local configuration file that will apply a set of standard parameters to every PBS script.

To set up a local config, create a file named ```.pbswrc``` within the directory that contains the shell script(s) you want to submit to qsub. Below is an example of a ```.pbswrc``` config with examples for specifying all of the variables currently supported by ```pbsw```:

``` shell
## Config file for PBS script Writer

## set user email
EMAIL=from.config@test.org

## set value for '# PBS -l'
PBS_l="nodes=1:ppn=10,pmem=8gb,walltime=24:00:00"
```
