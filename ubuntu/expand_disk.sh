#!/bin/bash
# ==============================================
# Ubuntu VM Disk Expansion Script for LVM Systems
# Run with: sudo bash expand_disk.sh
# ==============================================

echo "=== Step 1: Checking current disk layout ==="
lsblk
echo ""

echo "=== Step 2: Checking disk and partition sizes ==="
echo "Disk size:"
sudo fdisk -l /dev/vda | grep "Disk /dev/vda"
echo ""
echo "Partition layout:"
sudo parted /dev/vda unit GB print free | grep -E "Free Space|vda[0-9]"
echo ""

echo "=== Step 3: Expanding partition (if possible) ==="
# Try to expand partition to use all free space on disk
sudo growpart /dev/vda 3 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Partition expanded successfully."
else
    echo "Partition already at maximum size (or error occurred)."
fi
echo ""

echo "=== Step 4: Rescanning disk partitions ==="
sudo partprobe /dev/vda
echo "Partitions rescanned."
echo ""

echo "=== Step 5: Resizing Physical Volume ==="
# This makes LVM aware of the new space in /dev/vda3 partition
sudo pvresize /dev/vda3
echo "Physical volume resized."
echo ""

echo "=== Step 6: Checking available space in Volume Group ==="
# Shows how much free space is now available in the LVM pool
echo "Volume Group information:"
sudo vgdisplay ubuntu-vg | grep -A3 "VG Size"
echo ""

echo "=== Step 7: Extending Logical Volume ==="
# Uses 100% of available free space to expand the logical volume
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
echo "Logical volume extended."
echo ""

echo "=== Step 8: Resizing Filesystem ==="
# Makes the filesystem (ext4) use all the new space in the logical volume
# Note: Use the device mapper path which is guaranteed to exist
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
echo "Filesystem resized."
echo ""

echo "=== Step 9: Final verification ==="
echo "Disk usage:"
df -h /
echo ""
echo "Current disk layout:"
lsblk
echo ""
echo "LVM summary:"
sudo lvs --units g
echo ""
echo "=== Expansion complete! ==="
