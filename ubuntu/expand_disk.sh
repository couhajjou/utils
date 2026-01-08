#!/bin/bash
# ==============================================
# Ubuntu VM Disk Expansion Script for LVM Systems
# Run with: sudo bash expand_disk.sh
# ==============================================

echo "=== Step 1: Checking current disk layout ==="
lsblk
echo ""

echo "=== Step 2: Checking if partition can be expanded ==="
# First check the actual disk size vs partition size
echo "Disk size:"
sudo fdisk -l /dev/vda | grep "Disk /dev/vda"
echo ""
echo "Current partition 3 size:"
sudo parted /dev/vda unit GB print free | grep "Free Space\|vda3"
echo ""

echo "=== Step 3: Expanding partition (if needed) ==="
# Expand partition to use all free space on disk
sudo growpart /dev/vda 3
echo ""

echo "=== Step 4: Rescanning disk partitions ==="
sudo partprobe /dev/vda
echo ""

echo "=== Step 5: Resizing Physical Volume ==="
# This makes LVM aware of the new space in /dev/vda3 partition
sudo pvresize /dev/vda3
echo "Physical volume resized."
echo ""

echo "=== Step 6: Checking available space in Volume Group ==="
# Shows how much free space is now available in the LVM pool
sudo vgdisplay ubuntu--vg | grep -E "(Free|Size)"
echo ""

echo "=== Step 7: Extending Logical Volume ==="
# Uses 100% of available free space to expand the logical volume
sudo lvextend -l +100%FREE /dev/ubuntu--vg/ubuntu--lv
echo "Logical volume extended."
echo ""

echo "=== Step 8: Resizing Filesystem ==="
# Makes the filesystem (ext4) use all the new space in the logical volume
sudo resize2fs /dev/ubuntu--vg/ubuntu--lv
echo "Filesystem resized."
echo ""

echo "=== Step 9: Verifying the expansion ==="
echo "Final disk usage:"
df -h /
echo ""
echo "Current layout:"
lsblk
echo ""
echo "LVM details:"
sudo lvs
