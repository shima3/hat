#!/bin/bash
extless="${0%.*}"
$* examples/delay.sch < ${extless}.in
