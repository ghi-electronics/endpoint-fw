
# Prepare sources
Download these necessary sources and place in download-src folder.

- Buildroot: https://gitlab.com/buildroot.org/buildroot/-/tree/2022.02.x?ref_type=heads  
- Linux 5.13: https://github.com/torvalds/linux/releases/tag/v5.13  
- Uboot 2021.10: https://github.com/u-boot/u-boot/releases/tag/v2021.10  
- WiFi: http://sources.buildroot.net/rtl8188eu/  
- .NET 8.0.100: https://dotnet.microsoft.com/en-us/download/dotnet/8.0  
- vsdbg16: https://vsdebugger.azureedge.net/vsdbg-16-0-20419-1/vsdbg-linux-arm.zip  

# Build

- Run ```extract_src.sh.sh```
- Run ```overwrite_src.sh```
- Run ```create_ext4_images.sh```
- Call ```make ep_st_defconfig && make```

All output files are located in ./output/images


