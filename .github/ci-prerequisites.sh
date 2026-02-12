# Reclaim disk space, otherwise we have too little free space at the start of a job
#
# Numbers as of 2024-02-15:
#
# $ df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/root        73G   54G   20G  74% /
# tmpfs           3.4G  172K  3.4G   1% /dev/shm
# tmpfs           1.4G  1.1M  1.4G   1% /run
# tmpfs           5.0M     0  5.0M   0% /run/lock
# /dev/sda15      105M  6.1M   99M   6% /boot/efi
# /dev/sdb1        14G  4.1G  9.0G  31% /mnt
# tmpfs           693M   12K  693M   1% /run/user/1001
#
# $ docker images
# REPOSITORY       TAG         IMAGE ID       CREATED        SIZE
# node            18          acc6f84723fc   2 weeks ago    1.09GB
# node            20          723a77f71cf0   2 weeks ago    1.1GB
# debian          10          bb9367ba0dd2   2 weeks ago    114MB
# debian          11          e5f3fa5ee24d   2 weeks ago    124MB
# moby/buildkit   latest      480495983c47   2 weeks ago    172MB
# node            18-alpine   c8eb770fbfac   2 weeks ago    132MB
# node            20-alpine   530b955dc368   2 weeks ago    137MB
# alpine          3.16        d49a5025be10   2 weeks ago    5.54MB
# alpine          3.17        eaba187917cc   2 weeks ago    7.06MB
# alpine          3.18        d3782b16ccc9   2 weeks ago    7.33MB
# ubuntu          22.04       fd1d8f58e8ae   2 weeks ago    77.9MB
# ubuntu          20.04       18ca3f4297e7   3 weeks ago    72.8MB
# node            16          1ddc7e4055fd   5 months ago   909MB
# node            16-alpine   2573171e0124   6 months ago   118MB

# Remove node container images
time docker rmi -f $(docker images node -q)
# That is 979M
time sudo rm -rf /usr/share/dotnet
# That is 1.7G
time sudo rm -rf /usr/share/swift
# Remove Android
time sudo rm -rf /usr/local/lib/android
# Remove Haskell
time sudo rm -rf /opt/ghc
time sudo rm -rf /usr/local/.ghcup
# Remove pipx
time sudo rm -rf /opt/pipx
# Remove Rust
time sudo rm -rf /etc/skel/.rustup
time sudo rm -rf /home/packer/.rustup
time sudo rm -rf /home/runner/.rustup
time sudo rm -rf /usr/share/rust
# Remove Go
time sudo rm -rf /opt/hostedtoolcache/go
time sudo rm -rf /usr/local/go
# Remove miniconda
time sudo rm -rf /usr/share/miniconda
# Remove powershell
time sudo rm -rf /usr/local/share/powershell
# Remove Google Cloud SDK
time sudo rm -rf /usr/lib/google-cloud-sdk
# Remove CodeQL
time sudo rm -rf /opt/hostedtoolcache/CodeQL
# Remove Julia language
time sudo rm -rf /usr/local/julia1.12.4
