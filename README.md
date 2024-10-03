# HourglassOS Installer

该 TUI Shell 脚本安装程序用于 hourglassOS，这是一个基于 Void Linux 的系统，专为 Web 3.0 量身打造。

该安装程序的主要目标是提供一个支持加密功能的安装选项，同时也提供了其他常用的通用安装选项，并且配备了合理的默认设置。

该安装程序的整体目标是在安装程序退出后，立即实现一个高度定制、可用的系统。

# 特性
- 可选择添加用户自定义模块，供安装程序执行，详见模块说明
- 内置模块执行多项功能，部分包括：
  - 启用系统日志记录功能（使用 socklog）
  - 安装 Wi-Fi 固件及基础工具
  - 安装 Flatpak 并预配置 Flathub 仓库
  - 安装并预配置 qemu 和 libvirt
  - 安装 nftables 并附带默认的防火墙配置
  - 各类安全相关模块

- 可选择使用 grub、efistub 和实验性 UKI 支持

- 可选择对安装磁盘进行加密
  - 使用 UKI 配置时，加密将使用 luks2 加密 /boot 和 /
  - 使用 efistub 配置时，加密将使用 luks2 加密 /
  - 使用 grub 配置时，加密将使用 luks1 加密 /boot 和 /

- 可选择预安装并预配置以下内容：
  - 图形驱动（amd、nvidia、intel、nvidia-nouveau 或不安装）
  - 网络管理（dhcpcd、NetworkManager 或不安装）
  - 音频服务器（pipewire、pulseaudio 或不安装）
  - 桌面环境或窗口管理器（gnome、kde、xfce、sway、swayfx、wayfire、i3 或不安装）
  - 或者，选择不安装这些，安装一个最小化系统

- 可选择 base-system 或 base-container 基础系统元包
- 可选择使用 shred 安全擦除安装磁盘
- 可选择 doas 或 sudo
- 可选择使用的仓库镜像
- 可选择 linux、linux-lts 或 linux-mainline 内核
- 可选择 xfs 或 ext4 文件系统
- 在安装程序中配置 home、swap 和 root 分区，并支持 LVM
- 支持 glibc 和 musl
- 用户创建及基本配置

# 安装指南
1. 引导进入 Void Linux 的 live 媒体
2. 以 anon 用户登录
3. 执行以下命令：
   - `sudo xbps-install -S git`
   - `git clone https://github.com/kkrruumm/void-install-script/`
4. 进入脚本目录：
   - `cd void-install-script`
5. 为安装脚本赋予执行权限：
   - `chmod +x installer.sh`
6. 运行安装脚本：
   - `sudo ./installer.sh`
7. 按照屏幕上的步骤操作
8. 完成。


# efistub 和 UKI 注意事项

UKI 设置**将**提供全盘加密功能，因为 `/` 和 `/boot` 都将通过 luks2 加密。

efistub 设置**不会**提供全盘加密功能，因为 `/boot` 不会被加密。不过，根分区会使用 luks2 加密，而不是 luks1，因为这里不再受 grub 的限制。

请注意潜在的安全问题，例如使用 luks1 时使用较弱的密钥派生函数（如 pbkdf2），而不是 luks2 中使用的 argon2id。

efistub 和 UKI 在某些主板（不完全符合 UEFI 标准的主板）上**可能**会有些敏感，但这似乎不是大问题，只要我们“巧妙地”避免主板删除启动项。

# 模块说明

在安装程序中添加了一个基础的“模块”系统，以简化和组织各种功能的添加。

要创建模块，请在随安装程序提供的 `modules` 目录中创建一个文件，其文件名应为模块的标题。

然后，至少在此文件中添加 3 个必需的变量和 1 个必需的函数。如果缺少任何一个必需的变量或函数，安装程序将不会导入该模块。

模块文件内容示例：

```
title=nameofmymodule
description="- 这个模块执行 XYZ 操作"
status=off

main() {
    # 在这里执行你的操作
}
```

- `title` 变量将作为 TUI 中的条目名称，也是安装程序查找的文件名。
- `description` 变量是提供给用户的附加信息，显示在 TUI 中的选项旁，可以留空，但必须存在。
- `status` 变量告诉安装程序模块默认是启用还是禁用，合法值为 `on` 或 `off`。

在 `main()` 函数中，你可以自由添加任何需要执行的命令，并可以访问主安装脚本设置的所有变量。


你可以参考一些安装程序中自带的模块文件，获取更多示例。


# 隐藏的安装选项

有一些选项并未直接展示给用户，因为它们可能具有潜在的风险。用户可以通过创建一个文件来设置这些变量，并在执行安装程序时作为标志传递该文件。

示例：
```
./installer.sh /path/to/file
```

该文件可以包含以下任何或全部选项，示例中的值为默认设置：

```
acpi="true"
hash="sha512"
keysize="512"
itertime="10000"
basesystem="*" # 自定义基础系统包，而不是使用元包
```

如果文件中未设置这些变量，或未提供文件，则将使用上述默认值。

- `acpi` 切换可以设置为 `false`，以解决 ACPI 相关问题。这将为新安装设置内核参数 `acpi=off`。除非绝对必要，否则不要更改此设置。
- `hash`、`keysize` 和 `itertime` 都是用于加密安装时修改 LUKS 设置的变量。

我不建议更改 `hash` 和 `keysize` 的默认值，除非你非常确定需要更改。在更改这些值之前，请先进行研究。

`itertime` 稍微宽松一些。简而言之，值越大，暴力破解该磁盘所需的时间越长。

该值表示解锁磁盘所需的毫秒数，基于当前系统的计算能力。如果将此磁盘移到 CPU 更快的系统上，解锁速度将更快。

LUKS 默认值为 "2000"，即 2 秒。此安装程序中的默认值已增加，以考虑处理器较慢的系统（以及更注重安全的用户）。

根据 OWASP，符合 FIPS140 标准的值为 600000（即 10 分钟的磁盘解锁时间）。

隐藏设置功能的作用是提供更低级的控制，而不会增加安装程序的视觉负担。


# 其他说明

该安装程序仅支持 x86_64-efi，目前没有计划支持其他架构。

在大多数情况下，应该选择 `base-system` 元包，不过 `base-container` 提供了一个稍微更加精简的安装。