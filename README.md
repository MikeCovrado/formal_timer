## Example formal proofs and coverage using SBY

### RUN PROOFS
$ sby -f timer_proofs.sby 

### RUN COVERAGE
$ sby -f timer_coverage.sby 

### Review coverage and/or counter-example
$ gtkwave timer\_<proofs|coverage>/engine_0/trace[N].vcd timer.gtkw &
<br>
...where N is from the proof/coverage log.
