#!/bin/bash
# ==============================================
# Ubuntu VM Disk Expansion Script for LVM Systems
# Run with: sudo bash expand_disk.sh
# ==============================================

echo "=== Step 1: Checking current disk layout ==="
lsblk
echo ""

echo "=== Step 2: Resizing Physical Volume ==="
# This makes LVM aware of the new space in /dev/vda3 partition
sudo pvresize /dev/vda3
echo "Physical volume resized."
echo ""

echo "=== Step 3: Checking available space in Volume Group ==="
# Shows how much free space is now available in the LVM pool
sudo vgdisplay ubuntu-vg | grep -E "(Free|Size)"
echo ""

echo "=== Step 4: Extending Logical Volume ==="
# Uses 100% of available free space to expand the logical volume
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
echo "Logical volume extended."
echo ""

echo "=== Step 5: Resizing Filesystem ==="
# Makes the filesystem (ext4) use all the new space in the logical volume
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
echo "Filesystem resized."
echo ""

echo "=== Step 6: Verifying the expansion ==="
echo "Final disk usage:"
df -h /
echo ""
echo "LVM details:"
sudo lvs
