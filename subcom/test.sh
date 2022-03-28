#!/bin/bash

echo 'openss
git ch
git che' | ./comp.exp | sed -E '
1 s/openssl//;
2 s/che//;
3 s/checkout//;
3 s/cherry//;
3 s/cherry-pick//;
s/[[:space:]]//g;
' | awk '$0 {exit 1}'

(($(./comp.exp ' ' | xargs -n1 |  wc -l) > 10))
