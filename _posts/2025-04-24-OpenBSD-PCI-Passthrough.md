---
layout: post
title: Passing PCI Devices to OpenBSD VMs from Linux Virtualization Hosts
topic: PCI passthrough to OpenBSD hosts with libvirt and KVM
category: programming
description: With processor and platform support, PCI passthrough allows a guest virtual machine to directly map host PCI resources, keeping them otherwise inaccessible to the host. Linux VM hosts running libvirt and KVM can support PCI passthrough, but there were a few pitfalls when communicating with OpenBSD guests.
image: openbsd.gif
---

We run several virtualized OpenBSD routers and application hosts on Linux-based virtualization hosts. As more of the platforms we use for the virtualization hosts have moved to hardware that supports [VFIO](https://www.kernel.org/doc/html/v5.6/driver-api/vfio.html) (Virtual Function I/O), experiments were performed to switch from bridged interfaces to PCI passthrough.

PCI passthrough uses the [IOMMU](https://en.wikipedia.org/wiki/Input%E2%80%93output_memory_management_unit) functionality of newer platforms to keep the virtualization host kernel from talking to PCI devices configured for VM use, making the passed-through devices appear to the VM as if they were "plugged in" to the VM's PCI bus. This offers several potential advantages:

* Near-native speed for PCI devices
* Better VM/host isolation
* Support for devices which have no direct virtual counterpart

Passthrough is often used with GPUs, to give VMs exclusive, full-speed access to GPU resources. This is perhaps the most common example found on the Internet, in various guides, etc. It can be configured to work with any PCI device, as long as you have enough IOMMU group granularity. We were interested in passing through entire Ethernet devices for both security separation (the virtualization host would have no interaction with packets on the passed-through interface) and performance.

### Virtualization Platform

Experiments were conducted on our "medium virtualization host" platform, which at the time was the [Advantech FWA-3260](https://www.advantech.com/en-us/products/5f790122-c29e-4453-bb73-0da4c95b7eca/fwa-3260/mod_0d8b27c6-4283-4b90-abba-5aa5c5e068bd), which is a 1U router appliance featuring the Xeon D-1500 series processor. It supports Intel VT-d IOMMU functionality for PCI passthrough, and the included Ethernet interfaces have three distinct sets of PCI IDs:

* `8086:1521` for the four i350 gigabit copper ports
* `8086:15ac` for the Xeon D onboard X552 10 gigabit SFP+ ports

This allows for easy isolation of the Ethernet interfaces intended for VMs from the HVM management Ethernets, which are Intel i210 gigabit ports with PCI ID `8086:1533`. 

Most of our HVMs run [Alpine Linux](https://www.alpinelinux.org/), though the process for passing through PCI devices is largely the same on other Linux distributions. There are some differences mostly around Alpine's use of [OpenRC](https://wiki.gentoo.org/wiki/OpenRC) instead of `systemd`. Virtualization is achieved using [Linux KVM](https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine) and [libvirt](https://libvirt.org/).

### Configuring VFIO

We manage our HVMs through [Ansible](https://github.com/ansible/ansible) and configuring VFIO is no exception. The first step is kernel configuration: VFIO related modules must be configured into the `initrd` and `GRUB` must be told to enable VFIO in the kernel command line.

Our VFIO role first checks to see if VT-d is enabled (the FWA-3260 is unconditionally an Intel platform):

{% codeblock :language => 'yaml', :title => 'configure_grub.yml' %}
{% raw %}
- name: Check if Intel VT-d is already enabled
  replace:
    path: /etc/default/grub
    regexp: '^GRUB_CMDLINE_LINUX_DEFAULT="(.*)( {{ grub_cmdline }})(.*)"$'
    replace: 'GRUB_CMDLINE_LINUX_DEFAULT="\1 \3"'
  check_mode: true
  register: vt_d_presence
{% endraw %}
{% endcodeblock %}

If the `grub_cmdline` (defined in the vars for the role) is already present, we don't need to add it a second time. This replacement adds it in, preserving the rest of the `GRUB` command line:

{% codeblock :language => 'yaml', :title => 'configure_grub.yml' %}
{% raw %}
- name: Enable Intel VT-d
  replace:
    path: /etc/default/grub
    regexp: '^GRUB_CMDLINE_LINUX_DEFAULT="(.+)"$'
    replace: 'GRUB_CMDLINE_LINUX_DEFAULT="\1 {{ grub_cmdline }}"'
  when: not vt_d_presence.changed
  notify: Update Alpine GRUB configuration
{% endraw %}
{% endcodeblock %}

For the Advantech FWA-3260, or any other system using an Intel Xeon D processor, `grub_cmdline` is set to `intel_iommu=on iommu=pt intremap=no_x2apic_optout` in the role vars.

The handler `Update Apline GRUB configuration` just runs the command `/usr/sbin/grub-mkconfig -o /boot/grub/grub.cfg`.

VFIO modules are then configured in the kernel:

{% codeblock :language => 'yaml', :title => 'configure_vfio.yml' %}
{% raw %}
- name: Configure VFIO modules for initrd
  copy:
    src: vfio.modules
    dest: /etc/mkinitfs/features.d/vfio.modules
    owner: root
    group: root
    mode: '0644'
  notify: Rebuild Alpine initrd
{% endraw %}
{% endcodeblock %}

This step simply tells `mkinitfs` which modules we'd like to be included:

{% codeblock :language => 'conf', :title => 'vfio.modules' %}
# Managed by Ansible, DO NOT HAND-EDIT!

kernel/drivers/vfio/vfio.ko.*
kernel/drivers/vfio/vfio_virqfd.ko.*
kernel/drivers/vfio/vfio_iommu_type1.ko.*
kernel/drivers/vfio/pci/vfio-pci.ko.*
{% endcodeblock %}

The next step is to see if `mkinitfs.conf` already contains the configuration we want:

{% codeblock :language => 'yaml', :title => 'configure_vfio.yml' %}
{% raw %}
- name: Check if VFIO module features are already enabled for mkinitfs
  replace:
    path: /etc/mkinitfs/mkinitfs.conf
    regexp: '^features="(.*)( vfio)(.*)"$'
    replace: 'features="\1 \3"'
  check_mode: true
  register: vfio_presence

- name: Enable VFIO module features for mkinitfs
  replace:
    path: /etc/mkinitfs/mkinitfs.conf
    regexp: '^features="(.+)"$'
    replace: 'features="\1 vfio"'
  when: not vfio_presence.changed
  notify: Rebuild Alpine initrd
{% endraw %}
{% endcodeblock %}

As above, this test and replacement makes sure we don't already have `vfio` configured for `mkinitrd`. The handler `Rebuild Alpine initrd` has two parts:

{% codeblock :language => 'yaml', :title => 'handlers.yml' %}
{% raw %}
- name: Rebuild Alpine initrd
  shell: 
    cmd: mkinitfs $(ls /lib/modules)
  register: vfio_rebuild_initrd
  failed_when: vfio_rebuild_initrd.rc != 0
  notify:
    - ALERT -- RESTART REQUIRED FOR IOMMU

- name: ALERT -- RESTART REQUIRED FOR IOMMU
  debug:
    msg: "A restart is required to enable the IOMMU."
  register: iommu_restart_required
{% endraw %}
{% endcodeblock %}

Finally, we configure `modprobe` for VFIO full passthrough based on PCI IDs:

{% codeblock :language => 'yaml', :title => 'full_passthrough.yml' %}
{% raw %}
- name: Configure modprobe options for VFIO full passthrough
  template:
    src: "vfio_full_passthrough.conf.j2"
    dest: /etc/modprobe.d/vfio.conf
    owner: root
    group: root
    mode: '0644'
  notify: Rebuild Alpine initrd
{% endraw %}
{% endcodeblock %}

The `modprobe` configuration binds the PCI IDs specified in the host's vars to `vfio-pci` and sets `vfio-pci` as a softdep for the normal Ethernet kernel drivers for the PCI IDs, which in the case of the Advantech FWA-3260's interfaces, are `igb` and `ixgbe`. 

{% codeblock :language => 'conf', :title => 'vfio_full_passthrough.conf.j2' %}
{% raw %}
# Managed by Ansible, DO NOT HAND-EDIT!
# VFIO configuration for {{ inventory_hostname }}

options vfio-pci ids={{ vfio.passthrough.pci_ids|join(',') }}
{% if vfio.passthrough.options is defined %}
options {{ vfio.passthrough.options }}
{% endif %}
{% for module in vfio.passthrough.softdeps %}
softdep {{ module }} pre: vfio-pci
{% endfor %}
{% endraw %}
{% endcodeblock %}

This again registers changes with the `Rebuild Alpine initrd` handler.

Note that the above *does not tell the kernel about PCI IDs to be passed through on the kernel command line* -- this is often specified in configuration guides, but is not required as long as your device drivers are modules and not statically built into the kernel.

### Guest Configuration

The guests for this experiment were all OpenBSD; at the time, OpenBSD 7.6. No special configuration was required at the operating system level.

The `libvirt` configuration for the guests required some experimentation: at first, we were able to pass through PCI devices, but they behaved poorly, often passing traffic intermittently, causing lockups, etc. The problems caused such headache that [Proxmox VE](https://www.proxmox.com/en/products/proxmox-virtual-environment/overview) was installed on one of the FWA-3260 test platforms. After configuring the kernel for PCI passthrough, everything worked on the exact same hardware!

We finally determined that it was a mix of `libvirt` configuration issues causing headaches:

* Always use `UEFI` and `Q35` system configurations when passing through PCI
* Set the CPU type to the family `model`, not host passthrough

The second point, setting the CPU type, was the final bit required to achieve stability. You can find the CPU family for your platform by running `virsh capabilities` and looking for the `<model>` section of the XML it returns. For the Advantech FWA-3260, this is `Broadwell-v1`.

### Performance and Stability

The above configuration has been in continuous operation since early 2025, running the VMs that handle the routing, firewalling, etc. for the Glitch Works, LLC office's fiber connection. It also formed the basis for our newer Secure Access Gateway offerings deployed on customer sites. We have had no stability issues, and performance benchmarking shows that OpenBSD is slightly less performant than running bare-metal on the Advantech FWA-3260s.

Using full PCI passthrough has provided the isolation we require for security critical devices like routers and firewalls, keeping the HVM operating system completely blind to public Internet traffic, traffic from networks considered potentially hostile (a Secure Access Gateway talks to tool control systems which cannot be patched, often running unsupported operating systems and software), but still allowing the advantages of router/firewall virtualization in management, HA, and backups.

{% counter :text => 'Ethernet interfaces passed through' %}
