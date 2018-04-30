#!/bin/bash
FL=file_list2
find . -type f -printf '%s %p\n' > $FL
